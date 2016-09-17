//
//  Event.swift
//  YAML.framework
//
//  Created by Martin Kiss on 29 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



enum Event {
    case streamStart
    case streamEnd
    case documentStart(hasVersion: Bool, tags: [Tag.Directive], isImplicit: Bool)
    case documentEnd(isImplicit: Bool)
    case alias(anchor: String)
    case scalar(anchor: String, tag: String, content: String, style: Node.Scalar.Style)
    case sequenceStart(anchor: String, tag: String, style: Node.Sequence.Style)
    case sequenceEnd
    case mappingStart(anchor: String, tag: String, style: Node.Mapping.Style)
    case mappingEnd
}

