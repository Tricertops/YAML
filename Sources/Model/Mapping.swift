//
//  Mapping.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



class Mapping: Taggable, Anchorable {
    
    var tag: Tag?
    
    var anchor: String?
    
    var pairs: [(Nestable, Nestable)] = []
    
    var style: Style? = .Auto
    
}


extension Mapping {
    
    enum Style {
        case Block
        case Flow
        
        static let Auto: Style? = nil
    }
    
}


