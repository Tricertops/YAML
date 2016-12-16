//
//  Emitter_Tests.swift
//  YAML.framework
//
//  Created by Martin Kiss on 29 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//

import XCTest
import YAML


class Emitter_Tests: XCTestCase {

    override var subdirectory: String {
        return "emitted"
    }
    
    func test_empty_stream() {
        let string = try! Emitter().emit(YAML.Stream())
        XCTAssertTrue(string.isEmpty)
    }
    
    func test_stream_simple() {
        let emitter = Emitter()
        let content = Node.Scalar(content: "Hello, YAML!")
        let result = try! emitter.emit(content)
        
        let sample = self.file("stream_simple")
        XCTAssertEqual(sample, result)
    }
    
    func test_stream_multiple() {
        let stream = YAML.Stream()
        stream.hasVersion = true
        stream.prefersStartMark = true
        stream.hasEndMark = true
        stream.documents = [
            Node.Scalar(content: "Hello, YAML!"),
            Node.Scalar(content: "Hello, YAML!"),
            Node.Scalar(content: "Hello, YAML!"),
        ]
        // libyaml writes single scalar document as:
        // --- Hello, YAML!
        // I see no way to force the newline there.
        
        let result = try! Emitter().emit(stream)
        let sample = self.file("stream_multiple")
        XCTAssertEqual(sample, result, "")
    }
    
    func test_sequences() {
        let stream = YAML.Stream()
        stream.documents = [
            Node.Sequence(items: [
                Node.Scalar(content: "Apple"),
                Node.Scalar(content: "Banana"),
                Node.Scalar(content: "Citrus"),
                ], style: .block),
            Node.Sequence(items: [
                Node.Scalar(content: "Apple"),
                Node.Scalar(content: "Banana"),
                Node.Scalar(content: "Citrus"),
                ], style: .flow),
            Node.Sequence(items: [
                Node.Sequence(items: [
                    Node.Scalar(content: "Apple"),
                    Node.Scalar(content: "Banana"),
                    Node.Scalar(content: "Citrus"),
                    ], style: .flow),
                Node.Sequence(items: [
                    Node.Scalar(content: "Apple"),
                    Node.Scalar(content: "Banana"),
                    Node.Scalar(content: "Citrus"),
                    ], style: .block),
                ], style: .block),
        ]
        
        let result = try! Emitter().emit(stream)
        let sample = self.file("sequence")
        XCTAssertEqual(sample, result, "")
    }
}

