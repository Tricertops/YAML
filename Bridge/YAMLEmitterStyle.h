//
//  YAMLEmitterStyle.h
//  YAML
//
//  Created by Martin Kiss on 16.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//

#import "YAMLBridgeDefines.h"


#pragma mark Boolean

typedef enum : NSUInteger {
    YAMLEmitterStyleBoolean_yes_no,
    YAMLEmitterStyleBoolean_Yes_No,
    YAMLEmitterStyleBoolean_YES_NO,
    YAMLEmitterStyleBoolean_y_n,
    YAMLEmitterStyleBoolean_Y_N,
    
    YAMLEmitterStyleBoolean_true_false,
    YAMLEmitterStyleBoolean_True_False,
    YAMLEmitterStyleBoolean_TRUE_FALSE,
    YAMLEmitterStyleBoolean_t_f,
    YAMLEmitterStyleBoolean_T_F,
    
    YAMLEmitterStyleBoolean_on_off,
    YAMLEmitterStyleBoolean_On_Off,
    YAMLEmitterStyleBoolean_ON_OFF,
    
    YAMLEmitterStyleBoolean_Default = YAMLEmitterStyleBoolean_Yes_No,
    YAMLEmitterStyleBoolean_JSON = YAMLEmitterStyleBoolean_true_false,
    
} YAMLEmitterStyleBoolean;


#pragma mark - String

typedef enum : NSUInteger {
    YAMLEmitterStyleString_Auto, //TODO: Better name.
    YAMLEmitterStyleString_Literal,
    YAMLEmitterStyleString_SingleQuoted,
    YAMLEmitterStyleString_DoubleQuoted,
    
    YAMLEmitterStyleString_Default = YAMLEmitterStyleString_Auto,
    YAMLEmitterStyleString_JSON = YAMLEmitterStyleString_DoubleQuoted,
    
} YAMLEmitterStyleString;


#pragma mark - Integer

typedef enum : NSUInteger {
    YAMLEmitterStyleInteger_Decimal,
    YAMLEmitterStyleInteger_Hexadecimal,
    YAMLEmitterStyleInteger_Octal,
    
    YAMLEmitterStyleInteger_Default = YAMLEmitterStyleInteger_Decimal,
    YAMLEmitterStyleInteger_JSON = YAMLEmitterStyleInteger_Decimal,
    
} YAMLEmitterStyleInteger;


#pragma mark - Array

typedef enum : NSUInteger {
    YAMLEmitterStyleArray_Block,
    YAMLEmitterStyleArray_Flow,
    
    YAMLEmitterStyleArray_Default = YAMLEmitterStyleArray_Block,
    YAMLEmitterStyleArray_JSON = YAMLEmitterStyleArray_Flow,
} YAMLEmitterStyleArray;


#pragma mark - Dictionary

typedef enum : NSUInteger {
    YAMLEmitterStyleDictionary_Block,
    YAMLEmitterStyleDictionary_LongKeyBlock,
    YAMLEmitterStyleDictionary_Flow,
    
    YAMLEmitterStyleDictionary_Default = YAMLEmitterStyleDictionary_Block,
    YAMLEmitterStyleDictionary_JSON = YAMLEmitterStyleDictionary_Flow,
} YAMLEmitterStyleDictionary;


#pragma mark - Style Class

@class YAMLEmitterStyle;


@interface YAMLEmitterAppliedStyle : NSObject <NSMutableCopying>

- (YAMLEmitterAppliedStyle*)copy;
- (YAMLEmitterStyle*)mutableCopy;

@property BOOL allowsUnicode;
@property YAMLEmitterStyleBoolean booleanStyle;
@property YAMLEmitterStyleString stringStyle;
@property YAMLEmitterStyleInteger integerStyle;
@property YAMLEmitterStyleArray arrayStyle;
@property YAMLEmitterStyleDictionary dictionaryStyle;
@property NSUInteger indentationSpaces;
@property NSUInteger spacesBeforeComment;
@property NSUInteger spacesAfterComment; //TODO: What is this?
@property NSUInteger numberPrecision;

- (BOOL)allowsUnicode YAML_WRITEONLY_PROPERTY;
- (YAMLEmitterStyleBoolean)booleanStyle YAML_WRITEONLY_PROPERTY;
- (YAMLEmitterStyleString)stringStyle YAML_WRITEONLY_PROPERTY;
- (YAMLEmitterStyleInteger)integerStyle YAML_WRITEONLY_PROPERTY;
- (YAMLEmitterStyleArray)arrayStyle YAML_WRITEONLY_PROPERTY;
- (YAMLEmitterStyleDictionary)dictionaryStyle YAML_WRITEONLY_PROPERTY;
- (NSUInteger)indentationSpaces YAML_WRITEONLY_PROPERTY;
- (NSUInteger)spacesBeforeComment YAML_WRITEONLY_PROPERTY;
- (NSUInteger)spacesAfterComment YAML_WRITEONLY_PROPERTY;
- (NSUInteger)numberPrecision YAML_WRITEONLY_PROPERTY;

@end


@interface YAMLEmitterStyle : YAMLEmitterAppliedStyle

- (instancetype)init;
+ (instancetype)defaultStyle;
+ (instancetype)JSONStyle;

@property BOOL allowsUnicode;
@property YAMLEmitterStyleBoolean booleanStyle;
@property YAMLEmitterStyleString stringStyle;
@property YAMLEmitterStyleInteger integerStyle;
@property YAMLEmitterStyleArray arrayStyle;
@property YAMLEmitterStyleDictionary dictionaryStyle;
@property NSUInteger indentationSpaces;
@property NSUInteger spacesBeforeComment;
@property NSUInteger spacesAfterComment;
@property NSUInteger numberPrecision;

@end

