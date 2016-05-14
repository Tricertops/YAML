//
//  Emittable.swift
//  YAML.framework
//
//  Created by Martin Kiss on 14 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



protocol Emittable: AnyObject { }


extension Stream: Emittable { }
extension Scalar: Emittable { }
extension Sequence: Emittable { }
extension Mapping: Emittable { }
