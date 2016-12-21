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
    
    var subdirectory: String {
        return ""
    }
    
    func URLForFile(dir: String = "", _ name: String) -> URL {
        var directoryURL = self.testsURL
        let subdirectory = dir.isEmpty ? self.subdirectory : dir
        directoryURL = directoryURL.appendingPathComponent(subdirectory, isDirectory: true)
        return directoryURL.appendingPathComponent(name + ".yaml", isDirectory: false)
    }
    
    func file(dir: String = "", _ name: String) -> String {
        return (try? String(contentsOf: self.URLForFile(dir: dir, name))) ?? ""
    }
    
}

