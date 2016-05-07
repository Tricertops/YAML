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


class Mapping: Node, Taggable, Anchorable, Markable, Emittable {
    
    var pairs: [(Node, Node)] = []
    
    enum Style {
        case Block
        case Flow
        static let Auto: Style? = nil
    }
    var style: Style? = .Auto
    
    let startToken: Markable? = nil
    let endToken: Markable? = nil
    
}


