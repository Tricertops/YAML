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



extension Event {
    
    static func from(_ event: yaml_event_t) -> Event? {
        switch event.type {
            
        case YAML_NO_EVENT:
            return nil
            
        case YAML_STREAM_START_EVENT:
            // Ignore: .encoding
            return .streamStart
            
        case YAML_STREAM_END_EVENT:
            return .streamEnd
            
        case YAML_DOCUMENT_START_EVENT:
            let document = event.data.document_start
            let version = document.version_directive
            
            let rawDirectives = Array(start: document.tag_directives.start, end: document.tag_directives.end)
            let directives = rawDirectives.map {
                Tag.Directive(handle: String($0.handle), URI: String($0.prefix))
            }
            return .documentStart(
                hasVersion: (version != nil),
                tags: directives,
                isImplicit: (document.implicit != 0))
            
        case YAML_DOCUMENT_END_EVENT:
            let document = event.data.document_end
            return .documentEnd(isImplicit: (document.implicit != 0))
            
        case YAML_ALIAS_EVENT:
            let alias = event.data.alias
            return .alias(anchor: String(alias.anchor))
            
        case YAML_SCALAR_EVENT:
            let scalar = event.data.scalar
            return .scalar(
                anchor: String(scalar.anchor),
                tag: String(scalar.tag),
                content: String(scalar.value),
                style: .from(scalar.style))
            
        case YAML_SEQUENCE_START_EVENT:
            let sequence = event.data.sequence_start
            return .sequenceStart(
                anchor: String(sequence.anchor),
                tag: String(sequence.tag),
                style: .from(sequence.style))
            
        case YAML_SEQUENCE_END_EVENT:
            return .sequenceEnd
            
        case YAML_MAPPING_START_EVENT:
            let mapping = event.data.mapping_start
            return .mappingStart(
                anchor: String(mapping.anchor),
                tag: String(mapping.tag),
                style: .from(mapping.style))
            
        case YAML_MAPPING_END_EVENT:
            return .mappingEnd
            
        default:
            return nil
        }
    }
}


extension Node.Scalar.Style {
    
    static func from(_ style: yaml_scalar_style_t) -> Node.Scalar.Style {
        switch style {
        case YAML_SINGLE_QUOTED_SCALAR_STYLE: return .singleQuoted
        case YAML_DOUBLE_QUOTED_SCALAR_STYLE: return .doubleQuoted
        case YAML_FOLDED_SCALAR_STYLE: return .folded
        case YAML_LITERAL_SCALAR_STYLE: return .literal
        default: return .plain // ANY, PLAIN
        }
    }
    
}


extension Node.Sequence.Style {
    
    static func from(_ style: yaml_sequence_style_t) -> Node.Sequence.Style {
        switch style {
        case YAML_FLOW_SEQUENCE_STYLE: return .flow
        default: return .block // ANY, BLOCK
        }
    }
    
}


extension Node.Mapping.Style {
    
    static func from(_ style: yaml_mapping_style_t) -> Node.Mapping.Style {
        switch style {
        case YAML_FLOW_MAPPING_STYLE: return .flow
        default: return .block // ANY, BLOCK
        }
    }
    
}

