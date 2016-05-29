//
//  Emitter+Internal.swift
//  YAML.framework
//
//  Created by Martin Kiss on 28 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



extension Emitter {
    
    func internal_emit(stream: Stream) throws -> String {
        return try Internal(emitter: self).emit(stream)
    }
    
    private class Internal {
        
        var emitter: Emitter
        
        init(emitter: Emitter) {
            self.emitter = emitter
        }
        
        var c_emitter = yaml_emitter_t()
        var output: String = ""
        
        func emit(stream: Stream) throws -> String {
            setup()
            defer {
                cleanup()
            }
            //TODO: Emit Stream and Nodes.
            return output
        }
        
        func setup() {
            yaml_emitter_initialize(&c_emitter)
            
            yaml_emitter_set_encoding(&c_emitter, YAML_UTF8_ENCODING)
            yaml_emitter_set_canonical(&c_emitter, emitter.isCanonical ? 1 : 0)
            yaml_emitter_set_indent(&c_emitter, Int32(emitter.indentation))
            yaml_emitter_set_width(&c_emitter, Int32(emitter.lineWidth ?? -1))
            yaml_emitter_set_unicode(&c_emitter, emitter.allowsUnicode ? 1 : 0)
            yaml_emitter_set_break(&c_emitter, emitter.lineBreaks.c_lineBreak)
            
            let boxed: UnsafeMutablePointer<Internal> = nil
            boxed.memory = self
            
            yaml_emitter_set_output(&c_emitter, {
                (boxed, bytes, count) -> Int32 in
                let `self` = UnsafePointer<Internal>(boxed).memory
                
                let buffer = UnsafeBufferPointer(start: bytes, count: count)
                var generator = buffer.generate()
                var string = ""
                
                var decoder = UTF8()
                while case .Result(let scalar) = decoder.decode(&generator) {
                    string.unicodeScalars.append(scalar)
                }
                
                self.appendString(string)
                
                return 1
                }, boxed)
        }
        
        func appendString(string: String) {
            output += string
        }
        
        func cleanup() {
            yaml_emitter_delete(&c_emitter)
            c_emitter = yaml_emitter_t() // Clear.
        }
        
    }
    
}


extension Emitter.LineBreaks {
    
    var c_lineBreak: yaml_break_t {
        switch self {
        case .LF: return YAML_LN_BREAK
        case .CR: return YAML_CR_BREAK
        case .CRLF: return YAML_CRLN_BREAK
        }
    }
    
}

