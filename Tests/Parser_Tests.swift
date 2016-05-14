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
        
        guard let scalar = stream.documents[0] as? Node.Scalar else { XCTFail(); return }
        
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
            guard let scalar = document as? Node.Scalar else { XCTFail(); return }
            
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
            guard let sequence1 = stream.documents[0] as? Node.Sequence else { XCTFail(); return }
            XCTAssertEqual(sequence1.count, 4)
            XCTAssertEqual(sequence1.style, .Block)
            XCTAssertTrue(sequence1[1] === sequence1[3])
        }
        do {
            guard let sequence2 = stream.documents[1] as? Node.Sequence else { XCTFail(); return }
            XCTAssertEqual(sequence2.count, 4)
            XCTAssertEqual(sequence2.style, .Flow)
            XCTAssertTrue(sequence2[1] === sequence2[3])
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
        
        guard let mapping = stream.documents[0] as? Node.Mapping else { XCTFail(); return }
        XCTAssertEqual(mapping.count, 6)
        XCTAssertEqual(mapping.style, .Block)
    }
    
    func test_scalar() {
        let string = self.file("scalar")
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
        
        guard let mapping = stream.documents[0] as? Node.Mapping else { XCTFail(); return }
        
        guard let plain = mapping["plain"] as? Node.Scalar else { XCTFail(); return }
        XCTAssertEqual(plain.style, .Plain)
        
        guard let singleQuoted = mapping["single quoted"] as? Node.Scalar else { XCTFail(); return }
        XCTAssertEqual(singleQuoted.style, .SingleQuoted)
        XCTAssertFalse(singleQuoted.content.containsString("\u{27}")) // APOSTROPHE
        
        guard let doubleQuoted = mapping["double quoted"] as? Node.Scalar else { XCTFail(); return }
        XCTAssertEqual(doubleQuoted.style, .DoubleQuoted)
        XCTAssertFalse(doubleQuoted.content.containsString("\u{22}")) // QUOTATION MARK
        
        guard let folded = mapping["folded"] as? Node.Scalar else { XCTFail(); return }
        XCTAssertEqual(folded.style, .Folded)
        let prelast = folded.content.endIndex.predecessor() // Ends with newline.
        XCTAssertFalse(folded.content.substringToIndex(prelast).containsString("\n"))
        
        guard let literal = mapping["literal"] as? Node.Scalar else { XCTFail(); return }
        XCTAssertEqual(literal.style, .Literal)
        XCTAssertTrue(literal.content.containsString("\n"))
    }
    
}

