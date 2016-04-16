//
//  YAMLEmitter.h
//  YAML
//
//  Created by Martin Kiss on 16.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YAMLEmitterStyle.h"


@interface YAMLEmitter : NSObject

- (instancetype)init;

@property (readonly) NSUInteger outputLength;
@property (readonly) NSString *outputString;
@property (readonly) NSError *lastError;
@property (copy) void (^errorHandler)(NSError *);

@property (copy) YAMLEmitterAppliedStyle *globalStyle;
@property (copy) YAMLEmitterAppliedStyle *localStyle;

- (void)beginDocument;
- (void)endDocument;

- (void)beginArray;
- (void)beginArrayWithStyle:(YAMLEmitterStyleArray)style;
- (void)endArray;

- (void)beginDictionary;
- (void)beginDictionaryWithStyle:(YAMLEmitterStyleDictionary)style;
- (void)endDictionary;

- (void)writeVersionDirective;
- (void)writeNewLine;
- (void)writeString:(NSString *)string;
- (void)writeBoolean:(BOOL)boolean;
- (void)writeInteger:(NSInteger)integer;
- (void)writeNumber:(double)number;
- (void)writeData:(NSData *)data;
- (void)writeComment:(NSString *)comment;
- (void)writeNull;
- (void)writeAnchor:(NSString *)name;
- (void)writeAlias:(NSString *)name;
- (void)writeEmpty;
//TODO: Write Tags.

@end
