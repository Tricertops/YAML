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



//MARK: Parser: Basic

/// Object that can read YAML files, builds their model structure, and allows reverse lookup of their source string.
public class Parser {
    
    /// Creates `Parser` that parses given string immediatelly.
    /// - TODO: Allow lazy parsing?
    public init(string: String) {
        self.string = string
        (self.stream, self.error, self.lookup) = Parser.parse(string)
    }
    
    /// The source string passed to `init(string:)`
    public let string: String
    
    /// Stream object parsed from the string, or `nil`, if the parsing failed.
    public let stream: Stream?
    
    
    //MARK: Parser: Errors
    
    /// Error that occured during parsing.
    /// - Note: Even if error occured, the `.stream` could be valid object.
    public let error: Swift.Error?
    
    /// Error states of the Parser.
    public struct Error: Swift.Error {
        
        /// Type of error. Some types are mediated from the underlaying C library.
        public enum Kind: String {
            /// No better information is known.
            case unspecified
            /// Mediated from C library: Cannot allocate or reallocate a block of memory.
            case allocation
            /// Mediated from C library: Cannot read or decode the input string.
            case decoding
            /// Mediated from C library: Cannot scan the input string.
            case scanning
            /// Mediated from C library: Cannot parse the input string.
            case parsing
        }
        
        /// Type of error.
        let kind: Kind
        /// Message that describes the error.
        let message: String
        /// Problematic value
        let value: Int?
        /// Position in the source string.
        let mark: Mark
        /// Message about error context.
        let contextMessage: String
        /// Context position in the source string.
        let contextMark: Mark
    }
    
    //MARK: Parser: Reverse Lookup
    
    /// Returns range of given parsed object in the source string or `nil` when the object didn’t come from this `Parser`.
    public func rangeOf(_ object: Node) -> Mark.Range? {
        return self.lookup[ObjectIdentifier(object)]
    }
    
    /// Returns source string of given parsed object in or `nil` when the object didn’t come from this `Parser`.
    public func stringOf(_ object: Node) -> String? {
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
        
        /// Representation of make range in the source string.
        public struct Range {
            /// Mark of the range start.
            public let start: Mark
            /// Mark of the range end.
            /// - Invariant: `begin.position <= end.position`
            public let end: Mark
            /// Index of first character in source string.
            public var location: UInt {
                return self.start.location
            }
            /// Number of characters included in the string.
            public var length: UInt {
                return max(0, self.end.location - self.start.location)
            }
            /// Internal initializer that validates endpoints.
            internal init(start: Parser.Mark, end: Parser.Mark) {
                assert(start.location <= end.location)
                self.start = start
                self.end = end
            }
        }
    }
    
    //MARK: Parser: Internal
    
    /// Lookup table type for Parsable objects.
    internal typealias Lookup = [ObjectIdentifier: Mark.Range]
    
    /// Lookup table for Parsable objects.
    private let lookup: Lookup
    
}

