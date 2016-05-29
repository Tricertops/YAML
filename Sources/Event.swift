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
    case StreamStart
    case StreamEnd
    case DocumentStart(hasVersion: Bool, tags: [Tag.Directive], isImplicit: Bool)
    case DocumentEnd(isImplicit: Bool)
    case Alias(anchor: String)
    case Scalar(anchor: String, tag: String, content: String, style: Node.Scalar.Style)
    case SequenceStart(anchor: String, tag: String, style: Node.Sequence.Style)
    case SequenceEnd
    case MappingStart(anchor: String, tag: String, style: Node.Mapping.Style)
    case MappingEnd
}

