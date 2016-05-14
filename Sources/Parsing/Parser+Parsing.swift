//
//  Parser+Parsing.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



extension Parser {
    
    typealias Result = (stream: Stream?, error: ErrorType?, lookup: Lookup)
    
    static func parse(string: String) -> Result {
        var internal_parser = Internal()
        do {
            try internal_parser.setup(string)
            defer { internal_parser.cleanup() }
            
            while internal_parser.hasNextEvent {
                try internal_parser.processNextEvent()
            }
        }
        catch {
            return (nil, error, [:])
        }
        return (internal_parser.stream, nil, internal_parser.lookup)
    }
    
}


extension Parser {
    
    struct Internal {
        
        var stream: Stream?
        var lookup: Lookup = [:]
        
        var parser = yaml_parser_t()
        var hasNextEvent: Bool = true
        
        var anchors: [String: Node] = [:]
        var stack: [Node] = []
        var mappingKey: Node?
        
        mutating func setup(string: String) throws {
            yaml_parser_initialize(&parser)
            try parser.checkError()
            yaml_parser_set_input_string(&parser, string, string.c_length)
        }
        
        mutating func cleanup() {
            if Parser.Error(parser) != nil {
                stream = nil
                lookup = [:]
                hasNextEvent = false
            }
            yaml_parser_delete(&parser)
            parser = yaml_parser_t() // Clear.
        }
        
        mutating func loadNextEvent() throws -> Event? {
            var yaml_event = yaml_event_t()
            yaml_parser_parse(&parser, &yaml_event)
            let event = Event.from(yaml_event)
            hasNextEvent = (event != nil)
            try parser.checkError()
            return event
        }
        
        mutating func processNextEvent() throws {
            guard let event = try loadNextEvent() else {
                return
            }
            switch event {
                
            case .StreamStart:
                assert(stream == nil, "Already has Stream.")
                stream = Stream()
                
            case .StreamEnd:
                assert(stream != nil, "No Stream.")
                
            case .DocumentStart(let hasVersion, let tags, let isImplicit):
                guard let stream = self.stream else { fatalError("No Stream.") }
                
                let isFirst = stream.documents.isEmpty
                if isFirst {
                    stream.hasVersion = hasVersion
                    stream.tags = tags
                    stream.prefersStartMark = !isImplicit
                }
                
            case .DocumentEnd(let isImplicit):
                stream?.hasEndMark = !isImplicit
                anchors = [:] // Reset anchors.
                
            case .Alias(let anchor):
                guard let node = self.anchors[anchor] else { fatalError("No node for anchor “\(anchor)”") }
                addNode(node)
                
            case .Scalar(let anchor, let tag, let content, let style):
                let scalar = Node.Scalar()
                scalar.anchor = anchor
                scalar.tag = tag
                scalar.content = content
                scalar.style = style
                addNode(scalar)
                
            case .SequenceStart(let anchor, let tag, let style):
                let sequence = Node.Sequence()
                sequence.anchor = anchor
                sequence.tag = tag
                sequence.style = style
                addNode(sequence)
                stack.append(sequence)
                
            case .SequenceEnd:
                let last = self.stack.popLast()
                assert(last is Node.Sequence, "Expected Sequence node.")
                
            case .MappingStart(let anchor, let tag, let style):
                let mapping = Node.Mapping()
                mapping.anchor = anchor
                mapping.tag = tag
                mapping.style = style
                addNode(mapping)
                stack.append(mapping)
                
            case .MappingEnd:
                let last = self.stack.popLast()
                assert(last is Node.Mapping, "Expected Mapping node.")
            }
            
        }
        
        mutating func addNode(node: Node) {
            guard let stream = self.stream else { fatalError("No Stream.") }
            
            if stack.isEmpty {
                stream.documents.append(node)
            }
            else if let sequence = stack.last as? Node.Sequence {
                sequence.append(node)
            }
            else if let mapping = stack.last as? Node.Mapping {
                if let key = mappingKey {
                    mapping.append(key: key, value: node)
                    mappingKey = nil
                }
                else {
                    mappingKey = node
                }
            }
            else {
                fatalError("Unexpected node in stack: \(stack.last)")
            }
            
            if let anchor = node.anchor {
                self.anchors[anchor] = node
            }
        }
        
    }
    
}


