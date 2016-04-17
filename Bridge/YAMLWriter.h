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


//MARK: Writing Document

- (BOOL)beginDocumentWithError:(YAML_ERROR_TYPE)error;
- (BOOL)endDocumentWithError:(YAML_ERROR_TYPE)error;
- (BOOL)writeDocument:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block error:(YAML_ERROR_TYPE)error;


//MARK: Writing Array (Sequence)

- (BOOL)beginArrayWithError:(YAML_ERROR_TYPE)error;
- (BOOL)beginArrayWithStyle:(YAMLStyleArray)style error:(YAML_ERROR_TYPE)error;
- (BOOL)beginArrayWithStyle:(YAMLStyleArray)style indentation:(NSUInteger)indentation error:(YAML_ERROR_TYPE)error;
- (BOOL)endArrayWithError:(YAML_ERROR_TYPE)error;
- (BOOL)writeArray:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block error:(YAML_ERROR_TYPE)error;


//MARK: Writing Dictionary (Map)

- (BOOL)beginDictionaryWithError:(YAML_ERROR_TYPE)error;
- (BOOL)beginDictionaryWithStyle:(YAMLStyleDictionary)style error:(YAML_ERROR_TYPE)error;
- (BOOL)beginDictionaryWithStyle:(YAMLStyleDictionary)style indentation:(NSUInteger)indentation error:(YAML_ERROR_TYPE)error;
- (BOOL)endDictionaryWithError:(YAML_ERROR_TYPE)error;
- (BOOL)writeDictionary:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block error:(YAML_ERROR_TYPE)error;
- (BOOL)expectKeyWithError:(YAML_ERROR_TYPE)error;
- (BOOL)expectKeyAsLong:(BOOL)longKey error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(expectKey(long:));
- (BOOL)expectValueWithError:(YAML_ERROR_TYPE)error;
- (BOOL)writeKey:(nonnull NSString *)key value:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block    YAML_SWIFT_NAME(write(key:value:));


//MARK: Writing Scalars

- (BOOL)writeString:(nullable NSString *)string error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(_:));
- (BOOL)writeString:(nullable NSString *)string style:(YAMLStyleString)style error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(_:style:));

- (BOOL)writeBoolean:(BOOL)boolean error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(_:));
- (BOOL)writeBoolean:(BOOL)boolean style:(YAMLStyleBoolean)style error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(_:style:));

- (BOOL)writeInteger:(NSInteger)integer error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(_:));
- (BOOL)writeInteger:(NSInteger)integer style:(YAMLStyleInteger)style error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(_:style:));

- (BOOL)writeNumber:(double)number error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(_:));
- (BOOL)writeNumber:(double)number precision:(NSUInteger)precision error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(_:precision:));

- (BOOL)writeNullWithError:(YAML_ERROR_TYPE)error;

- (BOOL)writeData:(nullable NSData *)data error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(_:));


//MARK: Writing Comments & Whitespace

- (BOOL)writeComment:(nonnull NSString *)comment error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(comment:));
- (BOOL)writeComment:(nonnull NSString *)comment leadingSpaces:(NSUInteger)leadingSpaces error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(comment:leadingSpaces:));
- (BOOL)writeComment:(nonnull NSString *)comment leadingSpaces:(NSUInteger)leadingSpaces trailingSpaces:(NSUInteger)trailingSpaces error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(comment:leadingSpaces:trailingSpaces:));

- (BOOL)writeNewLineWithError:(YAML_ERROR_TYPE)error;


//MARK: Writing Anchors & Aliases

- (BOOL)writeAnchor:(nonnull NSString *)name error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(anchor:));
- (BOOL)writeAlias:(nonnull NSString *)name error:(YAML_ERROR_TYPE)error    YAML_SWIFT_NAME(write(alias:));


@end

