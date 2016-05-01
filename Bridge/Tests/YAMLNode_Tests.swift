//
//  YAMLNode_Tests.swift
//  YAML Bridge Tests
//
//  Created by Martin Kiss on 1 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//

import XCTest
import YAMLBridge


class YAMLNode_Tests: XCTestCase {

    var projectURL: NSURL {
        let path = NSBundle(forClass: self.dynamicType).objectForInfoDictionaryKey("YAMLProjectPath") as! String
        return NSURL(fileURLWithPath: path)
    }
    
    var testsURL: NSURL {
        return self.projectURL
            .URLByAppendingPathComponent("Bridge", isDirectory: true)
            .URLByAppendingPathComponent("Tests", isDirectory: true)
    }
    
    func URLForFile(name: String) -> NSURL {
        return self.testsURL.URLByAppendingPathComponent(name, isDirectory: false)
    }
    
    func test_reading() {
        let docs = YAMLNode.documentsFromFileURL(self.URLForFile("www.yaml"))
        XCTAssert(docs.count == 1)
    }
    
    func test_reusingNodes() {
        let docs = YAMLNode.documentsFromFileURL(self.URLForFile("reusing.yaml"))
        XCTAssert(docs.count == 1)
    }
    
}

