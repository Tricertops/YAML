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
    init(_ string: UnsafeMutablePointer<yaml_char_t>?) {
        guard let string = string else {
            self.init()
            return
        }
        
        let casted = UnsafePointer<CChar>(OpaquePointer(string))
        self.init(cString: casted)
    }
    
    /// Convenience function for obtaining indexes.
    func index(_ offset: Int) -> String.Index {
        return self.index(self.startIndex, offsetBy: offset)
    }
    
    /// Convenience function for obtaining indexes from the end.
    func index(backwards offset: Int) -> String.Index {
        return self.index(self.endIndex, offsetBy: -offset)
    }
    
    /// Substring from a native String.Index.
    func substring(from offset: Int) -> String {
        return String(self[self.index(offset) ..< self.endIndex])
    }
    
    /// Substring to a native String.Index.
    func substring(to offset: Int) -> String {
        return String(self[self.startIndex ..< self.index(backwards: offset)])
    }
    
    /// Invoke block on the contents of this string, represented as a nul-terminated array of char, ensuring the array's lifetime until return.
    func withMutableCString<Result>(_ block: @escaping (UnsafeMutablePointer<UInt8>) throws -> Result) rethrows -> Result {
        var array = self.utf8CString
        return try array.withUnsafeMutableBufferPointer { buffer in
            let casted = UnsafeMutablePointer<UInt8>(OpaquePointer(buffer.baseAddress!))
            return try block(casted)
        }
    }
    
}


extension Array {
    
    /// Creates array from libyaml array of arbitrary type.
    init(start: UnsafeMutablePointer<Element>?, end: UnsafeMutablePointer<Element>?) {
        self.init()
        
        guard let start = start else { return }
        guard let end = end else { return }
        
        var current = start
        while current < end {
            self.append(current.pointee)
            current += 1
        }
    }
    
}


extension Int32 {
    
    init(_ bool: Bool) {
        self.init(bool ? 1 : 0)
    }
    
}

