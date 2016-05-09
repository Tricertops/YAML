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


public class Stream: Parsed, Emittable {
    
    var documents: [Document] = []
    
    var explicitEnd: Bool = false
    
}

