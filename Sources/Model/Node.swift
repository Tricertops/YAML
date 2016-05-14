//
//  Node.swift
//  YAML.framework
//
//  Created by Martin Kiss on 14 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//



public class Node {
    
    public var tag: Tag?
    
    public var anchor: String?
    
}


extension Node {
    
    public class Scalar: Node {
        
        public var content: String = ""
        
        public var style: Style? = .Auto
        
        public enum Style {
            case Plain
            case SingleQuoted
            case DoubleQuoted
            case Literal
            case Folded
            
            public static let Auto: Style? = nil
        }
        
    }
    
}


extension Node {
    
    public class Sequence: Node {
        
        public var items: [Node] = []
        
        public var style: Style? = .Auto
        
        public enum Style {
            case Block
            case Flow
            
            public static let Auto: Style? = nil
        }
        
    }
    
}


extension Node {
    
    public class Mapping: Node {
        
        public var pairs: [(Node, Node)] = []
        
        public var style: Style? = .Auto
        
        public enum Style {
            case Block
            case Flow
            
            public static let Auto: Style? = nil
        }
        
    }
    
}

