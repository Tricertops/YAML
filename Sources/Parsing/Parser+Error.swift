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



extension Parser.Error {
    
    init?(_ parser: yaml_parser_t) {
        guard let kind: Parser.Error.Kind = .from(parser.error) else {
            return nil
        }
        self.kind = kind
        
        self.message = String(cString: parser.problem)
        self.contextMessage = String(cString: parser.context)
        
        let value = Int(parser.problem_value)
        self.value = (value == -1 ? nil : value)
        
        self.mark = Parser.Mark(parser.problem_mark)
        self.contextMark = Parser.Mark(parser.context_mark)
    }
    
}


extension Parser.Error.Kind {
    
    static func from(_ yaml_error: yaml_error_type_t) -> Parser.Error.Kind? {
        switch yaml_error {
            
        case YAML_NO_ERROR:
            return nil
            
        case YAML_MEMORY_ERROR:
            return .allocation
            
        case YAML_READER_ERROR:
            return .decoding
            
        case YAML_SCANNER_ERROR:
            return .scanning
            
        case YAML_PARSER_ERROR:
            return .parsing
            
        default:
            return .unspecified
        }
    }
    
}

