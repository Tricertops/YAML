//
//  Anchor.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//


protocol Anchorable: AnyObject {
    var anchor: String? { get set }
}


extension Anchorable {
    var anchor: String? {
        get { return nil }
        set { }
    }
}

