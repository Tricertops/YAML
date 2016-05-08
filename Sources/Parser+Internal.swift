//
//  Parser+Internal.swift
//  YAML
//
//  Created by Martin Kiss on 7.5.16.
//  Copyright © 2016 Tricertops. All rights reserved.
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
        var c_currentEvent = yaml_event_t()
        
        var isFinished: Bool {
            return (c_currentEvent.type == YAML_NO_EVENT)
        }
        
        mutating func setup(string: String) throws {
            yaml_parser_initialize(&c_parser)
            try c_parser.checkError()
            yaml_parser_set_input_string(&c_parser, string, string.cLength)
        }
        
        mutating func cleanup() {
            self.result = (nil, Parser.Error(c_parser), [:])
            yaml_parser_delete(&c_parser)
            c_parser = yaml_parser_t()
        }
        
        mutating func processNextEvent() throws {
            c_currentEvent = yaml_event_t()
            yaml_parser_parse(&c_parser, &c_currentEvent)
            try c_parser.checkError()
            
            //TODO: Process event
            
            switch c_currentEvent.type {
                
            case YAML_NO_EVENT:
                log("No Event")
                
            case YAML_STREAM_START_EVENT:
                log("Stream Start")
                indentationLevel += 1
                
            case YAML_STREAM_END_EVENT:
                indentationLevel -= 1
                log("Stream End")
                
            case YAML_DOCUMENT_START_EVENT:
                log("Document Start")
                indentationLevel += 1
                
            case YAML_DOCUMENT_END_EVENT:
                indentationLevel -= 1
                log("Document End")
                
            case YAML_ALIAS_EVENT:
                log("Alias")
                
            case YAML_SCALAR_EVENT:
                log("Scalar")
                
            case YAML_SEQUENCE_START_EVENT:
                log("Sequence Start")
                indentationLevel += 1
                
            case YAML_SEQUENCE_END_EVENT:
                indentationLevel -= 1
                log("Sequence End")
                
            case YAML_MAPPING_START_EVENT:
                indentationLevel += 1
                log("Mapping Start")
                
            case YAML_MAPPING_END_EVENT:
                indentationLevel -= 1
                log("Mapping End")
                
            default:
                log("Unknown")
            }
        }
        
        var indentationLevel: Int = 0
        
        func log(string: String) {
            for _ in 0 ..< indentationLevel {
                print("  ", terminator: "")
            }
            print(string)
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
    
    var cLength: Int {
        return Int(strlen(self))
    }
    
}

