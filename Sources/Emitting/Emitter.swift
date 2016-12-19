//
//  Emitter.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



//MARK: Emitter: Basics

/// Object that can write YAML streams into string representation.
public class Emitter {
    
    /// Creates default Emitter. Default values are defined by underlaying C library.
    public init() { }
    
    /// Produces a YAML string from given Stream object.
    public func emit(_ stream: Stream) throws -> String {
        return try self.internal_emit(stream)
    }
    
    /// Produces a YAML string from a given Node.
    public func emit(_ node: Node) throws -> String {
        return try self.emit(Stream(documents: [node]))
    }
    
    
    //MARK: Emitter: Print Style
    
    /// Set if the output should be in the "canonical" format as in the YAML specification.
    public var isCanonical: Bool = false
    
    /// Set the intendation increment in range 2...9
    public var indentation: Int = 2
    
    /// Set the preferred line width. Set `nil` for unlimited.
    public var lineWidth: Int? = 80
    
    /// Set if unescaped non-ASCII characters are allowed.
    public var allowsUnicode: Bool = true
    
    /// Set the preferred line break string.
    public var lineBreaks: LineBreaks = .Unix
    
    /// Possible LineBreaks.
    public enum LineBreaks: String {
        case LF = "\n" ///  Line Feed (U+000A)
        case CR = "\r" /// Carriage Return (U+000D)
        case CRLF = "\r\n" ///  Carriage Return + Line Feed
        
        public static let Unix: LineBreaks = .LF
        public static let Windows: LineBreaks = .CRLF
    }
    
    
    //MARK: Emitter: Node Style
    
    /// Node styles used when the Node doesn’t specify one.
    public var style: Style = .yaml
    
    /// Collection of optional Node styles.
    public struct Style {
        /// Style used for Scalar nodes.
        public var scalar: Node.Scalar.Style
        /// Style used for Sequence nodes.
        public var sequence: Node.Sequence.Style
        /// Style used for Mapping nodes.
        public var mapping: Node.Mapping.Style
        
        /// Style collection with default YAML styles: plain scalars, block sequences and mappings.
        public static let yaml = Style(scalar: .plain, sequence: .block, mapping: .block)
        /// Style collection with JSON styles: double-quoted scalars, flow sequences nad mappings.
        public static let json = Style(scalar: .doubleQuoted, sequence: .flow, mapping: .flow)
    }
    
    
    //MARK: Anchor Generation
    
    /// Describes strategy used to create anchors when none are assigned to emitted nodes with multiple references.
    /// - Note: Nodes in the emitted tree are allowed to have conflicting anchors. They will be handled by appending unique suffix.
    public var anchorGenerator: AnchorGenerator = .numeric(digits: 3)
    
    /// Possible anchor generator techniques.
    public enum AnchorGenerator {
        /// Generates sequential anchors that begin with 1, padded to at least given number of digits. (001, 002, 003, 004, …)
        case numeric(digits: Int)
        /// Generates anchors of pseudo-random hexadecimal numbers with given length. (33e7aa, 5513b1, 6f9a22, …)
        case random(length: Int)
    }
    
    
    //MARK: Emitter: Error
    
    /// Errors thrown by the Emitter
    public struct Error: Swift.Error {
        
        /// Type of error. Some types are mediated from the underlaying C library.
        public enum Kind: String {
            /// No better information is known.
            case unspecified
            /// Mediated from C library: Cannot allocate or reallocate a block of memory.
            case allocation
            /// Mediated from C library: Cannot write to the output string.
            case writing
            /// Mediated from C library: Cannot emit a YAML stream.
            case emitting
        }
        
        /// Type of error.
        let kind: Kind
        /// Message that describes the error.
        let message: String
    }
    
}

