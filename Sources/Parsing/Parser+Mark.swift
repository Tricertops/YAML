//
//  Parser+Mark.swift
//  YAML.framework
//
//  Created by Martin Kiss on 14 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



extension Parser.Mark {
    
    func indexInString(string: String) -> String.UTF8Index {
        let start = string.utf8.startIndex
        let end = string.utf8.endIndex
        return start.advancedBy(Int(self.location), limit: end)
    }
    
    init(_ c_mark: yaml_mark_t) {
        self.location = UInt(c_mark.index)
        self.line = UInt(c_mark.line)
        self.column = UInt(c_mark.column)
    }
    
}


extension Parser.Mark: Comparable { }

public func == (left: Parser.Mark, right: Parser.Mark) -> Bool {
    return left.location == right.location
}

public func < (left: Parser.Mark, right: Parser.Mark) -> Bool {
    return left.location < right.location
}


extension Parser.Mark.Range {
    
    func rangeInString(string: String) -> Swift.Range<String.UTF8Index> {
        let start = self.start.indexInString(string)
        let end = self.end.indexInString(string)
        return start ..< end
    }
    
    func substringFromString(string: String) -> String {
        let range = self.rangeInString(string)
        return String(string.utf8[range])
    }
    
    static func union(ranges: Parser.Mark.Range? ...) -> Parser.Mark.Range {
        var start: Parser.Mark?
        var end: Parser.Mark?
        
        for optionalRange in ranges {
            guard let range = optionalRange else { continue }
            if start == nil { start = range.start }
            if end == nil { end = range.end }
            
            start = min(start!, range.start)
            end = max(end!, range.end)
        }
        assert(start != nil, "Misuse of range union.")
        assert(start != nil, "Misuse of range union.")
        return Parser.Mark.Range(start: start!, end: end!)
    }
    
}


func ... (start: Parser.Mark, end: Parser.Mark) -> Parser.Mark.Range {
    return Parser.Mark.Range(start: start, end: end)
}

