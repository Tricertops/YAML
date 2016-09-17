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
    
    static func from(e: Event) -> yaml_event_t {
        var event = yaml_event_t()
        switch e {
            
        case .StreamStart:
            yaml_stream_start_event_initialize(&event, YAML_UTF8_ENCODING)
            
        case .StreamEnd:
            yaml_stream_end_event_initialize(&event)
            
        case .DocumentStart(let document):
            var version = yaml_version_directive_t(major: 1, minor: 1)
            //TODO: Convert tag directives to buffer.
            let tagStart: UnsafeMutablePointer<yaml_tag_directive_t> = nil
            let tagEnd: UnsafeMutablePointer<yaml_tag_directive_t> = nil
            
            withUnsafeMutablePointer(&version) {
                version in
                
                let pointer = document.hasVersion ? version : nil
                yaml_document_start_event_initialize(&event, pointer, tagStart, tagEnd, Int32(document.isImplicit))
            }
            
        case .DocumentEnd(let isImplicit):
            yaml_document_end_event_initialize(&event, Int32(isImplicit))
            
        case .Alias(let anchor):
            anchor.withMutableCString { pointer in
                yaml_alias_event_initialize(&event, pointer)
            }
            
        case .Scalar(let scalar):
            let isTagImplicit = true //TODO: Test
            
            scalar.anchor.withMutableCString { anchor in
                scalar.tag.withMutableCString { tag in
                    scalar.content.withMutableCString { content in
                        let optionalAnchor = (scalar.anchor.isEmpty ? nil : anchor)
                        yaml_scalar_event_initialize(&event, optionalAnchor, tag,
                            content, Int32(scalar.content.utf8.count),
                            Int32(isTagImplicit), Int32(isTagImplicit), .from(scalar.style))
                    }
                }
            }
            
        case .SequenceStart(let sequence):
            let isTagImplicit = true //TODO: Test
            
            sequence.anchor.withMutableCString { anchor in
                sequence.tag.withMutableCString { tag in
                    yaml_sequence_start_event_initialize(&event, anchor, tag, Int32(isTagImplicit), .from(sequence.style))
                }
            }
            
        case .SequenceEnd:
            yaml_sequence_end_event_initialize(&event)
            
        case .MappingStart(let mapping):
            let isTagImplicit = true //TODO: Test
            
            mapping.anchor.withMutableCString { anchor in
                mapping.tag.withMutableCString { tag in
                    yaml_mapping_start_event_initialize(&event, anchor, tag, Int32(isTagImplicit), .from(mapping.style))
                }
            }
            
        case .MappingEnd:
            yaml_mapping_end_event_initialize(&event)
            
        }
        return event
    }
    
}


extension yaml_scalar_style_t {
    
    static func from(style: Node.Scalar.Style) -> yaml_scalar_style_t {
        switch style {
        case .Plain: return YAML_PLAIN_SCALAR_STYLE
        case .SingleQuoted: return YAML_SINGLE_QUOTED_SCALAR_STYLE
        case .DoubleQuoted: return YAML_DOUBLE_QUOTED_SCALAR_STYLE
        case .Folded: return YAML_FOLDED_SCALAR_STYLE
        case .Literal: return YAML_LITERAL_SCALAR_STYLE
        }
    }
    
}


extension yaml_sequence_style_t {
    
    static func from(style: Node.Sequence.Style) -> yaml_sequence_style_t {
        switch style {
        case .Block: return YAML_BLOCK_SEQUENCE_STYLE
        case .Flow: return YAML_FLOW_SEQUENCE_STYLE
        }
    }
    
}


extension yaml_mapping_style_t {
    
    static func from(style: Node.Mapping.Style) -> yaml_mapping_style_t {
        switch style {
        case .Block: return YAML_BLOCK_MAPPING_STYLE
        case .Flow: return YAML_FLOW_MAPPING_STYLE
        }
    }
    
}

