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
    
    /// Returns length using `strlen()` C function.
    var c_length: Int {
        return Int(strlen(self))
    }
    
    /// Creates String from mutable libyaml char array.
    init(_ string: UnsafeMutablePointer<yaml_char_t>) {
        let converted = UnsafePointer<CChar>(string)
        self.init(String.fromCString(converted) ?? "")
    }
    
}


extension UnsafeMutablePointer {
    
    /// Enumerates libyaml array of arbitrary type.
    func enumerateToLast(last: UnsafeMutablePointer<Memory>, @noescape block: Memory -> ()) {
        var enumerated = self
        while enumerated != nil {
            block(enumerated.memory)
            enumerated = (enumerated == last ? nil : enumerated.successor())
        }
    }
    
}


extension Array {
    
    /// Creates array from libyaml array of arbitrary type.
    init(start: UnsafeMutablePointer<Element>, end: UnsafeMutablePointer<Element>) {
        self.init()
        start.enumerateToLast(end) { element in
            self.append(element)
        }
    }
    
}

