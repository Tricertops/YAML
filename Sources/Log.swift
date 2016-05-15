//
//  Log.swift
//  YAML.framework
//
//  Created by Martin Kiss on 9 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//


func log(debug message: String) {
    #if debug
        print("YAML Debug: " + message)
    #endif
}


func log(notice message: String) {
    print("YAML: " + message)
}


func log(warning message: String) {
    print("YAML Warning: " + message)
}

