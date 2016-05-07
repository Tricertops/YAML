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
    
    func test_init() {
        let string = self.file("sample.yaml")
        let parser = Parser(string: string)
        XCTAssertEqual(parser.string, string)
        XCTAssertNil(parser.stream, "We are not doing any parsing , yet.")
        XCTAssertNil(parser.error)
    }
    
}

