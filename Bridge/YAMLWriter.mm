//
//  YAMLWriter.mm
//  YAML Bridge
//
//  Created by Martin Kiss on 16 April 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//

#import <YAMLCore/YAMLCore.h>
#import "YAMLWriter.h"
#import "YAMLFileDescriptorOutputBuffer.h"


#pragma mark Private Properties

@interface YAMLWriter ()

@property (readonly) YAML::Emitter *emitter;

@end


#pragma mark Private Utilities

@interface YAMLWriter (StyleUtilities)

- (YAML::EMITTER_MANIP)booleanFormatManipulatorForStyle:(YAMLStyleBoolean)style;
- (YAML::EMITTER_MANIP)booleanCaseManipulatorForStyle:(YAMLStyleBoolean)style;
- (YAML::EMITTER_MANIP)booleanLengthManipulatorForStyle:(YAMLStyleBoolean)style;

- (YAML::EMITTER_MANIP)stringFormatManipulatorForStyle:(YAMLStyleString)style;
- (YAML::EMITTER_MANIP)stringCharsetManipulatorForStyle:(YAMLStyleString)style;

- (YAML::EMITTER_MANIP)integerBaseManipulatorForStyle:(YAMLStyleInteger)style;

- (YAML::EMITTER_MANIP)arrayFormatManipulatorForStyle:(YAMLStyleArray)style;

- (YAML::EMITTER_MANIP)dictionaryFormatManipulatorForStyle:(YAMLStyleDictionary)style;
- (YAML::EMITTER_MANIP)dictionaryKeyFormatManipulatorForStyle:(YAMLStyleDictionary)style;

- (int)validateIndentation:(NSUInteger)spaces;
- (int)validateCommentSpacing:(NSUInteger)spaces;

- (int)validateFloatPrecision:(NSUInteger)digits;
- (int)validateDoublePrecision:(NSUInteger)digits;

@end


#pragma mark - Base Implementation

@implementation YAMLWriter

- (void)dealloc {
    delete self->_emitter;
}

@end


#pragma mark - Initializers

@implementation YAMLWriter (Initializers)

- (nonnull instancetype)init {
    self = [super init];
    YAML_UNEXPECTED(self == nil);
    
    self->_emitter = new YAML::Emitter();
    
    return self;
}

- (nullable instancetype)initWithFileURL:(nonnull NSURL *)fileURL {
    NSError *error = nil;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:fileURL error:&error];
    
    if (YAML_WARNING(fileHandle == nil, "Failed to create %@ for URL '%@': %@", NSFileHandle.class, fileURL, error.localizedDescription)) {
        return nil;
    }
    
    return [self initWithFileHandle:fileHandle];
}

- (nullable instancetype)initWithFileHandle:(nonnull NSFileHandle *)fileHandle {
    self = [super init];
    YAML_UNEXPECTED(self == nil);
    
    if (YAML_WARNING(fileHandle == nil)) {
        return nil;
    }
    
    int fileDescriptor = fileHandle.fileDescriptor;
    YAMLFileDescriptorOutputStream stream(fileDescriptor);
    self->_emitter = new YAML::Emitter(stream);
    
    return self;
}

@end


#pragma mark - Result Accessors

@implementation YAMLWriter (ResultAccessors)

- (NSUInteger)outputLength {
    return self->_emitter->size();
}

- (nonnull NSString *)outputString {
    return @(self->_emitter->c_str());
}

- (nullable NSError *)error {
    if (self->_emitter->good()) {
        return nil;
    }
    
    NSString *message = @(self->_emitter->GetLastError().c_str());
    return [NSError errorWithDomain:YAMLErrorDomain
                               code:YAMLErrorWriter
                           userInfo:@{ NSLocalizedDescriptionKey: message }];
}

@end


#pragma mark - Global Style

@implementation YAMLWriter (GlobalStyle)

// Since YAML::Emitter doesn’t expose these properties for reading, we store their copies.
// If the underlaying emitter changes the properties different way, we may have irrelevant values.

- (void)setBooleanStyle:(YAMLStyleBoolean)style {
    self->_booleanStyle = style;
    
    self->_emitter->SetBoolFormat([self booleanFormatManipulatorForStyle:style]);
    self->_emitter->SetBoolFormat([self booleanCaseManipulatorForStyle:style]);
    self->_emitter->SetBoolFormat([self booleanLengthManipulatorForStyle:style]);
}

- (void)setStringStyle:(YAMLStyleString)style {
    self->_stringStyle = style;
    
    self->_emitter->SetStringFormat([self stringFormatManipulatorForStyle:style]);
    self->_emitter->SetOutputCharset([self stringCharsetManipulatorForStyle:style]);
}

