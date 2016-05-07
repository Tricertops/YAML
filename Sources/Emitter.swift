//
//  Emitter.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//


protocol Emittable: AnyObject {
    
}


class Emitter {
    
    init() { }
    
    var isCanonical: Bool = false
    var indentation: Int = 2
    var lineWidth: Int = 80
    var allowsUnicode: Bool = true
    
    enum LineBreaks: String {
        case Unix = "\n"
        case Windows = "\r\n"
        case ClassicMacOS = "\r"
    }
    var lineBreaks: LineBreaks = .Unix
    
    struct Style {
        var scalar: Scalar.Style? = nil
        var sequence: Sequence.Style? = nil
        var mapping: Mapping.Style? = nil
        
        static let None = Style()
        static let Default = Style(scalar: .Plain, sequence: .Block, mapping: .Block)
        static let JSON = Style(scalar: .DoubleQuoted, sequence: .Flow, mapping: .Flow)
    }
    var automaticStyle = Style.Default
    var forcedStyle = Style.None
    
    func emit(object: Emittable) throws -> String { return "" }
    func emit(object: Emittable, file: String) throws -> Bool { return true }
    
}

