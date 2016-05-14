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
public struct Tag {
    public var handle: String = ""
    public var prefix: String = ""
    
    public struct Directive {
        public var handle: String = ""
        public var prefix: String = ""
    }
}

