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
    
    /// Substring from an index as Int.
    func substring(from index: Int) -> String {
        return self.substring(from: self.startIndex + index)
    }
    
    /// Substring from a native String.Index.
    func substring(from index: Index) -> String {
        return String(self[index ..< self.endIndex])
    }
    
    /// Substring to an index as Int.
    func substring(to index: Int) -> String {
        return self.substring(to: self.startIndex + index)
    }
    
    /// Substring to a native String.Index.
    func substring(to index: Index) -> String {
        return String(self[self.startIndex ..< index])
    }
    
    /// Invoke block on the contents of this string, represented as a nul-terminated array of char, ensuring the array's lifetime until return.
    func withMutableCString<Result>(@noescape block: (UnsafeMutablePointer<UInt8>) throws -> Result) rethrows -> Result {
        var array = self.nulTerminatedUTF8
        return try array.withUnsafeMutableBufferPointer { buffer in
            return try block(buffer.baseAddress)
        }
    }
    
}


extension Array {
    
    /// Creates array from libyaml array of arbitrary type.
    init(start: UnsafeMutablePointer<Element>, end: UnsafeMutablePointer<Element>) {
        self.init()
        
        var current = start
        while current < end {
            self.append(current.memory)
            current += 1
        }
    }
    
}


func +
    <IndexType: ForwardIndexType>
    (index: IndexType,
     increment: IndexType.Distance)
    -> IndexType {
        return index.advancedBy(increment)
}

func -
    <IndexType: BidirectionalIndexType>
    (index: IndexType,
     decrement: IndexType.Distance)
    -> IndexType {
        return index.advancedBy(decrement)
}

func -
    <IndexType: ForwardIndexType>
    (larger: IndexType,
     smaller: IndexType)
    -> IndexType.Distance {
        return smaller.distanceTo(larger)
}


extension Int32 {
    
    init(_ bool: Bool) {
        self.init(bool ? 1 : 0)
    }
    
}

