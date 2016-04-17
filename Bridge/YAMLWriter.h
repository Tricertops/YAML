//
//  YAMLWriter.h
//  YAML
//
//  Created by Martin Kiss on 16.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//

#import "YAMLDefines.h"
#import "YAMLStyle.h"

//TODO: Version directive?
//TODO: Tags?
//TODO: Errors?
//TODO: Dates?


#pragma mark -

@interface YAMLWriter : NSObject

+ (BOOL)test;

@end


#pragma mark - Initializers

@interface YAMLWriter (Initializers)

- (instancetype)init;
- (instancetype)initWithFileURL:(NSURL *)fileURL;
- (instancetype)initWithFileHandle:(NSFileHandle *)fileHandle;

@end


#pragma mark - Result Getters

@interface YAMLWriter (ResultGetters)

@property (readonly) NSUInteger outputLength;
@property (readonly) NSString *outputString;
@property (readonly) NSError *error;

@end


#pragma mark - Global Style

@interface YAMLWriter (GlobalStyle)

@property BOOL allowsUnicode;
@property YAMLStyleBoolean booleanStyle;
@property YAMLStyleString stringStyle;
@property YAMLStyleInteger integerStyle;
@property YAMLStyleArray arrayStyle;
@property YAMLStyleDictionary dictionaryStyle;
@property NSUInteger indentationSpaces;
@property NSUInteger commentLeadingSpaces;
@property NSUInteger commentTrailingSpaces;
@property NSUInteger numberPrecision;

@end


#pragma mark - Writing Methods

@interface YAMLWriter (WritingMethods)

- (BOOL)beginDocument;
- (BOOL)endDocument;

- (BOOL)beginArray;
- (BOOL)beginArrayWithStyle:(YAMLStyleArray)arrayStyle;
- (BOOL)endArray;

- (BOOL)beginDictionary;
- (BOOL)beginDictionaryWithStyle:(YAMLStyleDictionary)dictionaryStyle;
- (BOOL)endDictionary;
- (BOOL)expectKey;
- (BOOL)expectKeyAsLong:(BOOL)longKey;
- (BOOL)expectValue;

- (BOOL)writeString:(NSString *)string;
- (BOOL)writeString:(NSString *)string style:(YAMLStyleString)stringStyle; //TODO: Escape Unicode?
- (BOOL)writeBoolean:(BOOL)boolean;
- (BOOL)writeBoolean:(BOOL)boolean style:(YAMLStyleBoolean)booleanStyle;
- (BOOL)writeInteger:(NSInteger)integer;
- (BOOL)writeInteger:(NSInteger)integer style:(YAMLStyleInteger)integerStyle;
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

@interface YAMLWriter (UnavailableGetters)

- (BOOL)allowsUnicode YAML_WRITEONLY_PROPERTY;
- (YAMLStyleBoolean)booleanStyle YAML_WRITEONLY_PROPERTY;
- (YAMLStyleString)stringStyle YAML_WRITEONLY_PROPERTY;
- (YAMLStyleInteger)integerStyle YAML_WRITEONLY_PROPERTY;
- (YAMLStyleArray)arrayStyle YAML_WRITEONLY_PROPERTY;
- (YAMLStyleDictionary)dictionaryStyle YAML_WRITEONLY_PROPERTY;
- (NSUInteger)indentationSpaces YAML_WRITEONLY_PROPERTY;
- (NSUInteger)commentLeadingSpaces YAML_WRITEONLY_PROPERTY;
- (NSUInteger)commentTrailingSpaces YAML_WRITEONLY_PROPERTY;
- (NSUInteger)numberPrecision YAML_WRITEONLY_PROPERTY;

@end

