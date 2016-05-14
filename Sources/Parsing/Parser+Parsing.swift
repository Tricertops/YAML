//
//  Parser+Parsing.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



extension Parser {
    
    typealias Result = (stream: Stream?, error: ErrorType?, lookup: Lookup)
    
    static func parse(string: String) -> Result {
        var internal_parser = Internal()
        do {
            try internal_parser.setup(string)
            defer { internal_parser.cleanup() }
            
            while internal_parser.hasNextEvent {
                try internal_parser.processNextEvent()
            }
        }
        catch {
            return (nil, error, [:])
        }
        return (internal_parser.stream, nil, internal_parser.lookup)
    }
    
}


extension Parser {
    
    struct Internal {
        
        var stream: Stream?
        var lookup: Lookup = [:]
        
        var parser = yaml_parser_t()
        var hasNextEvent: Bool = true
        
        mutating func setup(string: String) throws {
            yaml_parser_initialize(&parser)
            try parser.checkError()
            yaml_parser_set_input_string(&parser, string, string.c_length)
        }
        
        mutating func cleanup() {
            if Parser.Error(parser) != nil {
                stream = nil
                lookup = [:]
                hasNextEvent = false
            }
            yaml_parser_delete(&parser)
            parser = yaml_parser_t() // Clear.
        }
        
        mutating func loadNextEvent() throws -> Event? {
            var yaml_event = yaml_event_t()
            yaml_parser_parse(&parser, &yaml_event)
            let event = Event.from(yaml_event)
            hasNextEvent = (event != nil)
            try parser.checkError()
            return event
        }
        
        mutating func processNextEvent() throws {
            guard let event = try loadNextEvent() else {
                return
            }
            
            print("Event: \(event.debugDescription)")
        }
        
    }
    
}


