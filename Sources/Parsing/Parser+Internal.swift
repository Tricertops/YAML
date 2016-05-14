//
//  Parser+Internal.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//


//MARK: Parser: Mark

private extension Parser.Mark {
    
    private func indexInString(string: String) -> String.UTF8Index {
        let start = string.utf8.startIndex
        let end = string.utf8.endIndex
        return start.advancedBy(Int(self.location), limit: end)
    }
    
    private init(_ c_mark: yaml_mark_t) {
        self.location = UInt(c_mark.index)
        self.line = UInt(c_mark.line)
        self.column = UInt(c_mark.column)
    }
    
}


internal extension Parser.Mark.Range {
    
    private func rangeInString(string: String) -> Swift.Range<String.UTF8Index> {
        let start = self.start.indexInString(string)
        let end = self.end.indexInString(string)
        return start ..< end
    }
    
    internal func substringFromString(string: String) -> String {
        let range = self.rangeInString(string)
        return String(string.utf8[range])
    }
    
}


//MARK: Parser: Parsing

extension Parser {
    
    typealias Result = (stream: Stream?, error: ErrorType?, lookup: Lookup)
    
    static func parse(string: String) -> Result {
        var parser = Internal()
        do {
            try parser.setup(string)
            defer {
                parser.cleanup()
            }
            
            repeat {
                try parser.processNextEvent()
            } while(!parser.isFinished)
        }
        catch {
            return (nil, error, [:])
        }
        return parser.result
    }
    
    private struct Internal {
        
        var result: Result = (nil, nil, [:])
        
        var c_parser = yaml_parser_t()
        var currentEvent: Event? = nil
        
        var isFinished: Bool {
            return (currentEvent == nil)
        }
        
        mutating func setup(string: String) throws {
            yaml_parser_initialize(&c_parser)
            try c_parser.checkError()
            yaml_parser_set_input_string(&c_parser, string, string.c_length)
        }
        
        mutating func cleanup() {
            self.result = (nil, Parser.Error(c_parser), [:])
            yaml_parser_delete(&c_parser)
            c_parser = yaml_parser_t()
        }
        
        mutating func processNextEvent() throws {
            var c_currentEvent = yaml_event_t()
            yaml_parser_parse(&c_parser, &c_currentEvent)
            try c_parser.checkError()
            
            currentEvent = Event.from(c_event: c_currentEvent)
            let description = currentEvent == nil ? "nil" : currentEvent!.debugDescription
            print("Event: \(description)")
        }
        
    }
    
}


//MARK: Parser: Event

extension Parser {
    
    enum Event {
        case StreamStart
        case StreamEnd
        case DocumentStart(tags: [Tag.Directive])
        case DocumentEnd
        case Alias(anchor: String)
        case Scalar(anchor: String?, tag: Tag?, content: String, style: YAML.Scalar.Style)
        case SequenceStart(anchor: String?, tag: Tag?, style: Sequence.Style)
        case SequenceEnd
        case MappingStart(anchor: String?, tag: Tag?, style: Mapping.Style)
        case MappingEnd
        
        static func from(c_event c_event: yaml_event_t) -> Event? {
            switch c_event.type {
                
            case YAML_NO_EVENT:
                return nil
                
            case YAML_STREAM_START_EVENT:
                return .StreamStart
                
            case YAML_STREAM_END_EVENT:
                return .StreamEnd
                
            case YAML_DOCUMENT_START_EVENT:
                let c_document = c_event.data.document_start
                var directives: [Tag.Directive] = []
                c_document.tag_directives.start.enumerateToLast(c_document.tag_directives.end) {
                    c_directive in
                    directives.append(Tag.Directive(
                        handle: String(c_directive.handle),
                        prefix: String.from(c_directive.prefix)))
                }
                return .DocumentStart(tags: directives)
                
            case YAML_DOCUMENT_END_EVENT:
                return .DocumentEnd
                
            case YAML_ALIAS_EVENT:
                let c_alias = c_event.data.alias
                return .Alias(anchor: String.from(c_alias.anchor))
                
            case YAML_SCALAR_EVENT:
                let c_scalar = c_event.data.scalar
                let anchor = String.from(c_scalar.anchor)
                var tag = Tag()
                tag.handle = String.from(c_scalar.tag)
                let content = String.from(c_scalar.value)
                let style = YAML.Scalar.Style.Plain
                return .Scalar(anchor: anchor, tag: tag, content: content, style: style)
                
            case YAML_SEQUENCE_START_EVENT:
                let c_sequence = c_event.data.sequence_start
                let anchor = String.from(c_sequence.anchor)
                var tag = Tag()
                tag.handle = String.from(c_sequence.tag)
                let style = Sequence.Style.Block
                return .SequenceStart(anchor: anchor, tag: tag, style: style)
                
            case YAML_SEQUENCE_END_EVENT:
                return .SequenceEnd
                
            case YAML_MAPPING_START_EVENT:
                let c_mapping = c_event.data.sequence_start
                let anchor = String.from(c_mapping.anchor)
                var tag = Tag()
                tag.handle = String.from(c_mapping.tag)
                let style = Mapping.Style.Block
                return .MappingStart(anchor: anchor, tag: tag, style: style)
                
            case YAML_MAPPING_END_EVENT:
                return .MappingEnd
                
            default:
                return nil
            }
        }
    }
}

