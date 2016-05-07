//
//  Parser.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//


class Parser {
    
    init(string: String) { }
    init(file: String) { }
    
    func parse() throws { }
    
    let error: ErrorType? = nil
    let parsed: Stream? = nil
}


protocol Markable: AnyObject {
    
}


extension Parser {
    
    struct Mark {
        let location: Int
        let line: Int
        let column: Int
        
        struct Range {
            let begin: Mark
            let end: Mark
            var location: Int { return begin.location }
            var length: Int { return end.location - location }
        }
    }
    
    func rangeOf(object: Markable) -> Mark.Range! {
        return nil
    }
    func stringOf(object: Markable) -> String? {
        return nil
    }
    
}

