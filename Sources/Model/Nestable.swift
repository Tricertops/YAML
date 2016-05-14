//
//  Nestable.swift
//  YAML.framework
//
//  Created by Martin Kiss on 14 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



/// Object that can be nested in Sequence and Mapping.
protocol Nestable { }

extension Scalar: Nestable { }
extension Sequence: Nestable { }
extension Mapping: Nestable { }
extension Alias: Nestable { }

