//
//  YAML_Tests.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//

import XCTest



extension XCTestCase {
    
    var projectURL: NSURL {
        let path = NSBundle(forClass: self.dynamicType).objectForInfoDictionaryKey("YAMLProjectPath") as! String
        return NSURL(fileURLWithPath: path)
    }
    
    var testsURL: NSURL {
        return self.projectURL.URLByAppendingPathComponent("Tests", isDirectory: true)
    }
    
    func URLForFile(name: String) -> NSURL {
        return self.testsURL.URLByAppendingPathComponent(name + ".yaml", isDirectory: false)
    }
    
    func file(name: String) -> String {
        return (try? String(contentsOfURL: self.URLForFile(name))) ?? ""
    }
    
}

