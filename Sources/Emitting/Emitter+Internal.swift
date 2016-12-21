//
//  Emitter+Internal.swift
//  YAML.framework
//
//  Created by Martin Kiss on 28 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



extension Emitter {
    
    func internal_emit(_ stream: Stream) throws -> String {
        return try Internal(settings: self).emit(stream)
    }
    
    private class Internal {
        
        var settings: Emitter
        
        init(settings: Emitter) {
            self.settings = settings
        }
        
        var emittedNodes: Set<ObjectIdentifier> = []
        var usedAnchors: Set<String> = []
        var anchorAdjustments: [String: String] = [:]
        var anchorsByNode: [ObjectIdentifier: String] = [:]
        var generatedAnchorIndex: Int = 1
        
        var emitter = yaml_emitter_t()
        var output: String = ""
        
        func emit(_ stream: Stream) throws -> String {
            setup()
            defer {
                cleanup()
            }
            try checkError()
            
            for event in eventsForStream(stream) {
                var rawEvent: yaml_event_t = .from(event)
                yaml_emitter_emit(&emitter, &rawEvent)
                
                try checkError()
            }
            
            return output
        }
        
        func setup() {
            yaml_emitter_initialize(&emitter)
            
            yaml_emitter_set_encoding(&emitter, YAML_UTF8_ENCODING)
            yaml_emitter_set_canonical(&emitter, Int32(settings.isCanonical))
            yaml_emitter_set_indent(&emitter, Int32(settings.indentation))
            yaml_emitter_set_width(&emitter, Int32(settings.lineWidth ?? -1))
            yaml_emitter_set_unicode(&emitter, Int32(settings.allowsUnicode))
            yaml_emitter_set_break(&emitter, .from(settings.lineBreaks))
            
            let boxed = UnsafeMutablePointer<Internal>.allocate(capacity: 1)
            boxed.initialize(to: self)
            
            yaml_emitter_set_output(&emitter, {
                (boxed, bytes, count) -> Int32 in
                let `self` = UnsafePointer<Internal>(OpaquePointer(boxed)!).pointee
                
                let buffer = UnsafeBufferPointer(start: bytes, count: count)
                var generator = buffer.makeIterator()
                var string = ""
                
                var decoder = UTF8()
                while case .scalarValue(let scalar) = decoder.decode(&generator) {
                    string.unicodeScalars.append(scalar)
                }
                
                self.appendString(string)
                
                return 1
                }, boxed)
        }
        
        func appendString(_ string: String) {
            output += string
        }
        
        func cleanup() {
            yaml_emitter_delete(&emitter)
            emitter = yaml_emitter_t() // Clear.
        }
        
        func checkError() throws {
            if let error = Emitter.Error(emitter) {
                throw error
            }
        }
        
        func eventsForStream(_ stream: Stream) -> [Event] {
            var events: [Event] = []
            events.append(.streamStart)
            
            resetAnchors()
            
            var index = 0 // This is safer, because documents could be duplicated.
            for node in stream.documents {
                let isFirst = (index == 0)
                let isLast = (index == stream.documents.count - 1)
                
                events.append(.documentStart(
                    hasVersion: isFirst && stream.hasVersion,
                    tags: isFirst ? stream.tags : [],
                    isImplicit: !(isFirst && stream.hasStartMark)))
                
                collectAnchors(node)
                self.emittedNodes = []
                events += eventsForNode(node)
                
                events.append(.documentEnd(isImplicit: !(isLast && stream.hasEndMark)))
                
                resetAnchors()
                index += 1
            }
            
            events.append(.streamEnd)
            return events
        }
        
        func eventsForNode(_ node: Node) -> [Event] {
            let nodeID = ObjectIdentifier(node)
            if self.emittedNodes.contains(nodeID) {
                // Node is referenced multiple times, it already have anchor.
                let anchor = anchorForNode(node)
                assert(!anchor.isEmpty)
                return [.alias(anchor: anchor)]
            }
            self.emittedNodes.insert(nodeID)
            
            if let scalar = node as? Node.Scalar { return eventsForScalar(scalar) }
            if let sequence = node as? Node.Sequence { return eventsForSequence(sequence) }
            if let mapping = node as? Node.Mapping { return eventsForMapping(mapping) }
            assertionFailure("Unsupported Node type: \(node)")
            return []
        }
        
        func eventsForScalar(_ scalar: Node.Scalar) -> [Event] {
            return [
                .scalar(
                    anchor: anchorForNode(scalar),
                    tag: scalar.tag.stringForEmitter,
                    content: scalar.content,
                    style: scalar.style ?? settings.style.scalar)
            ]
        }
        
        func eventsForSequence(_ sequence: Node.Sequence) -> [Event] {
            var events: [Event] = []
            
            events.append(.sequenceStart(
                anchor: anchorForNode(sequence),
                tag: sequence.tag.stringForEmitter,
                style: sequence.style ?? settings.style.sequence))
            
            for node in sequence.items {
                events += eventsForNode(node)
            }
            
            events.append(.sequenceEnd)
            return events
        }
        
