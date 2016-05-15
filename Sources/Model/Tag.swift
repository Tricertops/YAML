//
//  Tag.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



/// Tags allow type annotations in YAML content. 
public enum Tag: Equatable {
    
    /// No tag is provided. This is the default.
    case None  // ""
    
    /// Non-specific tag is provided. Used to suppress implicit tag resolution.
    /// - Note: For example, scalar with content “true” is normally resolved to a Boolean type.
    /// Assigning it an .Explicit tag causes it to become String with “true” content.
    /// - Note: This Tag case will not be produced by Parser, since it will be resolved to .Standard case.
    case Explicit  // "!"
    
    /// Application-specific tag with name. Will be prefixed with “!”.
    /// - Note: This is the most common use case for archivation of nonstandard types.
    /// - Important: Do not attempt to misuse this case. Any existing “!” marks will be escaped.
    case Custom(String)  // !name
    
    /// Application-specific tag with handle and name. Both will be prefixed with “!” and concatenated.
    /// - Important: Handle must be defined by %TAG directive in the same YAML stream.
    /// - Note: This Tag case will not be produced by Parser, since it will be resolved to .URI case.
    case HandledCustom(handle: String, name: String)  // !handle!name
    
    /// Standard YAML-defined tag, for example String, Integer, Boolean. Will be prefixed with “!!”.
    /// - Note: Full name of this tag is prefixed with “tag:yaml.org,2002:”.
    case Standard(Tag.Standardized)  // !!name
    
    /// Tag with fully resolved name that is not resolved further. Will be enclosed in “<>” and prefixed with “!”.
    case URI(String)  // !<content>
    
}


extension Tag {
    
    /// List of language-independent YAML tags defined under the domain yaml.org.
    public enum Standardized: String {
        /// Core Tags
        case str /// A sequence of zero or more Unicode characters.
        case seq /// Sequence of arbitrary values.
        case map /// Unordered set of key-value pairs with NO duplicates.
        
        /// Extended Tags
        case bool /// Mathematical Booleans.
        case binary /// A sequence of zero or more octets (8 bit values). Typically in Base64 encoding.
        case float /// Floating-point approximation to real numbers.
        case int /// Mathematical integers.
        case null /// Devoid of value.
        
        /// Advanced Tags
        case omap /// Ordered sequence of key-value pairs with NO duplicates.
        case pairs /// Ordered sequence of key-value pairs allowing duplicates.
        case set /// Unordered set with NO duplicates.
        case merge /// Specify one or more mappings to be merged with the current one.
        case timestamp /// A point in time.
        case value /// Specify the default value of a mapping.
        case yaml /// Keys for encoding YAML in YAML.
        
        /// Prefix used by resolved standard tags.
        static let prefix = "tag:yaml.org,2002:"
    }
    
}


extension Tag {
    
    /// Represents declaration of custom tag handle.
    public struct Directive {
        
        /// String that can be used as handle for future tags.
        /// - SeeAlso: `Tag.HandledCustom`
        public var handle: String = ""
        
        /// Globally unique identifier used as namespace for tags referenced using associated handle.
        /// - Note: Prefixes should should follow this pattern: “tag:yaml.org,2002:”
        public var URI: String = ""
        
    }
}


public func == (left: Tag, right: Tag) -> Bool {
    switch (left, right) {
        
    case (.None
        , .None)
        : return true
        
    case (.Explicit
        , .Explicit)
        : return true
        
    case (.Custom(let left)
        , .Custom(let right))
        where left == right
        : return true
        
    case (.Standard(let left)
        , .Standard(let right))
        where left == right
        : return true
        
    case (.URI(let left)
        , .URI(let right))
        where left == right
        : return true
        
    case (.HandledCustom(let leftHandler , let leftName)
        , .HandledCustom(let rightHandler, let rightName))
        where leftHandler == rightHandler
            && leftName == rightName
        : return true
        
    default:
        return false
    }
}


extension Tag {
    
    static func resolve(tag: String, node: Node) -> Tag {
        if tag.isEmpty {
            if node is Node.Sequence { return .Standard(.seq) }
            if node is Node.Mapping  { return .Standard(.map) }
            return .None
        }
        if tag == "!" {
            if node is Node.Scalar { return .Standard(.str) }
            if node is Node.Sequence { return .Standard(.seq) }
            if node is Node.Mapping { return .Standard(.map) }
            return .Explicit // Should not reach this.
        }
        let prefix = Tag.Standardized.prefix
        if tag.hasPrefix("!!") {
            let name = tag.substring(from: 2)
            guard let standardized = Standardized(rawValue: name)
                else { return .URI(prefix + name) }
            return .Standard(standardized)
        }
        if tag.hasPrefix("!") {
            let name = tag.substring(from: 1)
            return .Custom(name)
        }
        if tag.hasPrefix(prefix) {
            let name = tag.substring(from: prefix.characters.count)
            guard let standardized = Standardized(rawValue: name)
                else { return .URI(prefix + name) }
            return .Standard(standardized)
        }
        return .URI(tag)
    }
    
}

