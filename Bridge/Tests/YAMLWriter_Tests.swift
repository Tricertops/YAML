//
//  YAMLWriter_Tests.swift
//  YAML Bridge Tests
//
//  Created by Martin Kiss on 17 April 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//

import XCTest
import YAMLBridge


class YAMLWriter_Tests: XCTestCase {
    
    var fileURL: NSURL {
        let tempURL = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let randomURL = tempURL.URLByAppendingPathComponent(NSUUID().UUIDString, isDirectory: true)
        let fileURL = randomURL.URLByAppendingPathComponent("\(self.dynamicType).yaml", isDirectory: false)
        return fileURL
    }
    
    override func setUp() {
        super.setUp()
        NSFileManager.defaultManager().createFileAtPath(self.fileURL.path!, contents: nil, attributes: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        let _ = try? NSFileManager.defaultManager().removeItemAtURL(self.fileURL)
    }
    
    func test_Creating() {
        XCTAssertNotNil( YAMLWriter() )
        XCTAssertNotNil( YAMLWriter(fileURL: self.fileURL) )
        XCTAssertNotNil( YAMLWriter(fileHandle: NSFileHandle.fileHandleWithStandardOutput()) )
    }
    
    func test_CreatingWithInvalidURLs() {
        XCTAssertNil( YAMLWriter(fileURL: NSURL(string: "http://tricer.at/ops")!) )
        XCTAssertNil( YAMLWriter(fileURL: NSURL(fileURLWithPath: "/Not/Existing/Path")) )
    }
    
}

