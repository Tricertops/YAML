//
//  Scalar.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



class Scalar: Taggable, Anchorable {
    
    var tag: Tag?
    
    var anchor: String?
    
    var content: String = ""
    
    var style: Style? = .Auto
    
}


extension Scalar {
    
    enum Style {
        case Plain
        case SingleQuoted
        case DoubleQuoted
        case Literal
        case Folded
        
        static let Auto: Style? = nil
    }
    
}

