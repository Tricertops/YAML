//
//  Parser_Tests.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//

import XCTest
import YAML


class Parser_Tests: XCTestCase {
    
    func test_stream_simple() {
        let string = self.file("stream_simple")
        let parser = Parser(string: string)
        XCTAssertEqual(parser.string, string)
        XCTAssertNil(parser.error)
        
        XCTAssertNotNil(parser.stream)
        guard let stream = parser.stream else { return }
        
        XCTAssertFalse(stream.hasVersion)
        XCTAssertTrue(stream.tags.isEmpty)
        XCTAssertFalse(stream.hasStartMark)
        XCTAssertEqual(stream.documents.count, 1)
        XCTAssertFalse(stream.hasSeparators)
        XCTAssertFalse(stream.hasEndMark)
        
        let document = stream.documents[0]
        XCTAssertTrue(document is Scalar)
        guard let scalar = document as? Scalar else { return }
        
        XCTAssertEqual(scalar.content, "Hello, YAML!")
    }
    
}

