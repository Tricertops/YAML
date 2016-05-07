//
//  Stream.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//


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

