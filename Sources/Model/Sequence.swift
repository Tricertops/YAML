//
//  Sequence.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



class Sequence: Taggable, Anchorable {
    
    var tag: Tag?
    
    var anchor: String?
    
    var items: [Nestable] = []
    
    var style: Style? = .Auto
    
}


extension Sequence {
    
    enum Style {
        case Block
        case Flow
        
        static let Auto: Style? = nil
    }
    
}

