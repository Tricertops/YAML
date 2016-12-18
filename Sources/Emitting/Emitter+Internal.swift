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
        
        var emitter = yaml_emitter_t()
        var output: String = ""
        
        func emit(_ stream: Stream) throws -> String {
            setup()
            defer {
                cleanup()
            }
            try self.checkError()
            
            for event in eventsForStream(stream) {
                var rawEvent: yaml_event_t = .from(event)
                yaml_emitter_emit(&emitter, &rawEvent)
                
                try self.checkError()
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
            
            var index = 0 // This is safer, because documents could be duplicated.
            for node in stream.documents {
                let isFirst = (index == 0)
                let isLast = (index == stream.documents.count - 1)
                
                events.append(.documentStart(
                    hasVersion: isFirst && stream.hasVersion,
                    tags: isFirst ? stream.tags : [],
                    isImplicit: !(isFirst && stream.hasStartMark)))
                
                events += eventsForNode(node)
                
                events.append(.documentEnd(isImplicit: !(isLast && stream.hasEndMark)))
                
                index += 1
            }
            
            events.append(.streamEnd)
            return events
        }
        
        func eventsForNode(_ node: Node) -> [Event] {
            if let scalar = node as? Node.Scalar { return eventsForScalar(scalar) }
            if let sequence = node as? Node.Sequence { return eventsForSequence(sequence) }
            if let mapping = node as? Node.Mapping { return eventsForMapping(mapping) }
            assertionFailure("Unsupported Node type: \(node)")
            return []
        }
        
        func eventsForScalar(_ scalar: Node.Scalar) -> [Event] {
            return [
                .scalar(
                    anchor: scalar.anchor,
                    tag: scalar.tag.stringForEmitter,
                    content: scalar.content,
                    style: scalar.style ?? settings.style.scalar)
            ]
        }
        
        func eventsForSequence(_ sequence: Node.Sequence) -> [Event] {
            var events: [Event] = []
            
            events.append(.sequenceStart(
                anchor: sequence.anchor,
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
                anchor: mapping.anchor,
                tag: mapping.tag.stringForEmitter,
                style: mapping.style ?? settings.style.mapping))
            
            for pair in mapping.pairs {
                events += eventsForNode(pair.key)
                events += eventsForNode(pair.value)
            }
            
            events.append(.mappingEnd)
            return events
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
        case .standard(let name): return Tag.Standardized.prefix + name.rawValue
        case .uri(let content): return content
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

