//
//  YAMLNode.mm
//  YAML Bridge
//
//  Created by Martin Kiss on 30 April 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//

#import <YAMLCore/YAMLCore.h>
#import "YAMLNode.h"


@interface YAMLNode ()

- (instancetype)initWithCoreNode:(YAML::Node)core;

@end


#pragma mark Private Subclasses

@interface YAMLNodeNull : YAMLNode @end
@interface YAMLNodeString : YAMLNode @end
@interface YAMLNodeArray : YAMLNode @end
@interface YAMLNodeDictionary : YAMLNode @end


#pragma mark - Base Implementation

@implementation YAMLNode


- (instancetype)initWithCoreNode:(YAML::Node)core {
    self = [super init];
    YAML_UNEXPECTED(self == nil);
    YAML_UNEXPECTED(self.class != YAMLNode.class, "This class is abstract, allocate a subclass.");
    YAML_UNEXPECTED( ! core.IsDefined(), "Cannot handle undefined nodes.");
    
    self->_type = [self.class typeFromCoreType:core.Type()];
    self->_tag = @(core.Tag().c_str());
    
    self->_sourcePosition = core.Mark().pos;
    self->_sourceLine = core.Mark().line;
    self->_sourceColumn = core.Mark().column;
    
    return self;
}


+ (YAMLNodeType)typeFromCoreType:(YAML::NodeType::value)core {
    switch (core) {
        case YAML::NodeType::value::Undefined: return YAMLNodeType_Undefined;
        case YAML::NodeType::value::Null: return YAMLNodeType_Null;
        case YAML::NodeType::value::Scalar: return YAMLNodeType_String;
        case YAML::NodeType::value::Sequence: return YAMLNodeType_Array;
        case YAML::NodeType::value::Map: return YAMLNodeType_Dictionary;
    }
    YAML_UNEXPECTED(core, "Unexpected node type: %i", core);
    return YAMLNodeType_Undefined;
}


- (NSString *)string {
    return nil;
}


- (NSArray<YAMLNode *> *)array {
    return nil;
}


- (NSDictionary<YAMLNode *,YAMLNode *> *)dictionary {
    return nil;
}


@end


#pragma mark - Loading Nodes

@implementation YAMLNode (Loading)


+ (instancetype)nodeFromCoreNode:(YAML::Node)core {
    YAMLNodeType type = [self typeFromCoreType:core.Type()];
    switch (type) {
        case YAMLNodeType_Undefined: {
            YAML_UNEXPECTED(core, "Cannot handle undefined nodes.");
        }
        case YAMLNodeType_Null: {
            return [[YAMLNodeNull alloc] initWithCoreNode:core];
        }
        case YAMLNodeType_String: {
            return [[YAMLNodeString alloc] initWithCoreNode:core];
        }
        case YAMLNodeType_Array: {
            return [[YAMLNodeArray alloc] initWithCoreNode:core];
        }
        case YAMLNodeType_Dictionary: {
            return [[YAMLNodeDictionary alloc] initWithCoreNode:core];
        }
    }
    YAML_UNEXPECTED(core, "Unexpected node type: %i", core.Type());
    return nil;
}

+ (nonnull NSArray<YAMLNode *> *)documentsFromString:(nonnull NSString *)string {
    YAML_UNEXPECTED(string == nil);
    
    return [self documentsFromVector:YAML::LoadAll(string.UTF8String)];
}

+ (nonnull NSArray<YAMLNode *> *)documentsFromFileURL:(nonnull NSURL *)fileURL {
    YAML_UNEXPECTED(fileURL == nil);
    YAML_UNEXPECTED( ! fileURL.isFileURL, "Supports only loading from files.");
    
    return [self documentsFromVector:YAML::LoadAllFromFile(fileURL.path.UTF8String)];
}

+ (nonnull NSArray<YAMLNode *> *)documentsFromVector:(std::vector<YAML::Node>)vector {
    NSMutableArray<YAMLNode *> *documents = [NSMutableArray new];
    for(std::vector<YAML::Node>::iterator iterator = vector.begin(); iterator != vector.end(); iterator ++) {
        YAMLNode *node = [YAMLNode nodeFromCoreNode:*iterator];
        [documents addObject:node];
    }
    return documents;
}


@end


#pragma mark - Null Node

@implementation YAMLNodeNull


- (instancetype)initWithCoreNode:(YAML::Node)core {
    self = [super init];
    YAML_UNEXPECTED(self == nil);
    YAML_UNEXPECTED( ! core.IsNull());
    return self;
}


@end


#pragma mark - String Node

@implementation YAMLNodeString


- (instancetype)initWithCoreNode:(YAML::Node)core {
    self = [super init];
    YAML_UNEXPECTED(self == nil);
    YAML_UNEXPECTED( ! core.IsScalar());
    
    self->_string = @(core.Scalar().c_str());
    
    return self;
}

@synthesize string = _string;


@end


#pragma mark - Array Node

@implementation YAMLNodeArray


- (instancetype)initWithCoreNode:(YAML::Node)core {
    self = [super init];
    YAML_UNEXPECTED(self == nil);
    YAML_UNEXPECTED( ! core.IsSequence());
    return self;
}

@synthesize array = _array;

- (NSArray<YAMLNode *> *)array {
    if (self->_array == nil) {
        //TODO: Convert children to YAMLNodes.
    }
    return self->_array;
}


@end


#pragma mark - Dictionary Node

@implementation YAMLNodeDictionary


- (instancetype)initWithCoreNode:(YAML::Node)core {
    self = [super init];
    YAML_UNEXPECTED(self == nil);
    YAML_UNEXPECTED( ! core.IsMap());
    return self;
}

@synthesize dictionary = _dictionary;

- (NSDictionary<YAMLNode *,YAMLNode *> *)dictionary {
    if (self->_dictionary == nil) {
        //TODO: Convert children to YAMLNodes.
    }
    return self->_dictionary;
}


@end


