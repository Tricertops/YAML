//
//  Parser+Event.swift
//  YAML.framework
//
//  Created by Martin Kiss on 14 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



extension Parser {
    
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
    
}


extension Parser.Event {
    
    static func from(event: yaml_event_t) -> Parser.Event? {
        switch event.type {
            
        case YAML_NO_EVENT:
            return nil
            
        case YAML_STREAM_START_EVENT:
            // Ignore: .encoding
            return .StreamStart
            
        case YAML_STREAM_END_EVENT:
            return .StreamEnd
            
        case YAML_DOCUMENT_START_EVENT:
            let document = event.data.document_start
            let version = document.version_directive
            
            let rawDirectives = Array(start: document.tag_directives.start, end: document.tag_directives.end)
            let directives = rawDirectives.map {
                Tag.Directive(handle: String($0.handle), URI: String($0.prefix))
            }
            return .DocumentStart(
                hasVersion: (version != nil),
                tags: directives,
                isImplicit: (document.implicit != 0))
            
        case YAML_DOCUMENT_END_EVENT:
            let document = event.data.document_end
            return .DocumentEnd(isImplicit: (document.implicit != 0))
            
        case YAML_ALIAS_EVENT:
            let alias = event.data.alias
            return .Alias(anchor: String(alias.anchor))
            
        case YAML_SCALAR_EVENT:
            let scalar = event.data.scalar
            //TODO: .plain_implicit
            //TODO: .quoted_implicit
            return .Scalar(
                anchor: String(scalar.anchor),
                tag: String(scalar.tag),
                content: String(scalar.value),
                style: .from(scalar.style))
            
        case YAML_SEQUENCE_START_EVENT:
            let sequence = event.data.sequence_start
            //TODO: .implicit
            return .SequenceStart(
                anchor: String(sequence.anchor),
                tag: String(sequence.tag),
                style: .from(sequence.style))
            
        case YAML_SEQUENCE_END_EVENT:
            return .SequenceEnd
            
        case YAML_MAPPING_START_EVENT:
            let mapping = event.data.mapping_start
            //TODO: .implicit
            return .MappingStart(
                anchor: String(mapping.anchor),
                tag: String(mapping.tag),
                style: .from(mapping.style))
            
        case YAML_MAPPING_END_EVENT:
            return .MappingEnd
            
        default:
            return nil
        }
    }
}


extension Node.Scalar.Style {
    
    static func from(style: yaml_scalar_style_t) -> Node.Scalar.Style {
        switch style {
        case YAML_SINGLE_QUOTED_SCALAR_STYLE: return .SingleQuoted
        case YAML_DOUBLE_QUOTED_SCALAR_STYLE: return .DoubleQuoted
        case YAML_FOLDED_SCALAR_STYLE: return .Folded
        case YAML_LITERAL_SCALAR_STYLE: return .Literal
        default: return .Plain // ANY, PLAIN
        }
    }
    
}


extension Node.Sequence.Style {
    
    static func from(style: yaml_sequence_style_t) -> Node.Sequence.Style {
        switch style {
        case YAML_FLOW_SEQUENCE_STYLE: return .Flow
        default: return .Block // ANY, BLOCK
        }
    }
    
}


extension Node.Mapping.Style {
    
    static func from(style: yaml_mapping_style_t) -> Node.Mapping.Style {
        switch style {
        case YAML_FLOW_MAPPING_STYLE: return .Flow
        default: return .Block // ANY, BLOCK
        }
    }
    
}

