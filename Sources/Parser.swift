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


//MARK: Parser: Base

/// Object that can read YAML files, builds their model structure, and allows reverse lookup of their source string.
public class Parser {
    
    /// Creates `Parser` that parses given string immediatelly.
    /// - TODO: Allow lazy parsing?
    public init(string: String) {
        self.string = string
        self.internal_parse()
    }
    
    /// The source string passed to `init(string:)`
    public let string: String
    
    /// Stream object parsed from the string, or `nil`, if the parsing failed.
    public internal(set) var stream: Stream? = nil
    
    /// Error that occured during parsing.
    /// - Note: Even if error occured, the `.stream` could be valid object.
    public internal(set) var error: ErrorType? = nil
    
    
    //MARK: Parser: Reverse Lookup
    
    /// Returns range of given parsed object in the source string or `nil` when the object didn’t come from this `Parser`.
    public func rangeOf(object: Parsed) -> Mark.Range? {
        return self.lookup[ObjectIdentifier(object)]
    }
    
    /// Returns source string of given parsed object in or `nil` when the object didn’t come from this `Parser`.
    public func stringOf(object: Parsed) -> String? {
        return self.rangeOf(object)?.substringFromString(self.string)
    }
    
    /// Representation of a mark in the source string.
    /// - Important: Uses UTF-8 bytes!
    /// - TODO: Convert UTF-8 locations from `libyaml` to character indexes.
    public struct Mark {
        /// Index of character in source string.
        public let location: UInt
        /// Line on which the mark is located.
        public let line: UInt
        /// Index of character within the line.
        public let column: UInt
        
        //TODO: No public init()
        
        /// Representation of make range in the source string.
        public struct Range {
            /// Mark of the range start.
            public let start: Mark
            /// Mark of the range end.
            /// - Invariant: `end.position >= begin.position`
            public let end: Mark
            /// Index of first character in source string.
            public var location: UInt {
                return self.start.location
            }
            /// Number of characters included in the string.
            public var length: UInt {
                return max(0, self.end.location - self.start.location)
            }
            
            //TODO: No public init()
        }
    }
    
    /// Lookup table for Parsed objects.
    internal var lookup: [ObjectIdentifier: Mark.Range] = [:]
    
}


/// Object that was created by Parser and can be mapped back to source string.
/// - SeeAlso: `Parser.rangeOf(_:)`, `Parser.stringOf(_:)`
public protocol Parsed: AnyObject { }

