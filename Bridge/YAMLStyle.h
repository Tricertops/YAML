//
//  YAMLStyle.h
//  YAML
//
//  Created by Martin Kiss on 16.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//

#import "YAMLDefines.h"


#pragma mark Boolean

YAML_ENUM(YAMLStyleBoolean) {
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
    
};


#pragma mark - String

YAML_ENUM(YAMLStyleString) {
    YAMLStyleString_Plain,
    YAMLStyleString_Literal,
    YAMLStyleString_SingleQuoted,
    YAMLStyleString_DoubleQuoted,
    YAMLStyleString_DoubleQuotedASCII,
    
    YAMLStyleString_Default = YAMLStyleString_Plain,
    YAMLStyleString_JSON = YAMLStyleString_DoubleQuoted,
    
};


#pragma mark - Integer

YAML_ENUM(YAMLStyleInteger) {
    YAMLStyleInteger_Decimal,
    YAMLStyleInteger_Hexadecimal,
    YAMLStyleInteger_Octal,
    
    YAMLStyleInteger_Default = YAMLStyleInteger_Decimal,
    YAMLStyleInteger_JSON = YAMLStyleInteger_Decimal,
    
};


#pragma mark - Array

YAML_ENUM(YAMLStyleArray) {
    YAMLStyleArray_Block,
    YAMLStyleArray_Flow,
    
    YAMLStyleArray_Default = YAMLStyleArray_Block,
    YAMLStyleArray_JSON = YAMLStyleArray_Flow,
};


#pragma mark - Dictionary

YAML_ENUM(YAMLStyleDictionary) {
    YAMLStyleDictionary_Block,
    YAMLStyleDictionary_BlockLongKeys,
    YAMLStyleDictionary_Flow,
    
    YAMLStyleDictionary_Default = YAMLStyleDictionary_Block,
    YAMLStyleDictionary_JSON = YAMLStyleDictionary_Flow,
};

