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
    
    /// Whether the stream *wants* explicit `---` mark at the beginning.
    /// - Note: In some cases the mark is required.
    /// - SeeAlso: `.hasStartMark`
    public var prefersStartMark: Bool = false
    
    /// Whether the stream *has* explicit `---` mark at the beginning.
    public var hasStartMark: Bool {
        return hasVersion || !tags.isEmpty || prefersStartMark
    }
    
    /// Documents contained in the stream.
    public var documents: [Node] = []
    
    /// Whether the stream has explicit `...` mark at the end.
    public var hasEndMark: Bool = false
    
    
    /// Creates a Stream with a list of document Nodes.
    convenience init(documents: [Node]) {
        self.init()
        self.documents = documents
    }
    
}

