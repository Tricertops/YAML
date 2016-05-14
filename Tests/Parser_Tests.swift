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
        XCTAssertFalse(stream.hasEndMark)
        
        let document = stream.documents[0]
        XCTAssertTrue(document is Node.Scalar)
        guard let scalar = document as? Node.Scalar else { return }
        
        XCTAssertEqual(scalar.content, "Hello, YAML!")
    }
    
    func test_stream_multiple() {
        let string = self.file("stream_multiple")
        let parser = Parser(string: string)
        XCTAssertEqual(parser.string, string)
        XCTAssertNil(parser.error)
        
        XCTAssertNotNil(parser.stream)
        guard let stream = parser.stream else { return }
        
        XCTAssertTrue(stream.hasVersion)
        XCTAssertTrue(stream.tags.isEmpty)
        XCTAssertTrue(stream.hasStartMark)
        XCTAssertEqual(stream.documents.count, 3)
        XCTAssertTrue(stream.hasEndMark)
        
        for document in stream.documents {
            XCTAssertTrue(document is Node.Scalar)
            guard let scalar = document as? Node.Scalar else { return }
            
            XCTAssertEqual(scalar.content, "Hello, YAML!")
        }
    }
    
    func test_sequence() {
        let string = self.file("sequence")
        let parser = Parser(string: string)
        XCTAssertEqual(parser.string, string)
        XCTAssertNil(parser.error)
        
        XCTAssertNotNil(parser.stream)
        guard let stream = parser.stream else { return }
        
        XCTAssertFalse(stream.hasVersion)
        XCTAssertTrue(stream.tags.isEmpty)
        XCTAssertFalse(stream.hasStartMark)
        XCTAssertEqual(stream.documents.count, 3)
        XCTAssertFalse(stream.hasEndMark)
        
        do {
            let document1 = stream.documents[0]
            XCTAssertTrue(document1 is Node.Sequence)
            guard let sequence1 = document1 as? Node.Sequence else { return }
            XCTAssertEqual(sequence1.items.count, 4)
            XCTAssertEqual(sequence1.style, .Block)
            XCTAssertTrue(sequence1.items[1] === sequence1.items[3])
        }
        do {
            let document2 = stream.documents[1]
            XCTAssertTrue(document2 is Node.Sequence)
            guard let sequence2 = document2 as? Node.Sequence else { return }
            XCTAssertEqual(sequence2.items.count, 4)
            XCTAssertEqual(sequence2.style, .Flow)
            XCTAssertTrue(sequence2.items[1] === sequence2.items[3])
        }
    }
    
    func test_mapping() {
        let string = self.file("mapping")
        let parser = Parser(string: string)
        XCTAssertEqual(parser.string, string)
        XCTAssertNil(parser.error)
        
        XCTAssertNotNil(parser.stream)
        guard let stream = parser.stream else { return }
        
        XCTAssertFalse(stream.hasVersion)
        XCTAssertTrue(stream.tags.isEmpty)
        XCTAssertFalse(stream.hasStartMark)
        XCTAssertEqual(stream.documents.count, 1)
        XCTAssertFalse(stream.hasEndMark)
        
        let document = stream.documents[0]
        XCTAssertTrue(document is Node.Mapping)
        guard let mapping = document as? Node.Mapping else { return }
        XCTAssertEqual(mapping.pairs.count, 6)
        XCTAssertEqual(mapping.style, .Block)
    }
    
}

