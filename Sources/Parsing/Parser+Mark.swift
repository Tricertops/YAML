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
    
}

