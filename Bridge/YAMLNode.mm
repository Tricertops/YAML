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


#pragma mark Internal Interface

@interface YAMLNode ()

+ (nonnull instancetype)allocInternal NS_RETURNS_RETAINED;
- (nonnull instancetype)initWithCoreNode:(YAML::Node)core NS_DESIGNATED_INITIALIZER;

@end


#pragma mark Internal Subclasses

@interface YAMLNodeNull : YAMLNode

- (NSString *)string YAML_UNAVAILABLE("This is always nil.");
- (NSArray<YAMLNode *> *)array YAML_UNAVAILABLE("This is always nil.");
- (NSDictionary<YAMLNode *,YAMLNode *> *)dictionary YAML_UNAVAILABLE("This is always nil.");

@end

@interface YAMLNodeString : YAMLNode

- (NSArray<YAMLNode *> *)array YAML_UNAVAILABLE("This is always nil.");
- (NSDictionary<YAMLNode *,YAMLNode *> *)dictionary YAML_UNAVAILABLE("This is always nil.");

@end

@interface YAMLNodeArray : YAMLNode

- (NSString *)string YAML_UNAVAILABLE("This is always nil.");
- (NSDictionary<YAMLNode *,YAMLNode *> *)dictionary YAML_UNAVAILABLE("This is always nil.");

@end

@interface YAMLNodeDictionary : YAMLNode

- (NSString *)string YAML_UNAVAILABLE("This is always nil.");
- (NSArray<YAMLNode *> *)array YAML_UNAVAILABLE("This is always nil.");

@end


#pragma mark - Base Implementation

#define NEWLINE     @"\n"
#define INDENT2     @"  "
#define INDENT4     @"    "

@implementation YAMLNode


+ (nonnull instancetype)allocInternal NS_RETURNS_RETAINED {
    return [super alloc];
}

- (nonnull instancetype)init {
    YAML_UNEXPECTED(YAMLNode.class, "Do not construct nodes yourself.");
    YAML::Node fake;
    return [self initWithCoreNode:fake];
}

- (nonnull instancetype)initWithCoreNode:(YAML::Node)core {
    self = [super init];
    YAML_UNEXPECTED(self == nil);
    YAML_UNEXPECTED(self.class == YAMLNode.class, "This class is abstract, allocate a subclass.");
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

- (instancetype)copyWithZone:(__unused NSZone *)zone {
    return self;
}

- (nonnull instancetype)copy {
    return self;
}

- (BOOL)isEqual:(nonnull YAMLNode *)other {
    return (self == other);
}

- (nonnull NSString *)description {
    return [NSString stringWithFormat:@"%@::%p %@", self.class, self, self.tag];
}

- (nonnull NSString*)indentedDescriptionWith:(nonnull NSString *)indent {
    NSString *replacement = [NEWLINE stringByAppendingString: indent];
    return [self.description stringByReplacingOccurrencesOfString:NEWLINE withString:replacement];
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
            return [[YAMLNodeNull allocInternal] initWithCoreNode:core];
        }
        case YAMLNodeType_String: {
            return [[YAMLNodeString allocInternal] initWithCoreNode:core];
        }
        case YAMLNodeType_Array: {
            return [[YAMLNodeArray allocInternal] initWithCoreNode:core];
        }
        case YAMLNodeType_Dictionary: {
            return [[YAMLNodeDictionary allocInternal] initWithCoreNode:core];
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
    for(auto core = vector.begin(); core != vector.end(); core ++) {
        YAMLNode *node = [YAMLNode nodeFromCoreNode:*core];
        [documents addObject:node];
    }
    return documents;
}


@end


#pragma mark - Null Node

@implementation YAMLNodeNull


- (instancetype)initWithCoreNode:(YAML::Node)core {
    self = [super initWithCoreNode:core];
    YAML_UNEXPECTED(self == nil);
    YAML_UNEXPECTED( ! core.IsNull());
    return self;
}


@end


#pragma mark - String Node

@implementation YAMLNodeString


@synthesize string = _string;

- (instancetype)initWithCoreNode:(YAML::Node)core {
    self = [super initWithCoreNode:core];
    YAML_UNEXPECTED(self == nil);
    YAML_UNEXPECTED( ! core.IsScalar());
    
    self->_string = @(core.Scalar().c_str());
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ “%@”", super.description, self.string];
}


@end


#pragma mark - Array Node

@implementation YAMLNodeArray


@synthesize array = _array;

- (instancetype)initWithCoreNode:(YAML::Node)core {
    self = [super initWithCoreNode:core];
    YAML_UNEXPECTED(self == nil);
    YAML_UNEXPECTED( ! core.IsSequence());
    
    NSMutableArray<YAMLNode *> *array = [NSMutableArray new];
    for (auto subcore = core.begin(); subcore != core.end(); subcore ++) {
        [array addObject: [YAMLNode nodeFromCoreNode:*subcore]];
    }
    self->_array = array;
    
    return self;
}

- (NSString *)description {
    NSMutableString *description = [super.description mutableCopy];
    for (YAMLNode *node in self.array)
    {
        [description appendFormat:NEWLINE "  – %@", [node indentedDescriptionWith:INDENT4]];
    }
    return description;
}


@end


#pragma mark - Dictionary Node

@implementation YAMLNodeDictionary


@synthesize dictionary = _dictionary;

- (instancetype)initWithCoreNode:(YAML::Node)core {
    self = [super initWithCoreNode:core];
    YAML_UNEXPECTED(self == nil);
    YAML_UNEXPECTED( ! core.IsMap());
    
    NSMutableDictionary<YAMLNode *,YAMLNode *> *dictionary = [NSMutableDictionary new];
    for (auto subcore = core.begin(); subcore != core.end(); subcore ++) {
        YAMLNode *key = [YAMLNode nodeFromCoreNode:subcore->first];
        YAMLNode *value = [YAMLNode nodeFromCoreNode:subcore->second];
        dictionary[key] = value;
    }
    self->_dictionary = dictionary;
    
    return self;
}

- (NSString *)description {
    NSMutableString *description = [super.description mutableCopy];
    for (YAMLNode *key in self.dictionary)
    {
        YAMLNode *value = self.dictionary[key];
        [description appendFormat:NEWLINE "  %@ = %@",
         [key indentedDescriptionWith:INDENT2],
         [value indentedDescriptionWith:INDENT2]];
    }
    return description;
}


@end


