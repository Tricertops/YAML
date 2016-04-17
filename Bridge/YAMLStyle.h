//
//  YAMLStyle.h
//  YAML
//
//  Created by Martin Kiss on 16.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//

#import "YAMLDefines.h"


#pragma mark Boolean

typedef enum : NSUInteger {
    YAMLStyleBoolean_true_false,
    YAMLStyleBoolean_True_False,
    YAMLStyleBoolean_TRUE_FALSE,
    YAMLStyleBoolean_t_f,
    YAMLStyleBoolean_T_F,
    
    YAMLStyleBoolean_yes_no,
    YAMLStyleBoolean_Yes_No,
    YAMLStyleBoolean_YES_NO,
    YAMLStyleBoolean_y_n,
    YAMLStyleBoolean_Y_N,
    
    YAMLStyleBoolean_on_off,
    YAMLStyleBoolean_On_Off,
    YAMLStyleBoolean_ON_OFF,
    
    YAMLStyleBoolean_Default = YAMLStyleBoolean_true_false,
    YAMLStyleBoolean_JSON = YAMLStyleBoolean_true_false,
    
} YAMLStyleBoolean;


#pragma mark - String

typedef enum : NSUInteger {
    YAMLStyleString_Auto, //TODO: Better name.
    YAMLStyleString_Literal,
    YAMLStyleString_SingleQuoted,
    YAMLStyleString_DoubleQuoted,
    //TODO: Escaped Unicode?
    
    YAMLStyleString_Default = YAMLStyleString_Auto,
    YAMLStyleString_JSON = YAMLStyleString_DoubleQuoted,
    
} YAMLStyleString;


#pragma mark - Integer

typedef enum : NSUInteger {
    YAMLStyleInteger_Decimal,
    YAMLStyleInteger_Hexadecimal,
    YAMLStyleInteger_Octal,
    
    YAMLStyleInteger_Default = YAMLStyleInteger_Decimal,
    YAMLStyleInteger_JSON = YAMLStyleInteger_Decimal,
    
} YAMLStyleInteger;


#pragma mark - Array

typedef enum : NSUInteger {
    YAMLStyleArray_Block,
    YAMLStyleArray_Flow,
    
    YAMLStyleArray_Default = YAMLStyleArray_Block,
    YAMLStyleArray_JSON = YAMLStyleArray_Flow,
} YAMLStyleArray;


#pragma mark - Dictionary

typedef enum : NSUInteger {
    YAMLStyleDictionary_Block,
    YAMLStyleDictionary_Flow,
    
    YAMLStyleDictionary_Default = YAMLStyleDictionary_Block,
    YAMLStyleDictionary_JSON = YAMLStyleDictionary_Flow,
} YAMLStyleDictionary;