- (void)setIntegerStyle:(YAMLStyleInteger)style {
    self->_integerStyle = style;
    
    self->_emitter->SetIntBase([self integerBaseManipulatorForStyle:style]);
}

- (void)setArrayStyle:(YAMLStyleArray)style {
    self->_arrayStyle = style;
    
    self->_emitter->SetSeqFormat([self arrayFormatManipulatorForStyle:style]);
}

- (void)setDictionaryStyle:(YAMLStyleDictionary)style {
    self->_dictionaryStyle = style;
    
    self->_emitter->SetMapFormat([self dictionaryFormatManipulatorForStyle:style]);
    self->_emitter->SetMapFormat([self dictionaryKeyFormatManipulatorForStyle:style]);
}

- (void)setIndentationSpaces:(NSUInteger)spaces {
    self->_indentationSpaces = spaces;
    
    self->_emitter->SetIndent([self validateIndentation:spaces]);
}

- (void)setCommentLeadingSpaces:(NSUInteger)spaces {
    self->_commentLeadingSpaces = spaces;
    
    self->_emitter->SetPreCommentIndent([self validateCommentSpacing:spaces]);
}

- (void)setCommentTrailingSpaces:(NSUInteger)spaces {
    self->_commentTrailingSpaces = spaces;
    
    self->_emitter->SetPostCommentIndent([self validateCommentSpacing:spaces]);
}

- (void)setNumberPrecision:(NSUInteger)precision {
    self->_numberPrecision = precision;
    
    self->_emitter->SetFloatPrecision([self validateFloatPrecision:precision]);
    self->_emitter->SetDoublePrecision([self validateDoublePrecision:precision]);
}

@end


#pragma mark - Style Utilities

@implementation YAMLWriter (StyleUtilities)

- (YAML::EMITTER_MANIP)booleanFormatManipulatorForStyle:(YAMLStyleBoolean)style {
    switch (style) {
        case YAMLStyleBoolean_true_false:
        case YAMLStyleBoolean_True_False:
        case YAMLStyleBoolean_TRUE_FALSE:
        case YAMLStyleBoolean_t_f:
        case YAMLStyleBoolean_T_F:
            return YAML::TrueFalseBool;
            
        case YAMLStyleBoolean_yes_no:
        case YAMLStyleBoolean_Yes_No:
        case YAMLStyleBoolean_YES_NO:
        case YAMLStyleBoolean_y_n:
        case YAMLStyleBoolean_Y_N:
            return YAML::YesNoBool;
            
        case YAMLStyleBoolean_on_off:
        case YAMLStyleBoolean_On_Off:
        case YAMLStyleBoolean_ON_OFF:
            return YAML::OnOffBool;
    }
    YAML_WARNING(style, "Unsupported style %td", style);
    return YAML::TrueFalseBool; // Default.
}

- (YAML::EMITTER_MANIP)booleanCaseManipulatorForStyle:(YAMLStyleBoolean)style {
    switch (style) {
        case YAMLStyleBoolean_true_false:
        case YAMLStyleBoolean_yes_no:
        case YAMLStyleBoolean_t_f:
        case YAMLStyleBoolean_y_n:
        case YAMLStyleBoolean_on_off:
            return YAML::LowerCase;
            
        case YAMLStyleBoolean_True_False:
        case YAMLStyleBoolean_Yes_No:
        case YAMLStyleBoolean_On_Off:
            return YAML::CamelCase;
            
        case YAMLStyleBoolean_TRUE_FALSE:
        case YAMLStyleBoolean_YES_NO:
        case YAMLStyleBoolean_T_F:
        case YAMLStyleBoolean_Y_N:
        case YAMLStyleBoolean_ON_OFF:
            return YAML::UpperCase;
    }
    YAML_WARNING(style, "Unsupported style %td", style);
    return YAML::LowerCase; // Default.
}

- (YAML::EMITTER_MANIP)booleanLengthManipulatorForStyle:(YAMLStyleBoolean)style {
    switch (style) {
        case YAMLStyleBoolean_true_false:
        case YAMLStyleBoolean_True_False:
        case YAMLStyleBoolean_TRUE_FALSE:
        case YAMLStyleBoolean_yes_no:
        case YAMLStyleBoolean_Yes_No:
        case YAMLStyleBoolean_YES_NO:
        case YAMLStyleBoolean_on_off:
        case YAMLStyleBoolean_On_Off:
        case YAMLStyleBoolean_ON_OFF:
            return YAML::LongBool;
            
        case YAMLStyleBoolean_t_f:
        case YAMLStyleBoolean_T_F:
        case YAMLStyleBoolean_y_n:
        case YAMLStyleBoolean_Y_N:
            return YAML::ShortBool;
    }
    YAML_WARNING(style, "Unsupported style %td", style);
    return YAML::LongBool; // Default.
}

