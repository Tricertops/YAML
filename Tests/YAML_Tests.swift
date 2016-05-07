//
//  YAML_Tests.swift
//  YAML
//
//  Created by Martin Kiss on 7.5.16.
//  Copyright © 2016 Tricertops. All rights reserved.
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
        return self.testsURL.URLByAppendingPathComponent(name, isDirectory: false)
    }
    
    func file(name: String) -> String {
        return (try? String(contentsOfURL: self.URLForFile(name))) ?? ""
    }
    
}

