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
        let stream = Stream()
        stream.hasVersion = true
        stream.prefersStartMark = true
        stream.hasEndMark = true
        stream.documents = [
            Node.Scalar(),
            Node.Scalar(),
            Node.Scalar(),
        ]
        
        let emitter = Emitter()
        do {
            let string = try emitter.emit(stream)
            XCTAssertNotNil(string)
        }
        catch {
            XCTAssertNil(error)
        }
    }

}

