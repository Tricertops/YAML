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

- (nonnull instancetype)init;
- (nonnull instancetype)initWithFileURL:(nonnull NSURL *)fileURL;
- (nonnull instancetype)initWithFileHandle:(nonnull NSFileHandle *)fileHandle;

@end


#pragma mark - Result Getters

@interface YAMLWriter (ResultGetters)

@property (readonly) NSUInteger outputLength;
@property (readonly, nonnull) NSString *outputString;
@property (readonly, nullable) NSError *error;

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

typedef BOOL (^YAMLWriterBlock)(void);

@interface YAMLWriter (WritingMethods)

- (BOOL)beginDocument;
- (BOOL)endDocument;
- (BOOL)writeDocument:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block;

- (BOOL)beginArray;
- (BOOL)beginArrayWithStyle:(YAMLStyleArray)style;
- (BOOL)endArray;
- (BOOL)writeArray:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block;

- (BOOL)beginDictionary;
- (BOOL)beginDictionaryWithStyle:(YAMLStyleDictionary)style;
- (BOOL)endDictionary;
- (BOOL)writeDictionary:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block;
- (BOOL)expectKey;
- (BOOL)expectKeyAsLong:(BOOL)longKey;
- (BOOL)expectValue;

- (BOOL)writeString:(nonnull NSString *)string;
- (BOOL)writeString:(nonnull NSString *)string style:(YAMLStyleString)style; //TODO: Escape Unicode?
- (BOOL)writeBoolean:(BOOL)boolean;
- (BOOL)writeBoolean:(BOOL)boolean style:(YAMLStyleBoolean)style;
- (BOOL)writeInteger:(NSInteger)integer;
- (BOOL)writeInteger:(NSInteger)integer style:(YAMLStyleInteger)style;
- (BOOL)writeNumber:(double)number;
- (BOOL)writeNumber:(double)number precision:(NSUInteger)precision;
- (BOOL)writeData:(nonnull NSData *)data;

- (BOOL)writeNull;
- (BOOL)writeNewLine;
- (BOOL)writeComment:(nonnull NSString *)comment;
- (BOOL)writeComment:(nonnull NSString *)comment leadingSpaces:(NSUInteger)leadingSpaces;
- (BOOL)writeComment:(nonnull NSString *)comment leadingSpaces:(NSUInteger)leadingSpaces trailingSpaces:(NSUInteger)trailingSpaces;

- (BOOL)writeAnchor:(nonnull NSString *)name;
- (BOOL)writeAlias:(nonnull NSString *)name;

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

