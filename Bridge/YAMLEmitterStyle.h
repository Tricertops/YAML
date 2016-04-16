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
    YAMLEmitterStyleBoolean_true_false,
    YAMLEmitterStyleBoolean_True_False,
    YAMLEmitterStyleBoolean_TRUE_FALSE,
    YAMLEmitterStyleBoolean_t_f,
    YAMLEmitterStyleBoolean_T_F,
    
    YAMLEmitterStyleBoolean_yes_no,
    YAMLEmitterStyleBoolean_Yes_No,
    YAMLEmitterStyleBoolean_YES_NO,
    YAMLEmitterStyleBoolean_y_n,
    YAMLEmitterStyleBoolean_Y_N,
    
    YAMLEmitterStyleBoolean_on_off,
    YAMLEmitterStyleBoolean_On_Off,
    YAMLEmitterStyleBoolean_ON_OFF,
    
    YAMLEmitterStyleBoolean_Default = YAMLEmitterStyleBoolean_true_false,
    YAMLEmitterStyleBoolean_JSON = YAMLEmitterStyleBoolean_true_false,
    
} YAMLEmitterStyleBoolean;


#pragma mark - String

typedef enum : NSUInteger {
    YAMLEmitterStyleString_Auto, //TODO: Better name.
    YAMLEmitterStyleString_Literal,
    YAMLEmitterStyleString_SingleQuoted,
    YAMLEmitterStyleString_DoubleQuoted,
    //TODO: Escaped Unicode?
    
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
    YAMLEmitterStyleDictionary_Flow,
    
    YAMLEmitterStyleDictionary_Default = YAMLEmitterStyleDictionary_Block,
    YAMLEmitterStyleDictionary_JSON = YAMLEmitterStyleDictionary_Flow,
} YAMLEmitterStyleDictionary;

