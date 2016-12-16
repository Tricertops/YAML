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
}

