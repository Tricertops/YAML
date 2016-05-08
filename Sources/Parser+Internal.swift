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
    
    struct Internal {
        typealias Result = (stream: Stream?, error: ErrorType?, lookup: Lookup)
        
        static func parse(string: String) -> Result {
            //TODO: Construct libyaml parser.
            //TODO: Build YAML model from events.
            return (nil, nil, [:])
        }
    }
    
}

