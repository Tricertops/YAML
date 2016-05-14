//
//  Stream.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//


/// Represents a YAML file parsed using Parser or constructed programatically for Emitter.
public class Stream {
    
    /// Whether the stream has explicit `%YAML 1.1` at the beginning.
    public var hasVersion: Bool = false
    
    /// List of tag directives preceding the documents.
    public var tags: [Tag.Directive] = []
    
    /// Whether the stream has explicit `---` mark at the beginning.
    public var hasStartMark: Bool = false
    
    /// Documents contained in the stream.
    public var documents: [Node] = []
    
    /// Whether the documents are delimited by `---` marks.
    /// - Note: This property is determined from other properties.
    public var hasSeparators: Bool {
        return hasVersion || !tags.isEmpty || documents.count > 0
    }
    
    /// Whether the stream has explicit `...` mark at the end.
    public var hasEndMark: Bool = false
    
}

