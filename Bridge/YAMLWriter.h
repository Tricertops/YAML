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
- (BOOL)beginArrayWithStyle:(YAMLStyleArray)style indentation:(NSUInteger)indentation;
- (BOOL)endArray;
- (BOOL)writeArray:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block;

- (BOOL)beginDictionary;
- (BOOL)beginDictionaryWithStyle:(YAMLStyleDictionary)style;
- (BOOL)beginDictionaryWithStyle:(YAMLStyleDictionary)style indentation:(NSUInteger)indentation;
- (BOOL)endDictionary;
- (BOOL)writeDictionary:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block;
- (BOOL)expectKey;
- (BOOL)expectKeyAsLong:(BOOL)longKey    YAML_SWIFT_NAME(expectKey(long:));
- (BOOL)expectValue;
- (BOOL)writeKey:(nonnull NSString *)key value:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block    YAML_SWIFT_NAME(write(key:value:));

- (BOOL)writeString:(nullable NSString *)string    YAML_SWIFT_NAME(write(_:));
- (BOOL)writeString:(nullable NSString *)string style:(YAMLStyleString)style    YAML_SWIFT_NAME(write(_:style:)); //TODO: Escape Unicode?

- (BOOL)writeNewLine;

- (BOOL)writeBoolean:(BOOL)boolean    YAML_SWIFT_NAME(write(_:));
- (BOOL)writeBoolean:(BOOL)boolean style:(YAMLStyleBoolean)style    YAML_SWIFT_NAME(write(_:style:));

- (BOOL)writeInteger:(NSInteger)integer    YAML_SWIFT_NAME(write(_:));
- (BOOL)writeInteger:(NSInteger)integer style:(YAMLStyleInteger)style    YAML_SWIFT_NAME(write(_:style:));

- (BOOL)writeNumber:(double)number    YAML_SWIFT_NAME(write(_:));
- (BOOL)writeNumber:(double)number precision:(NSUInteger)precision    YAML_SWIFT_NAME(write(_:precision:));

- (BOOL)writeData:(nullable NSData *)data    YAML_SWIFT_NAME(write(_:));

- (BOOL)writeNull;

- (BOOL)writeComment:(nonnull NSString *)comment    YAML_SWIFT_NAME(write(comment:));
- (BOOL)writeComment:(nonnull NSString *)comment leadingSpaces:(NSUInteger)leadingSpaces    YAML_SWIFT_NAME(write(comment:leadingSpaces:));
- (BOOL)writeComment:(nonnull NSString *)comment leadingSpaces:(NSUInteger)leadingSpaces trailingSpaces:(NSUInteger)trailingSpaces    YAML_SWIFT_NAME(write(comment:leadingSpaces:trailingSpaces:));

- (BOOL)writeAnchor:(nonnull NSString *)name    YAML_SWIFT_NAME(write(anchor:));
- (BOOL)writeAlias:(nonnull NSString *)name    YAML_SWIFT_NAME(write(alias:));

@end

