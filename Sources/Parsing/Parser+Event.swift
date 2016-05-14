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
        case Scalar(anchor: String?, tag: Tag?, content: String, style: Node.Scalar.Style)
        case SequenceStart(anchor: String?, tag: Tag?, style: Node.Sequence.Style)
        case SequenceEnd
        case MappingStart(anchor: String?, tag: Tag?, style: Node.Mapping.Style)
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
                Tag.Directive(handle: String($0.handle), prefix: String($0.prefix))
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
                tag: Tag(handle: String(scalar.tag), prefix: ""),
                content: String(scalar.value),
                style: .Plain)
            
        case YAML_SEQUENCE_START_EVENT:
            let sequence = event.data.sequence_start
            //TODO: .implicit
            return .SequenceStart(
                anchor: String(sequence.anchor),
                tag: Tag(handle: String(sequence.tag), prefix: ""),
                style: .Block)
            
        case YAML_SEQUENCE_END_EVENT:
            return .SequenceEnd
            
        case YAML_MAPPING_START_EVENT:
            let mapping = event.data.sequence_start
            //TODO: .implicit
            return .MappingStart(
                anchor: String(mapping.anchor),
                tag: Tag(handle: String(mapping.tag), prefix: ""),
                style: .Block)
            
        case YAML_MAPPING_END_EVENT:
            return .MappingEnd
            
        default:
            return nil
        }
    }
}


extension Parser.Event: CustomDebugStringConvertible {
    
    var debugDescription: String {
        switch self {
        case StreamStart: return "Stream:"
        case StreamEnd: return ":Stream"
        case DocumentStart(let hasVersion, let tags, let isImplicit):
            return "Document"
                + (isImplicit ? "" : "---")
                + (hasVersion ? " 1.1" : "")
                + (tags.isEmpty ? "" : " \(tags)")
                + ":"
        case DocumentEnd(let isImplicit):
            return ":Document"
                + (isImplicit ? "" : " ...")
        case Alias(let anchor): return "Alias: *\(anchor)"
        case Scalar(let anchor, let tag, let content, _):
            return "Scalar"
                + (anchor == nil || anchor!.isEmpty ? "" : " &" + anchor!)
                + (tag == nil || tag!.handle.isEmpty ? "" : " !" + tag!.handle)
                + ": " + content
        case SequenceStart(let anchor, let tag, _):
            return "Sequence"
                + (anchor == nil || anchor!.isEmpty ? "" : " &" + anchor!)
                + (tag == nil || tag!.handle.isEmpty ? "" : " !" + tag!.handle)
                + ":"
        case SequenceEnd: return ":Sequence"
        case MappingStart(let anchor, let tag, _):
            return "Mapping"
                + (anchor == nil || anchor!.isEmpty ? "" : " &" + anchor!)
                + (tag == nil || tag!.handle.isEmpty ? "" : " !" + tag!.handle)
                + ":"
        case MappingEnd: return ":Mapping"
        }
    }
    
}

