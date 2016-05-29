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
    
    func internal_emit(stream: Stream) throws -> String {
        return try Internal(settings: self).emit(stream)
    }
    
    private class Internal {
        
        var settings: Emitter
        
        init(settings: Emitter) {
            self.settings = settings
        }
        
        var emitter = yaml_emitter_t()
        var output: String = ""
        
        func emit(stream: Stream) throws -> String {
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
            
            let boxed: UnsafeMutablePointer<Internal> = nil
            boxed.memory = self
            
            yaml_emitter_set_output(&emitter, {
                (boxed, bytes, count) -> Int32 in
                let `self` = UnsafePointer<Internal>(boxed).memory
                
                let buffer = UnsafeBufferPointer(start: bytes, count: count)
                var generator = buffer.generate()
                var string = ""
                
                var decoder = UTF8()
                while case .Result(let scalar) = decoder.decode(&generator) {
                    string.unicodeScalars.append(scalar)
                }
                
                self.appendString(string)
                
                return 1
                }, boxed)
        }
        
        func appendString(string: String) {
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
        
        func eventsForStream(stream: Stream) -> [Event] {
            var events: [Event] = []
            events.append(.StreamStart)
            
            var index = 0 // This is safer, because documents could be duplicated.
            for node in stream.documents {
                let isFirst = (index == 0)
                let isLast = (index == stream.documents.count - 1)
                
                events.append(.DocumentStart(
                    hasVersion: isFirst && stream.hasVersion,
                    tags: isFirst ? stream.tags : [],
                    isImplicit: !(isFirst && stream.hasStartMark)))
                
                events += eventsForNode(node)
                
                events.append(.DocumentEnd(isImplicit: !(isLast && stream.hasEndMark)))
                
                index += 1
            }
            
            events.append(.StreamEnd)
            return events
        }
        
        func eventsForNode(node: Node) -> [Event] {
            if let scalar = node as? Node.Scalar { return eventsForScalar(scalar) }
            if let sequence = node as? Node.Sequence { return eventsForSequence(sequence) }
            if let mapping = node as? Node.Mapping { return eventsForMapping(mapping) }
            assertionFailure("Unsupported Node type: \(node)")
            return []
        }
        
        func eventsForScalar(scalar: Node.Scalar) -> [Event] {
            return [
                .Scalar(
                    anchor: scalar.anchor,
                    tag: scalar.tag.stringForEmit,
                    content: scalar.content,
                    style: scalar.style ?? settings.style.scalar)
            ]
        }
        
        func eventsForSequence(sequence: Node.Sequence) -> [Event] {
            var events: [Event] = []
            
            events.append(.SequenceStart(
                anchor: sequence.anchor,
                tag: sequence.tag.stringForEmit,
                style: sequence.style ?? settings.style.sequence))
            
            for node in sequence.items {
                events += eventsForNode(node)
            }
            
            events.append(.SequenceEnd)
            return events
        }
        
        func eventsForMapping(mapping: Node.Mapping) -> [Event] {
            var events: [Event] = []
            
            events.append(.MappingStart(
                anchor: mapping.anchor,
                tag: mapping.tag.stringForEmit,
                style: mapping.style ?? settings.style.mapping))
            
            for pair in mapping.pairs {
                events += eventsForNode(pair.key)
                events += eventsForNode(pair.value)
            }
            
            events.append(.MappingEnd)
            return events
        }
        
    }
    
}


extension yaml_break_t {
    
    static func from(lineBreaks: Emitter.LineBreaks) -> yaml_break_t {
        switch lineBreaks {
        case .LF: return YAML_LN_BREAK
        case .CR: return YAML_CR_BREAK
        case .CRLF: return YAML_CRLN_BREAK
        }
    }
    
}


extension Tag {
    
    var stringForEmit: String {
        switch self {
        case .None: return ""
        case .Explicit: return "!"
        case .Custom(let name): return "!" + name
        case .HandledCustom(let tag): return "!" + tag.handle + "!" + tag.name
        case .Standard(let name): return "!!" + name.rawValue
        case .URI(let content): return "!<" + content + ">"
        }
    }
    
}


extension Emitter.Error {
    
    init?(_ emitter: yaml_emitter_t) {
        guard let kind: Emitter.Error.Kind = .from(emitter.error) else {
            return nil
        }
        self.kind = kind
        self.message = String.fromCString(emitter.problem) ?? ""
    }
    
}


extension Emitter.Error.Kind {
    
    static func from(yaml_error: yaml_error_type_t) -> Emitter.Error.Kind? {
        switch yaml_error {
            
        case YAML_NO_ERROR:
            return nil
            
        case YAML_MEMORY_ERROR:
            return .Allocation
            
        case YAML_WRITER_ERROR:
            return .Writing
            
        case YAML_EMITTER_ERROR:
            return .Emitting
            
        default:
            return .Unspecified
        }
    }
    
}

