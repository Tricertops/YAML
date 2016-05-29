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
        return try Internal(emitter: self).emit(stream)
    }
    
    private class Internal {
        
        var emitter: Emitter
        
        init(emitter: Emitter) {
            self.emitter = emitter
        }
        
        var c_emitter = yaml_emitter_t()
        var output: String = ""
        
        func emit(stream: Stream) throws -> String {
            setup()
            defer {
                cleanup()
            }
            //TODO: Emit Stream and Nodes.
            
            var event = yaml_event_t()
            yaml_stream_start_event_initialize(&event, YAML_UTF8_ENCODING)
            yaml_emitter_emit(&c_emitter, &event)
            yaml_stream_end_event_initialize(&event)
            yaml_emitter_emit(&c_emitter, &event)
            
            return output
        }
        
        func setup() {
            yaml_emitter_initialize(&c_emitter)
            
            yaml_emitter_set_encoding(&c_emitter, YAML_UTF8_ENCODING)
            yaml_emitter_set_canonical(&c_emitter, Int32(emitter.isCanonical))
            yaml_emitter_set_indent(&c_emitter, Int32(emitter.indentation))
            yaml_emitter_set_width(&c_emitter, Int32(emitter.lineWidth ?? -1))
            yaml_emitter_set_unicode(&c_emitter, Int32(emitter.allowsUnicode))
            yaml_emitter_set_break(&c_emitter, emitter.lineBreaks.c_lineBreak)
            
            let boxed: UnsafeMutablePointer<Internal> = nil
            boxed.memory = self
            
            yaml_emitter_set_output(&c_emitter, {
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
            yaml_emitter_delete(&c_emitter)
            c_emitter = yaml_emitter_t() // Clear.
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
                    style: resolveStyle(
                        provided: scalar.style,
                        forced: emitter.forcedStyle.scalar,
                        fallback: emitter.defultStyle.scalar ?? Style.YAML.scalar!))
            ]
        }
        
        func eventsForSequence(sequence: Node.Sequence) -> [Event] {
            var events: [Event] = []
            
            events.append(.SequenceStart(
                anchor: sequence.anchor,
                tag: sequence.tag.stringForEmit,
                style: resolveStyle(
                    provided: sequence.style,
                    forced: emitter.forcedStyle.sequence,
                    fallback: emitter.defultStyle.sequence ?? Style.YAML.sequence!)))
            
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
                style: resolveStyle(
                    provided: mapping.style,
                    forced: emitter.forcedStyle.mapping,
                    fallback: emitter.defultStyle.mapping ?? Style.YAML.mapping!)))
            
            for pair in mapping.pairs {
                events += eventsForNode(pair.key)
                events += eventsForNode(pair.value)
            }
            
            events.append(.MappingEnd)
            return events
        }
        
        func resolveStyle<Style>(provided provided: Style?, forced: Style?, fallback: Style) -> Style {
            if let forced = forced { return forced }
            if let provided = provided { return provided }
            return fallback
        }
        
    }
    
}


extension Emitter.LineBreaks {
    
    var c_lineBreak: yaml_break_t {
        switch self {
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