extension Parser.Event: CustomDebugStringConvertible {
    
    var debugDescription: String {
        switch self {
        case StreamStart: return "Stream:"
        case StreamEnd: return ":Stream"
        case DocumentStart(let tags): return "Document (Tags: \(tags)):"
        case DocumentEnd: return ":Document"
        case Alias(let anchor): return "Alias: *\(anchor)"
        case Scalar(let anchor, let tag, let content, _):
            return "Scalar"
                + (anchor == nil || anchor!.isEmpty ? "" : " &" + anchor!)
                + (tag == nil || tag!.handle.isEmpty ? "" : " !" + tag!.handle)
                + ": " + content
        case SequenceStart(let anchor, let tag, _):
            return "Sequence"
                + (anchor == nil || anchor!.isEmpty ? "" : " &" + anchor!)
                + (tag == nil || tag!.handle.isEmpty ? "" : " !" + tag!.handle)
                + ":"
        case SequenceEnd: return ":Sequence"
        case MappingStart(let anchor, let tag, _):
            return "Mapping"
                + (anchor == nil || anchor!.isEmpty ? "" : " &" + anchor!)
                + (tag == nil || tag!.handle.isEmpty ? "" : " !" + tag!.handle)
                + ":"
        case MappingEnd: return ":Mapping"
        }
    }
    
}


//MARK: Parser: Error

extension yaml_parser_t {
    
    func checkError() throws {
        if let error = Parser.Error(self) {
            throw error
        }
    }
    
}


extension Parser.Error {
    
    private init?(_ c_parser: yaml_parser_t) {
        let type: Type
        switch c_parser.error {
        case YAML_NO_ERROR: return nil
        case YAML_MEMORY_ERROR: type = .Allocation
        case YAML_READER_ERROR: type = .Decoding
        case YAML_SCANNER_ERROR: type = .Scanning
        case YAML_PARSER_ERROR: type = .Parsing
        default: type = .Unspecified
        }
        self.type = type
        self.message = String.fromCString(c_parser.problem) ?? ""
        let c_value = Int(c_parser.problem_value)
        self.value = (c_value == -1 ? nil : c_value)
        self.mark = Parser.Mark(c_parser.problem_mark)
        self.contextMessage = String.fromCString(c_parser.context) ?? ""
        self.contextMark = Parser.Mark(c_parser.context_mark)
    }
    
}


//MARK: Utilities

extension String {
    
    var c_length: Int {
        return Int(strlen(self))
    }
    
    static func from(yaml_string: UnsafePointer<yaml_char_t>) -> String {
        let converted = UnsafePointer<CChar>(yaml_string)
        return String.fromCString(converted) ?? ""
    }
    
    static func from(yaml_string: UnsafeMutablePointer<yaml_char_t>) -> String {
        let converted = UnsafePointer<CChar>(yaml_string)
        return String.fromCString(converted) ?? ""
    }
    
}

extension UnsafeMutablePointer {
    
    func enumerateToLast(last: UnsafeMutablePointer<Memory>, @noescape block: Memory -> ()) {
        var enumerated = self
        while enumerated != nil {
            block(enumerated.memory)
            enumerated = (enumerated == last ? nil : enumerated.successor())
        }
    }
    
}

