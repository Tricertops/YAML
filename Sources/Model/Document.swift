//
//  Document.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//


class Document: Markable, Emittable {
    
    struct Version {
        var major: Int = 1
        var minor: Int = 1
        static let Unspecified: Version? = nil
        static let Default = Version(major: 1, minor: 1)
    }
    var version: Version? = .Unspecified
    
    var tags: [Tag.Directive] = []
    
    var explicitStart: Bool = true
    let startToken: Markable? = nil
    let endToken: Markable? = nil
    
    var root: Node? = nil
    
}

