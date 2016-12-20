//
//  Emitter+Event.swift
//  YAML.framework
//
//  Created by Martin Kiss on 29 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



extension yaml_event_t {
    
    static func from(_ e: Event) -> yaml_event_t {
        var event = yaml_event_t()
        switch e {
            
        case .streamStart:
            yaml_stream_start_event_initialize(&event, YAML_UTF8_ENCODING)
            
        case .streamEnd:
            yaml_stream_end_event_initialize(&event)
            
        case .documentStart(let document):
            var version = yaml_version_directive_t(major: 1, minor: 1)
            //TODO: Convert tag directives to buffer.
            let tagStart: UnsafeMutablePointer<yaml_tag_directive_t>? = nil
            let tagEnd: UnsafeMutablePointer<yaml_tag_directive_t>? = nil
            
            let _ = withUnsafeMutablePointer(to: &version) {
                versionRef in
                
                yaml_document_start_event_initialize(&event, (document.hasVersion ? versionRef : nil), tagStart, tagEnd, Int32(document.isImplicit))
            }
            
        case .documentEnd(let isImplicit):
            yaml_document_end_event_initialize(&event, Int32(isImplicit))
            
        case .alias(let anchor):
            let _ = anchor.withMutableCString { pointer in
                yaml_alias_event_initialize(&event, pointer)
            }
            
        case .scalar(let scalar):
            let isTagImplicit = scalar.tag.isEmpty
            
            let _ = scalar.anchor.withMutableCString { anchor in
                let _ = scalar.tag.withMutableCString { tag in
                    let _ = scalar.content.withMutableCString { content in
                        yaml_scalar_event_initialize(
                            &event,
                            (scalar.anchor.isEmpty ? nil : anchor),
                            tag,
                            content,
                            Int32(scalar.content.utf8.count),
                            Int32(isTagImplicit),
                            Int32(isTagImplicit),
                            .from(scalar.style))
                    }
                }
            }
            
        case .sequenceStart(let sequence):
            let isTagImplicit = sequence.tag.isEmpty
            
            let _ = sequence.anchor.withMutableCString { anchor in
                let _ = sequence.tag.withMutableCString { tag in
                    yaml_sequence_start_event_initialize(
                        &event,
                        (sequence.anchor.isEmpty ? nil : anchor),
                        tag,
                        Int32(isTagImplicit),
                        .from(sequence.style))
                }
            }
            
        case .sequenceEnd:
            yaml_sequence_end_event_initialize(&event)
            
        case .mappingStart(let mapping):
            let isTagImplicit = mapping.tag.isEmpty
            
            let _ = mapping.anchor.withMutableCString { anchor in
                let _ = mapping.tag.withMutableCString { tag in
                    yaml_mapping_start_event_initialize(
                        &event,
                        (mapping.anchor.isEmpty ? nil : anchor),
                        tag,
                        Int32(isTagImplicit),
                        .from(mapping.style))
                }
            }
            
        case .mappingEnd:
            yaml_mapping_end_event_initialize(&event)
            
        }
        return event
    }
    
}


extension yaml_scalar_style_t {
    
    static func from(_ style: Node.Scalar.Style) -> yaml_scalar_style_t {
        switch style {
        case .plain: return YAML_PLAIN_SCALAR_STYLE
        case .singleQuoted: return YAML_SINGLE_QUOTED_SCALAR_STYLE
        case .doubleQuoted: return YAML_DOUBLE_QUOTED_SCALAR_STYLE
        case .folded: return YAML_FOLDED_SCALAR_STYLE
        case .literal: return YAML_LITERAL_SCALAR_STYLE
        }
    }
    
}


extension yaml_sequence_style_t {
    
    static func from(_ style: Node.Sequence.Style) -> yaml_sequence_style_t {
        switch style {
        case .block: return YAML_BLOCK_SEQUENCE_STYLE
        case .flow: return YAML_FLOW_SEQUENCE_STYLE
        }
    }
    
}


extension yaml_mapping_style_t {
    
    static func from(_ style: Node.Mapping.Style) -> yaml_mapping_style_t {
        switch style {
        case .block: return YAML_BLOCK_MAPPING_STYLE
        case .flow: return YAML_FLOW_MAPPING_STYLE
        }
    }
    
}

