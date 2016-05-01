//
//  YAMLNode.h
//  YAML Bridge
//
//  Created by Martin Kiss on 30 April 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//

#import "YAMLDefines.h"



#pragma mark - YAML Node Class

@interface YAMLNode : NSObject <NSCopying>

+ (nonnull instancetype)new YAML_UNAVAILABLE("Do not construct nodes yourself.");
+ (nonnull instancetype)alloc YAML_UNAVAILABLE("Do not construct nodes yourself.");
- (nonnull instancetype)init YAML_UNAVAILABLE("Do not construct nodes yourself.");

- (nonnull instancetype)copy; //!< Returns self.
- (BOOL)isEqual:(nonnull YAMLNode *)other; //!< Compares pointer identity.

@end


#pragma mark - Loading Nodes

@interface YAMLNode (Loading)

+ (nonnull NSArray<YAMLNode *> *)documentsFromString:(nonnull NSString *)string;
+ (nonnull NSArray<YAMLNode *> *)documentsFromFileURL:(nonnull NSURL *)fileURL;

@end


#pragma mark - Reading From Nodes

@interface YAMLNode () // Not a category, because of stored properties.

YAML_ENUM(YAMLNodeType) {
    YAMLNodeType_Undefined, //TODO: Can be produced?
    YAMLNodeType_Null, //TODO: Create special getter?
    YAMLNodeType_String,
    YAMLNodeType_Array,
    YAMLNodeType_Dictionary,
};

@property (readonly) YAMLNodeType type;
@property (readonly, nonnull) NSString *tag;

@property (readonly, nullable) NSString *string;
@property (readonly, nullable) NSArray<YAMLNode *> *array;
@property (readonly, nullable) NSDictionary<YAMLNode *,YAMLNode *> *dictionary;

@end


#pragma mark - Source Reference

@interface YAMLNode () // Not a category, because of stored properties.

@property (readonly) NSUInteger sourcePosition;
@property (readonly) NSUInteger sourceLine;
@property (readonly) NSUInteger sourceColumn;

@end


