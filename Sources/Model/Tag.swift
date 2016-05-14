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



//TODO: Enum to handle .Verbatim .BuiltIn .UserDefined and maybe .Implicit?
struct Tag {
    var handle: String = ""
    var suffix: String = ""
    
    struct Directive {
        var handle: String = ""
        var prefix: String = ""
    }
}


protocol Taggable {
    var tag: Tag? { get set }
}


