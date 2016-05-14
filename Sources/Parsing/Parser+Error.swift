//
//  Parser+Error.swift
//  YAML.framework
//
//  Created by Martin Kiss on 14 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



extension yaml_parser_t {
    
    func checkError() throws {
        if let error = Parser.Error(self) {
            throw error
        }
    }
    
}


extension Parser.Error {
    
    init?(_ parser: yaml_parser_t) {
        guard let kind = Parser.Error.Kind.from(parser.error) else {
            return nil
        }
        self.kind = kind
        
        self.message = String.fromCString(parser.problem) ?? ""
        self.contextMessage = String.fromCString(parser.context) ?? ""
        
        let value = Int(parser.problem_value)
        self.value = (value == -1 ? nil : value)
        
        self.mark = Parser.Mark(parser.problem_mark)
        self.contextMark = Parser.Mark(parser.context_mark)
    }
    
}


extension Parser.Error.Kind {
    
    static func from(yaml_error: yaml_error_type_t) -> Parser.Error.Kind? {
        switch yaml_error {
            
        case YAML_NO_ERROR:
            return nil
            
        case YAML_MEMORY_ERROR:
            return .Allocation
            
        case YAML_READER_ERROR:
            return .Decoding
            
        case YAML_SCANNER_ERROR:
            return .Scanning
            
        case YAML_PARSER_ERROR:
            return .Parsing
            
        default:
            return .Unspecified
        }
    }
    
}

