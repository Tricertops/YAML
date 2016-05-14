//
//  Parsable.swift
//  YAML.framework
//
//  Created by Martin Kiss on 14 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



/// Object that was created by Parser and can be mapped back to source string.
/// - SeeAlso: `Parser.rangeOf(_:)`, `Parser.stringOf(_:)`
public protocol Parsable: AnyObject { }


extension Stream: Parsable { }
extension Scalar: Parsable { }
extension Sequence: Parsable { }
extension Mapping: Parsable { }
extension Alias: Parsable { }

