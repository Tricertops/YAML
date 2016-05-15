//
//  Utilities.swift
//  YAML.framework
//
//  Created by Martin Kiss on 14 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



extension String {
    
    /// Creates String from mutable libyaml char array.
    init(_ string: UnsafeMutablePointer<yaml_char_t>) {
        let casted = UnsafePointer<CChar>(string)
        self.init(String.fromCString(casted) ?? "")
    }
    
}


extension Array {
    
    /// Creates array from libyaml array of arbitrary type.
    init(start: UnsafeMutablePointer<Element>, end: UnsafeMutablePointer<Element>) {
        self.init()
        
        var current = start
        while current < end {
            self.append(current.memory)
            current = current.successor()
        }
    }
    
}

