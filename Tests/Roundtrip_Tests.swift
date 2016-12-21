//
//  Roundtrip_Tests.swift
//  YAML
//
//  Created by Martin Kiss on 20.12.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//

import XCTest
import YAML


class Roundtrip_Tests: XCTestCase {
    
    func test_website() {
        let source = self.file(dir: "parsed", "website")
        let sample = self.file(dir: "emitted", "website")
        
        let stream = Parser(string: source).stream!
        let result = try! Emitter().emit(stream)
        
        XCTAssertEqual(sample, result)
        
        let stream2 = Parser(string: result).stream!
        let result2 = try! Emitter().emit(stream2)
        XCTAssertEqual(result, result2)
    }
    
}