        func eventsForMapping(_ mapping: Node.Mapping) -> [Event] {
            var events: [Event] = []
            
            events.append(.mappingStart(
                anchor: anchorForNode(mapping),
                tag: mapping.tag.stringForEmitter,
                style: mapping.style ?? settings.style.mapping))
            
            for pair in mapping.pairs {
                events += eventsForNode(pair.key)
                events += eventsForNode(pair.value)
            }
            
            events.append(.mappingEnd)
            return events
        }
        
        func collectAnchors(_ node: Node) {
            let nodeID = ObjectIdentifier(node)
            if self.emittedNodes.contains(nodeID) {
                // Node is referenced multiple times, it needs anchor.
                
                let anchor = self.anchorsByNode[nodeID] ?? ""
                if anchor.isEmpty {
                    self.anchorsByNode[nodeID] = createAnchor(for: node)
                }
            }
            else {
                // Node is referenced first time.
                self.emittedNodes.insert(nodeID)
                
                if let sequence = node as? Node.Sequence {
                    for item in sequence.items {
                        collectAnchors(item)
                    }
                }
                if let mapping = node as? Node.Mapping {
                    for (key, value) in mapping.pairs {
                        collectAnchors(key)
                        collectAnchors(value)
                    }
                }
            }
        }
        
        func anchorForNode(_ node: Node) -> String {
            let nodeID = ObjectIdentifier(node)
            let original = self.anchorsByNode[nodeID] ?? ""
            
            if let adjustment = self.anchorAdjustments[original] {
                return adjustment
            }
            return original
        }
        
        func createAnchor(for node: Node) -> String {
            var anchor = node.anchor
            
            if anchor.isEmpty {
                (anchor, self.generatedAnchorIndex) = generateAnchor(index: self.generatedAnchorIndex)
            }
            else {
                if self.usedAnchors.contains(anchor) {
                    // In case of conflict, adjust the existing one and new one.
                    let (adjustment, index) = generateAnchor(generator: .numeric(digits: 1), base: anchor)
                    self.anchorAdjustments[anchor] = adjustment
                    (anchor, _) = generateAnchor(generator: .numeric(digits: 1), base: anchor, index: index)
                }
            }
            self.usedAnchors.insert(anchor)
            return anchor
        }
        
        func resetAnchors() {
            self.emittedNodes = []
            self.usedAnchors = []
            self.anchorAdjustments = [:]
            self.anchorsByNode = [:]
            self.generatedAnchorIndex = 1
        }
        
        func generateAnchor(generator: AnchorGenerator? = nil, base: String = "", index: Int = 1) -> (anchor: String, index: Int) {
            let generator = generator ?? self.settings.anchorGenerator
            var index = index
            var anchor = base
            let prefix = base.isEmpty ? "" : (base + "-")
            
            while anchor.isEmpty || self.usedAnchors.contains(anchor) {
                anchor = prefix + generator.generate(index: index, existingCount: self.usedAnchors.count)
                index += 1
            }
            
            return (anchor, index)
        }
        
    }
    
}


extension Emitter.AnchorGenerator {
    
    func generate(index: Int, existingCount: Int = 0) -> String {
        switch self {
        case .numeric(let digits):
            var string = "\(index)"
            while string.characters.count < digits {
                string = "0" + string
            }
            return string
            
        case .random(let length):
            let characters = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"]
            var string = ""
            
            // With random of fixed length, we risk running out of combinations.
            var length = length
            if existingCount > 0 {                
                let minimalLength = Int(ceil(log(Double(existingCount) * 1.618) / log(Double(characters.count))))
                if length < minimalLength {
                    length = minimalLength
                }
            }
            
            for _ in 0..<length {
                let random = Int(arc4random_uniform(UInt32(characters.count)))
                string += characters[random]
            }
            return string
        }
    }
    
}


extension yaml_break_t {
    
    static func from(_ lineBreaks: Emitter.LineBreaks) -> yaml_break_t {
        switch lineBreaks {
        case .LF: return YAML_LN_BREAK
        case .CR: return YAML_CR_BREAK
        case .CRLF: return YAML_CRLN_BREAK
        }
    }
    
}


extension Tag {
    
    var stringForEmitter: String {
        switch self {
        case .none: return ""
        case .custom(let name): return "!" + name
        case .uri(let content): return content
        case .standard(let name):
            // These two tags probably never need to be emitted.
            if name == .seq || name == .map {
                return ""
            }
            return Tag.Standardized.prefix + name.rawValue
        }
    }
    
}


extension Emitter.Error {
    
    init?(_ emitter: yaml_emitter_t) {
        guard let kind: Emitter.Error.Kind = .from(emitter.error) else {
            return nil
        }
        self.kind = kind
        self.message = String(cString: emitter.problem)
    }
    
}


extension Emitter.Error.Kind {
    
    static func from(_ yaml_error: yaml_error_type_t) -> Emitter.Error.Kind? {
        switch yaml_error {
            
        case YAML_NO_ERROR:
            return nil
            
        case YAML_MEMORY_ERROR:
            return .allocation
            
        case YAML_WRITER_ERROR:
            return .writing
            
        case YAML_EMITTER_ERROR:
            return .emitting
            
        default:
            return .unspecified
        }
    }
    
}

