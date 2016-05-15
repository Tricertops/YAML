//
//  Node.swift
//  YAML.framework
//
//  Created by Martin Kiss on 14 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



/// Common supertype for YAML content: Scalars, Sequences, Mappings.
///
/// - Note:
/// Nodes are reference types and may be used multiple times in YAML document. Such reusing is supported by YAML anchors.
/// If you encouter a single Node on multiple places after parsing YAML. This means this node has been referenced using Alias.
/// If you pass a document to Emitter with multiple references to one Node. Repeated references are emitted as Aliases.
public class Node {
    
    /// Optional type information of this Node.
    public var tag: Tag = .None
    
    /// Optional string identifying this Node in cross-references.
    public var anchor: String = ""
    
}


extension Node {
    
    /// Represents all leaves (non-collections) in YAML format: strings, numbers, null
    public class Scalar: Node {
        
        /// String representation of the content.
        public var content: String = ""
        
        /// Style detected by Parser or intended to Emitter.
        public var style: Style? = .Auto
        
        /// Possible Scalar styles.
        public enum Style {
            case Plain /// No quotes,  inline, does NOT allow or preserve newlines.
            case SingleQuoted /// Enclosed in single quotes, inline, preserves newlines.
            case DoubleQuoted /// Enclosed in double quotes, inline, preserves newlines.
            case Folded /// No quotes,  multiline, does NOT preserve newlines.
            case Literal /// No quotes, multiline, preserves newlines.
            
            /// Default unspecified style. Can be specified in Emitter.
            public static let Auto: Style? = nil
        }
    }
}


extension Node {
    
    /// Represents ordered collections in YAML format.
    public class Sequence: Node {
        
        /// Array of all contained nodes.
        public var items: [Node] = []
        
        /// Style detected by Parser or intended to Emitter.
        public var style: Style? = .Auto
        
        /// Possible Sequence styles.
        public enum Style {
            case Block /// Standard YAML style with leading hyphens.
            case Flow /// JSON style, enclosed in square braces.
            
            /// Default unspecified style. Can be specified in Emitter.
            public static let Auto: Style? = nil
        }
    }
}


extension Node.Sequence {
    
    /// Shorthand for detecting empty.
    public var isEmpty: Bool {
        return items.isEmpty
    }
    
    /// Shorthand for detecting count.
    public var count: Int {
        return items.count
    }
    
    /// Shorthand for accessing items.
    public subscript(index: Int) -> Node {
        get { return items[index] }
        set { items[index] = newValue }
    }
    
    /// Shorthand for appending items.
    public func append(node: Node) {
        items.append(node)
    }
    
}


extension Node {
    
    /// Represents mapping in YAML format.
    public class Mapping: Node {
        
        /// Type of the Node pair.
        public typealias Pair = (key: Node, value: Node)
        
        /// Array of all contained pairs. Key and value may be any other Node subtype. Keys may be duplicated.
        /// - Note: This is stored as ordered collection, but the order should not be significant to data modeling, only for presentation.
        public var pairs: [Pair] = []
        
        /// Style detected by Parser or intended to Emitter.
        public var style: Style? = .Auto
        
        /// Possible Mapping styles.
        public enum Style {
            case Block /// Standard YAML style.
            case Flow /// JSON style, enclosed in curly braces.
            
            /// Default unspecified style. Can be specified in Emitter.
            public static let Auto: Style? = nil
        }
    }
}


extension Node.Mapping {
    
    /// Shorthand for detecting empty.
    public var isEmpty: Bool {
        return pairs.isEmpty
    }
    
    /// Shorthand for detecting count.
    public var count: Int {
        return pairs.count
    }
    
    /// Shorthand for accessing pairs.
    public subscript(index: Int) -> Pair {
        get { return pairs[index] }
        set { pairs[index] = newValue }
    }
    
    /// Shorthand for appending pairs.
    public func append(key key: Node, value: Node) {
        pairs.append((key, value))
    }
    
    /// Convenience for finding first matching key of Scalar node.
    public subscript(scalarContent: String) -> Node? {
        for (key, value) in pairs {
            if let key = key as? Node.Scalar {
                if key.content == scalarContent {
                    return value
                }
            }
        }
        return nil
    }
    
}