- (YAML::EMITTER_MANIP)stringFormatManipulatorForStyle:(YAMLStyleString)style {
    switch (style) {
        case YAMLStyleString_Plain:
            return YAML::Auto;
            
        case YAMLStyleString_Literal:
            return YAML::Literal;
            
        case YAMLStyleString_SingleQuoted:
            return YAML::SingleQuoted;
            
        case YAMLStyleString_DoubleQuoted:
        case YAMLStyleString_DoubleQuotedASCII:
            return YAML::DoubleQuoted;
    }
    YAML_WARNING(style, "Unsupported style %td", style);
    return YAML::Auto; // Default.
}

- (YAML::EMITTER_MANIP)stringCharsetManipulatorForStyle:(YAMLStyleString)style {
    switch (style) {
        case YAMLStyleString_Plain:
        case YAMLStyleString_Literal:
        case YAMLStyleString_SingleQuoted:
        case YAMLStyleString_DoubleQuoted:
            return YAML::EmitNonAscii;
            
        case YAMLStyleString_DoubleQuotedASCII:
            return YAML::EscapeNonAscii;
    }
    YAML_WARNING(style, "Unsupported style %td", style);
    return YAML::EmitNonAscii; // Default.
}

- (YAML::EMITTER_MANIP)integerBaseManipulatorForStyle:(YAMLStyleInteger)style {
    switch (style) {
        case YAMLStyleInteger_Decimal:
            return YAML::Dec;
            
        case YAMLStyleInteger_Hexadecimal:
            return YAML::Hex;
            
        case YAMLStyleInteger_Octal:
            return YAML::Oct;
    }
    YAML_WARNING(style, "Unsupported style %td", style);
    return YAML::Dec; // Default.
}

- (YAML::EMITTER_MANIP)arrayFormatManipulatorForStyle:(YAMLStyleArray)style {
    switch (style) {
        case YAMLStyleArray_Block:
            return YAML::Block;
        
        case YAMLStyleArray_Flow:
            return YAML::Flow;
    }
    YAML_WARNING(style, "Unsupported style %td", style);
    return YAML::Block; // Default.
}

- (YAML::EMITTER_MANIP)dictionaryFormatManipulatorForStyle:(YAMLStyleDictionary)style {
    switch (style) {
        case YAMLStyleDictionary_Block:
        case YAMLStyleDictionary_BlockLongKeys:
            return YAML::Block;
            
        case YAMLStyleDictionary_Flow:
            return YAML::Flow;
    }
    YAML_WARNING(style, "Unsupported style %td", style);
    return YAML::Block; // Default.
}

- (YAML::EMITTER_MANIP)dictionaryKeyFormatManipulatorForStyle:(YAMLStyleDictionary)style {
    switch (style) {
        case YAMLStyleDictionary_Block:
        case YAMLStyleDictionary_Flow:
            return YAML::Auto;
            
        case YAMLStyleDictionary_BlockLongKeys:
            return YAML::LongKey;
    }
    YAML_WARNING(style, "Unsupported style %td", style);
    return YAML::Auto; // Default.
}

- (int)validateIndentation:(NSUInteger)spaces {
    if (YAML_WARNING(spaces < 2, "Indentation too low: %tu", spaces)) {
        return 2; // Minimum.
    }
    if (YAML_WARNING(spaces > 100, "Indentation is ridiculous: %tu", spaces)) {
        return 2; // Default.
    }
    return (int)spaces;
}

- (int)validateCommentSpacing:(NSUInteger)spaces {
    if (YAML_WARNING(spaces < 1, "There must be at least one space: %tu", spaces)) {
        return 1; // Minimum.
    }
    if (YAML_WARNING(spaces > 100, "Spacing is ridiculous: %tu", spaces)) {
        return 2; // Default.
    }
    return (int)spaces;
}

- (int)validateFloatPrecision:(NSUInteger)precision {
    // Not a warning, since we use primarily `double` type.
    // FLT_DIG is 6
    if (precision > 7) {
        return 7; // Maximum.
    }
    return (int)precision;
}

- (int)validateDoublePrecision:(NSUInteger)precision {
    // DBL_DIG is 15
    if (YAML_WARNING(precision > 16, "Precision too large: %tu", precision)) {
        return 16; // Maximum.
    }
    return (int)precision;
}

@end

