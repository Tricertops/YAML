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
        return Internal().parse(string: string)
    }
    
    private class Internal {
        
        var stream: Stream?
        var lookup: Lookup = [:]
        
        var parser = yaml_parser_t()
        var hasNextEvent: Bool = true
        var anchors: [String: Node] = [:]
        var stack: [Node] = []
        var mappingKey: Node?
        
        func parse(string string: String) -> Result {
            do {
                try string.nulTerminatedUTF8.withUnsafeBufferPointer {
                    buffer in
                    // We do the parsing within this block, because the pointer is valid only here.
                    
                    try self.setup(buffer)
                    defer { self.cleanup() }
                    
                    while self.hasNextEvent {
                        try self.processNextEvent()
                    }
                }
            }
            catch {
                return (nil, error, [:])
            }
            return (self.stream, nil, self.lookup)
        }
        
        func setup(buffer: UnsafeBufferPointer<UTF8.CodeUnit>) throws {
            yaml_parser_initialize(&parser)
            try parser.checkError()
            
            let length = buffer.count - 1 // Ignore termination \0.
            yaml_parser_set_input_string(&parser, buffer.baseAddress, length)
        }
        
        func cleanup() {
            if Parser.Error(parser) != nil {
                stream = nil
                lookup = [:]
                hasNextEvent = false
            }
            yaml_parser_delete(&parser)
            parser = yaml_parser_t() // Clear.
        }
        
        func loadNext() throws -> (event: Event?, range: Mark.Range?) {
            var yaml_event = yaml_event_t()
            yaml_parser_parse(&parser, &yaml_event)
            defer {
                yaml_event_delete(&yaml_event)
            }
            let event = Event.from(yaml_event)
            hasNextEvent = (event != nil)
            try parser.checkError()
            
            if let event = event {
                let startMark = Mark(yaml_event.start_mark)
                let endMark = Mark(yaml_event.end_mark)
                return (event, startMark...endMark)
            }
            return (nil, nil)
        }
        
        func processNextEvent() throws {
            let next = try loadNext()
            guard let event = next.event else { return }
            guard let range = next.range else { return }
            
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
                scalar.content = content
                scalar.style = style
                scalar.tag = Tag.resolve(tag, node: scalar)
                addNode(scalar)
                addRange(range, node: scalar)
                
            case .SequenceStart(let anchor, let tag, let style):
                let sequence = Node.Sequence()
                sequence.anchor = anchor
                sequence.style = style
                sequence.tag = Tag.resolve(tag, node: sequence)
                addNode(sequence)
                addRange(range, node: sequence)
                stack.append(sequence)
                
            case .SequenceEnd:
                let last = self.stack.popLast()
                guard let sequence = last as? Node.Sequence else { fatalError("Expected Sequence node.") }
                addRange(range, node: sequence)
                
            case .MappingStart(let anchor, let tag, let style):
                let mapping = Node.Mapping()
                mapping.anchor = anchor
                mapping.style = style
                mapping.tag = Tag.resolve(tag, node: mapping)
                addNode(mapping)
                addRange(range, node: mapping)
                stack.append(mapping)
                
            case .MappingEnd:
                let last = self.stack.popLast()
                guard let mapping = last as? Node.Mapping else { fatalError("Expected Mapping node.") }
                addRange(range, node: mapping)
            }
        }
        
        func addNode(node: Node) {
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
            
            if !node.anchor.isEmpty {
                self.anchors[node.anchor] = node
            }
        }
        
        func addRange(range: Mark.Range, node: Node) {
            let key = ObjectIdentifier(node)
            lookup[key] = Mark.Range.union(lookup[key], range)
        }
        
    }
    
}


