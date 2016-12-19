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
    
    func test_sequence() {
        let stream = YAML.Stream()
        stream.documents = [
            Node.Sequence(items: [
                Node.Scalar(content: "Apple"),
                Node.Scalar(content: "Banana"),
                Node.Scalar(content: "Citrus"),
                ]),
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
                    ]),
                ], style: .block),
        ]
        
        let result = try! Emitter().emit(stream)
        let sample = self.file("sequence")
        XCTAssertEqual(sample, result, "")
    }
    
    func test_mapping() {
        let content = Node.Mapping(pairs: [
            (Node.Scalar(content: "model"), Node.Scalar(content: "MacBook Pro Retina")),
            (Node.Scalar(content: "size"), Node.Scalar(content: "13-inch")),
            (Node.Scalar(content: "year"), Node.Scalar(content: "2014")),
            (Node.Scalar(content: "processor"), Node.Mapping(pairs: [
                (Node.Scalar(content: "model"), Node.Scalar(content: "Intel Core i5")),
                (Node.Scalar(content: "speed"), Node.Scalar(content: "2.6 GHz")),
                ])),
            (Node.Scalar(content: "memory"), Node.Mapping(pairs: [
                (Node.Scalar(content: "size"), Node.Scalar(content: "8 GB")),
                (Node.Scalar(content: "speed"), Node.Scalar(content: "1600 MHz")),
                (Node.Scalar(content: "type"), Node.Scalar(content: "DDR3")),
                ], style: .block)),
            (Node.Scalar(content: "graphics"), Node.Mapping(pairs: [
                (Node.Scalar(content: "type"), Node.Scalar(content: "Intel Iris")),
                (Node.Scalar(content: "memory"), Node.Scalar(content: "1536 MB")),
                ], style: .flow)),
            ])
        
        let result = try! Emitter().emit(content)
        let sample = self.file("mapping")
        XCTAssertEqual(sample, result, "")
    }
    
    func test_scalar() {
        let content = Node.Mapping(pairs: [
            (Node.Scalar(content: "plain"), Node.Scalar(content: "Lorem ipsum dolor sit amet.", style: .plain)),
            (Node.Scalar(content: "single quoted"), Node.Scalar(content: "Lorem ipsum dolor sit amet.", style: .singleQuoted)),
            (Node.Scalar(content: "double quoted"), Node.Scalar(content: "Lorem ipsum dolor sit amet.", style: .doubleQuoted)),
            (Node.Scalar(content: "folded"), Node.Scalar(content: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore\nmagna aliqua.", style: .folded)),
            (Node.Scalar(content: "literal"), Node.Scalar(content: "Lorem ipsum dolor sit amet, consectetur adipisicing elit,\nsed do eiusmod tempor incididunt ut labore et dolore magna\naliqua.", style: .literal)),
            ])
        
        let result = try! Emitter().emit(content)
        let sample = self.file("scalar")
        XCTAssertEqual(sample, result, "")
    }
    
    func test_tags() {
        let content = Node.Sequence(items: [
            Node.Scalar(content: "None"),
            Node.Scalar(content: "Standard", tag: .standard(.str)),
            Node.Scalar(content: "Custom", tag: .custom("message")),
            Node.Scalar(content: "URI", tag: .uri("tag:full.tricertops.com,2016:message")),
            Node.Scalar(content: "ShortenedURI", tag: .uri("tag:tricertops.com,2016:message")),
            ])
        
        let stream = YAML.Stream()
        stream.tags = [Tag.Directive(handle: "handle", URI: "tag:tricertops.com,2016")]
        stream.documents = [content]
        stream.hasEndMark = true
        
        let result = try! Emitter().emit(stream)
        let sample = self.file("tags")
        XCTAssertEqual(sample, result, "")
    }
    
    func test_alias() {
        let A = Node.Scalar(content: "A", anchor: "a")
        let B = Node.Scalar(content: "B", anchor: "a")
        let C = Node.Scalar(content: "C", anchor: "b")
        let document1 = Node.Sequence(items: [A, B, C, B, C, B])
        
        let document2 = Node.Sequence()
        document2.anchor = "a"
        document2.append(document2)
        
        let document3 = Node.Mapping()
        document3.anchor = "a"
        document3.pairs.append((Node.Scalar(content: "key"), document3))
        
        let document4 = Node.Mapping()
        document4.anchor = "a"
        document4.pairs.append((document4, Node.Scalar(content: "value")))
        
        let stream = YAML.Stream(documents: [document1, document2, document3, document4])
        stream.prefersStartMark = true
        stream.hasEndMark = true
        let result = try! Emitter().emit(stream)
        let sample = self.file("alias")
        XCTAssertEqual(sample, result, "")
    }
    
    func test_generated_anchors() {
        let A = Node.Scalar(content: "A")
        let B = Node.Scalar(content: "B")
        let C = Node.Scalar(content: "C")
        let D = Node.Scalar(content: "D", anchor: "D")
        let E = Node.Scalar(content: "E", anchor: "E")
        
        let sequence = Node.Sequence()
        sequence.style = .flow
        sequence.anchor = "sequence"
        sequence.items = [A, sequence]
        let mapping = Node.Mapping()
        mapping.style = .flow
        mapping.anchor = "mapping"
        mapping.pairs = [(B, mapping)]
        
        let F = Node.Scalar(content: "F", anchor: "004")
        let G = Node.Scalar(content: "G")
        let H = Node.Scalar(content: "H", anchor: "004")
        
        let document = Node.Sequence(items: [
            A,B,C, C,A,B, D,E, C,
            sequence, mapping,
            F, G, G, H, F, H,
            ])
        
        let result = try! Emitter().emit(document)
        let sample = self.file("generated_anchors")
        XCTAssertEqual(sample, result, "")
    }
    
}

