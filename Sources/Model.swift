//
//  Node.swift
//  YAML.framework
//
//  Created by Martin Kiss on 1 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//

import Foundation


protocol Markable: AnyObject {
    
}

class Parser {
    
    init(string: String) { }
    init(file: String) { }
    
    func parse() throws { }
    
    let error: ErrorType? = nil
    let parsed: Stream? = nil
    
    struct Mark {
        let location: Int
        let line: Int
        let column: Int
        
        struct Range {
            let begin: Mark
            let end: Mark
            var location: Int { return begin.location }
            var length: Int { return end.location - location }
        }
    }
    func rangeOf(object: Markable) -> Mark.Range! {
        return nil
    }
    func stringOf(object: Markable) -> String? {
        return nil
    }
    
}


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
    }
    var automaticStyle = Style()
    var forcedStyle = Style()
    
    func emit(object: Emittable) throws -> String { return "" }
    func emit(object: Emittable, file: String) throws -> Bool { return true }
    
}


protocol Taggable {
    var tag: Tag? { get set }
    var isTagExplicit: Bool { get set }
}
extension Taggable {
    var tag: Tag? {
        get { return nil }
        set { }
    }
    var isTagExplicit: Bool {
        get { return false }
        set { }
    }
}


protocol Anchorable: AnyObject {
    var anchor: String? { get set }
}
extension Anchorable {
    var anchor: String? {
        get { return nil }
        set { }
    }
}


protocol Node {
    
}


class Stream: Markable, Emittable {
    
    enum Encoding {
        case UTF8
        case UTF16LittleEndian
        case UTF16BigEndian
    }
    var encoding: Encoding = .UTF8
    
    var documents: [Document] = []
    
    var explicitEnd: Bool = false
    let startToken: Markable? = nil
    let endToken: Markable? = nil
    
}


class Document: Markable, Emittable {
    
    struct Version {
        var major: Int = 1
        var minor: Int = 1
        static let Unspecified: Version? = nil
        static let Default = Version(major: 1, minor: 1)
    }
    var version: Version? = .Unspecified
    
    struct Tag {
        var handle: String = ""
        var prefix: String = ""
    }
    var tags: [Tag] = []
    
    var explicitStart: Bool = true
    let startToken: Markable? = nil
    let endToken: Markable? = nil
    
    var root: Node? = nil
    
}

class Alias: Node, Markable {
    var target: Anchorable? = nil
}

class Tag: Markable {
    var handle: String = ""
    var suffix: String = ""
}

class Scalar: Node, Taggable, Anchorable, Markable, Emittable {
    
    var content: String = ""
    
    enum Style {
        case Plain
        case SingleQuoted
        case DoubleQuoted
        case Literal
        case Folded
        static let Auto: Style? = nil
    }
    var style: Style? = .Auto
    
}

class Sequence: Node, Taggable, Anchorable, Markable, Emittable {
    
    var items: [Node] = []
    
    enum Style {
        case Block
        case Flow
        static let Auto: Style? = nil
    }
    var style: Style? = .Auto
    
    let startToken: Markable? = nil
    let endToken: Markable? = nil
    
}

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


