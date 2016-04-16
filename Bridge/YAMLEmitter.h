//
//  YAMLEmitter.h
//  YAML
//
//  Created by Martin Kiss on 16.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAMLEmitterStyle.h"

//TODO: Version directive?
//TODO: Tags?
//TODO: Errors?
//TODO: Dates?


#pragma mark -

@interface YAMLEmitter : NSObject

@end


#pragma mark - Initializers

@interface YAMLEmitter (Initializers)

- (instancetype)init;
- (instancetype)initWithFileURL:(NSURL *)fileURL;
- (instancetype)initWithFileHandle:(NSFileHandle *)fileHandle;

@end


#pragma mark - Result Getters

@interface YAMLEmitter (ResultGetters)

@property (readonly) NSUInteger outputLength;
@property (readonly) NSString *outputString;
@property (readonly) NSError *error;

@end


#pragma mark - Global Style

@interface YAMLEmitter (GlobalStyle)

@property BOOL allowsUnicode;
@property YAMLEmitterStyleBoolean booleanStyle;
@property YAMLEmitterStyleString stringStyle;
@property YAMLEmitterStyleInteger integerStyle;
@property YAMLEmitterStyleArray arrayStyle;
@property YAMLEmitterStyleDictionary dictionaryStyle;
@property NSUInteger indentationSpaces;
@property NSUInteger commentLeadingSpaces;
@property NSUInteger commentTrailingSpaces;
@property NSUInteger numberPrecision;

@end


#pragma mark - Writing Methods

@interface YAMLEmitter (WritingMethods)

- (BOOL)beginDocument;
- (BOOL)endDocument;

- (BOOL)beginArray;
- (BOOL)beginArrayWithStyle:(YAMLEmitterStyleArray)arrayStyle;
- (BOOL)endArray;

- (BOOL)beginDictionary;
- (BOOL)beginDictionaryWithStyle:(YAMLEmitterStyleDictionary)dictionaryStyle;
- (BOOL)endDictionary;
- (BOOL)expectKey;
- (BOOL)expectKeyAsLong:(BOOL)longKey;
- (BOOL)expectValue;

- (BOOL)writeString:(NSString *)string;
- (BOOL)writeString:(NSString *)string style:(YAMLEmitterStyleString)stringStyle; //TODO: Escape Unicode?
- (BOOL)writeBoolean:(BOOL)boolean;
- (BOOL)writeBoolean:(BOOL)boolean style:(YAMLEmitterStyleBoolean)booleanStyle;
- (BOOL)writeInteger:(NSInteger)integer;
- (BOOL)writeInteger:(NSInteger)integer style:(YAMLEmitterStyleInteger)integerStyle;
- (BOOL)writeNumber:(double)number;
- (BOOL)writeNumber:(double)number precision:(NSUInteger)numberOfIntegerDigits;
- (BOOL)writeData:(NSData *)data;

- (BOOL)writeNull;
- (BOOL)writeNewLine;
- (BOOL)writeComment:(NSString *)comment;
- (BOOL)writeComment:(NSString *)comment leadingSpaces:(NSUInteger)leading;
- (BOOL)writeComment:(NSString *)comment leadingSpaces:(NSUInteger)leading trailingSpaces:(NSUInteger)trailingSpaces;

- (BOOL)writeAnchor:(NSString *)name;
- (BOOL)writeAlias:(NSString *)name;

@end


#pragma mark - Unavailable Getters

@interface YAMLEmitter (UnavailableGetters)

- (BOOL)allowsUnicode YAML_WRITEONLY_PROPERTY;
- (YAMLEmitterStyleBoolean)booleanStyle YAML_WRITEONLY_PROPERTY;
- (YAMLEmitterStyleString)stringStyle YAML_WRITEONLY_PROPERTY;
- (YAMLEmitterStyleInteger)integerStyle YAML_WRITEONLY_PROPERTY;
- (YAMLEmitterStyleArray)arrayStyle YAML_WRITEONLY_PROPERTY;
- (YAMLEmitterStyleDictionary)dictionaryStyle YAML_WRITEONLY_PROPERTY;
- (NSUInteger)indentationSpaces YAML_WRITEONLY_PROPERTY;
- (NSUInteger)commentLeadingSpaces YAML_WRITEONLY_PROPERTY;
- (NSUInteger)commentTrailingSpaces YAML_WRITEONLY_PROPERTY;
- (NSUInteger)numberPrecision YAML_WRITEONLY_PROPERTY;

@end

