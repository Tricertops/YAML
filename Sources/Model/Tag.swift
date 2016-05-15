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
public enum Tag {
    
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
    case Standard(String)  // !!name
    
    /// Tag with fully resolved name that is not resolved further. Will be enclosed in “<>” and prefixed with “!”.
    case URI(String)  // !<content>
    
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

