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
    var explicitVersion: Bool = false
    
    /// List of tag directives preceding the documents.
    var tags: [Tag.Directive] = []
    
    /// Documents contained in the stream.
    var documents: [Document] = []
    
    /// Whether the stream has explicit `...` mark at the end.
    var explicitEnd: Bool = false
    
}


/// Object that can be placed in a stream.
protocol Document { }

extension Scalar: Document { }
extension Sequence: Document { }
extension Mapping: Document { }

