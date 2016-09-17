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
    
    var projectURL: URL {
        let path = Bundle(for: type(of: self)).object(forInfoDictionaryKey: "YAMLProjectPath") as! String
        return URL(fileURLWithPath: path)
    }
    
    var testsURL: URL {
        return self.projectURL.appendingPathComponent("Tests", isDirectory: true)
    }
    
    func URLForFile(_ name: String) -> URL {
        return self.testsURL.appendingPathComponent(name + ".yaml", isDirectory: false)
    }
    
    func file(_ name: String) -> String {
        return (try? String(contentsOf: self.URLForFile(name))) ?? ""
    }
    
}

