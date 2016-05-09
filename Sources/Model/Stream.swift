//
//  Stream.swift
//  YAML.framework
//
//  Created by Martin Kiss on 7 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//


public class Stream: Parsed, Emittable {
    
    enum Encoding {
        case UTF8
        case UTF16LittleEndian
        case UTF16BigEndian
        
        static func from(c_encoding c_encoding: yaml_encoding_t) -> Encoding {
            switch c_encoding {
            case YAML_UTF8_ENCODING: return .UTF8
            case YAML_UTF16BE_ENCODING: return .UTF16BigEndian
            case YAML_UTF16LE_ENCODING: return .UTF16LittleEndian
            default:
                YAML.log(warning: "Unrecognized encoding \(c_encoding)")
                return .UTF8
            }
        }
    }
    
    var encoding: Encoding = .UTF8
    
    var documents: [Document] = []
    
    var explicitEnd: Bool = false
    
}

