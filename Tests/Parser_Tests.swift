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
        
        guard let stream = parser.stream else { XCTFail(); return }
        
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
        
        guard let stream = parser.stream else { XCTFail(); return }
        
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
        
        guard let stream = parser.stream else { XCTFail(); return }
        
        XCTAssertFalse(stream.hasVersion)
        XCTAssertTrue(stream.tags.isEmpty)
        XCTAssertFalse(stream.hasStartMark)
        XCTAssertEqual(stream.documents.count, 3)
        XCTAssertFalse(stream.hasEndMark)
        
        do {
            guard let sequence1 = stream.documents[0] as? Node.Sequence else { XCTFail(); return }
            XCTAssertEqual(sequence1.count, 4)
            XCTAssertEqual(sequence1.style, .block)
            XCTAssertTrue(sequence1[1] === sequence1[3])
        }
        do {
            guard let sequence2 = stream.documents[1] as? Node.Sequence else { XCTFail(); return }
            XCTAssertEqual(sequence2.count, 4)
            XCTAssertEqual(sequence2.style, .flow)
            XCTAssertTrue(sequence2[1] === sequence2[3])
        }
    }
    
    func test_mapping() {
        let string = self.file("mapping")
        let parser = Parser(string: string)
        XCTAssertEqual(parser.string, string)
        XCTAssertNil(parser.error)
        
        guard let stream = parser.stream else { XCTFail(); return }
        
        XCTAssertFalse(stream.hasVersion)
        XCTAssertTrue(stream.tags.isEmpty)
        XCTAssertFalse(stream.hasStartMark)
        XCTAssertEqual(stream.documents.count, 1)
        XCTAssertFalse(stream.hasEndMark)
        
        guard let mapping = stream.documents[0] as? Node.Mapping else { XCTFail(); return }
        XCTAssertEqual(mapping.count, 6)
        XCTAssertEqual(mapping.style, .block)
    }
    
    func test_scalar() {
        let string = self.file("scalar")
        let parser = Parser(string: string)
        XCTAssertEqual(parser.string, string)
        XCTAssertNil(parser.error)
        
        guard let stream = parser.stream else { XCTFail(); return }
        
        XCTAssertFalse(stream.hasVersion)
        XCTAssertTrue(stream.tags.isEmpty)
        XCTAssertFalse(stream.hasStartMark)
        XCTAssertEqual(stream.documents.count, 1)
        XCTAssertFalse(stream.hasEndMark)
        
        guard let mapping = stream.documents[0] as? Node.Mapping else { XCTFail(); return }
        
        guard let plain = mapping["plain"] as? Node.Scalar else { XCTFail(); return }
        XCTAssertEqual(plain.style, .plain)
        
        guard let singleQuoted = mapping["single quoted"] as? Node.Scalar else { XCTFail(); return }
        XCTAssertEqual(singleQuoted.style, .singleQuoted)
        XCTAssertFalse(singleQuoted.content.contains("\u{27}")) // APOSTROPHE
        
        guard let doubleQuoted = mapping["double quoted"] as? Node.Scalar else { XCTFail(); return }
        XCTAssertEqual(doubleQuoted.style, .doubleQuoted)
        XCTAssertFalse(doubleQuoted.content.contains("\u{22}")) // QUOTATION MARK
        
        guard let folded = mapping["folded"] as? Node.Scalar else { XCTFail(); return }
        XCTAssertEqual(folded.style, .folded)
        let prelast = folded.content.characters.index(before: folded.content.endIndex) // Ends with newline.
        XCTAssertFalse(folded.content.substring(to: prelast).contains("\n"))
        
        guard let literal = mapping["literal"] as? Node.Scalar else { XCTFail(); return }
        XCTAssertEqual(literal.style, .literal)
        XCTAssertTrue(literal.content.contains("\n"))
    }
    
    func test_marks() {
        let string = self.file("marks")
        let parser = Parser(string: string)
        XCTAssertEqual(parser.string, string)
        XCTAssertNil(parser.error)
        
        guard let stream = parser.stream else { XCTFail(); return }
        guard let mapping = stream.documents[0] as? Node.Mapping else { XCTFail(); return }
        
        guard let rangeMapping = parser.rangeOf(mapping) else { XCTFail(); return }
        XCTAssertEqual(rangeMapping.start.location, 29)
        XCTAssertEqual(rangeMapping.end.location, 62)
        
        guard let rangeKey1 = parser.rangeOf(mapping[0].key) else { XCTFail(); return }
        XCTAssertEqual(rangeKey1.start.location, 29)
        XCTAssertEqual(rangeKey1.end.location, 32)
        
        guard let rangeValue1 = parser.rangeOf(mapping[0].value) else { XCTFail(); return }
        XCTAssertEqual(rangeValue1.start.location, 34)
        XCTAssertEqual(rangeValue1.end.location, 39)
        
        guard let rangeKey2 = parser.rangeOf(mapping[1].key) else { XCTFail(); return }
        XCTAssertEqual(rangeKey2.start.location, 40)
        XCTAssertEqual(rangeKey2.end.location, 48)
        
        guard let rangeValue2 = parser.rangeOf(mapping[1].value) else { XCTFail(); return }
        XCTAssertEqual(rangeValue2.start.location, 52)
        XCTAssertEqual(rangeValue2.end.location, 62)
    }
    
    func test_tags() {
        let string = self.file("tags")
        let parser = Parser(string: string)
        XCTAssertEqual(parser.string, string)
        XCTAssertNil(parser.error)
        
        let URI = "tag:tricertops.com,2016:"
        
        guard let stream = parser.stream else { XCTFail(); return }
        XCTAssertEqual(stream.documents.count, 1)
        XCTAssertEqual(stream.tags.count, 1)
        XCTAssertEqual(stream.tags[0].handle, "!handle!")
        XCTAssertEqual(stream.tags[0].URI, URI)
        
        guard let sequence = stream.documents[0] as? Node.Sequence else { XCTFail(); return }
        XCTAssertEqual(sequence.count, 7)
        XCTAssertEqual(sequence.tag, Tag.standard(.seq))
        
        XCTAssertTrue(sequence[0].tag == Tag.none)
        XCTAssertTrue(sequence[1].tag == Tag.standard(.str))
        XCTAssertTrue(sequence[2].tag == Tag.custom("message"))
        XCTAssertTrue(sequence[3].tag == Tag.uri(URI + "message"))
        
        XCTAssertTrue(sequence[4].tag == Tag.standard(.str), "Explicit should be resolved.")
        XCTAssertTrue(sequence[5].tag == Tag.custom("message"), "Local verbatim tag should be resolved.")
        XCTAssertTrue(sequence[6].tag == Tag.uri(URI + "message"), "Named handle should be resolved.")
    }
    
    func test_alias() {
        let string = self.file("alias")
        let parser = Parser(string: string)
        XCTAssertEqual(parser.string, string)
        XCTAssertNil(parser.error)
        
        guard let stream = parser.stream else { XCTFail(); return }
        XCTAssertEqual(stream.documents.count, 3)
    }
    
}

