//
//  Tag.swift
//  YAML
//
//  Created by Martin Kiss on 7.5.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//


class Tag: Parsed {
    var handle: String = ""
    var suffix: String = ""
}


extension Tag {
    struct Directive {
        var handle: String = ""
        var prefix: String = ""
    }
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


