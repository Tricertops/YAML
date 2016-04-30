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


#pragma mark - Global Style

// Since YAML::Emitter doesn’t expose these properties for reading, we store their copies.
// If the underlaying emitter changes them in other way than these setters, we may have irrelevant values.

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


#pragma mark - Writing Methods

@implementation YAMLWriter (WritingMethods)


//MARK: Raw Emitting

- (void)applyLocalIndentation:(NSUInteger)spaces {
    *(self->_emitter) << YAML::Indent([self validateIndentation:spaces]);
}

- (void)applyLocalNumberPrecision:(NSUInteger)precision {
    *(self->_emitter) << YAML::FloatPrecision([self validateFloatPrecision:precision]);
    *(self->_emitter) << YAML::DoublePrecision([self validateDoublePrecision:precision]);
}

- (void)emitManipulator:(YAML::EMITTER_MANIP)manipulator {
    *(self->_emitter) << manipulator;
}

- (void)emitString:(nonnull NSString *)string {
    YAML_UNEXPECTED(string == nil);
    
    *(self->_emitter) << string.UTF8String;
}

- (void)emitBoolean:(BOOL)boolean {
    YAML_WARNING(boolean != NO && boolean != YES);
    
    *(self->_emitter) << (bool)boolean;
}

- (void)emitInteger:(NSInteger)integer {
    *(self->_emitter) << integer;
}

- (void)emitDouble:(double)number {
    *(self->_emitter) << number;
}

- (void)emitNull {
    *(self->_emitter) << YAML::Null;
}

- (void)emitData:(nonnull NSData *)data {
    YAML_UNEXPECTED(data == nil);
    
    *(self->_emitter) << YAML::Binary((const unsigned char *)data.bytes, (std::size_t)data.length);
}

- (void)emitComment:(nonnull NSString *)comment {
    YAML_UNEXPECTED(comment == nil);
    YAML_WARNING(comment.length == 0, "Empty comment");
    
    *(self->_emitter) << YAML::Comment(comment.UTF8String);
}

- (void)emitAnchor:(nonnull NSString *)name {
    YAML_UNEXPECTED(name == nil);
    YAML_WARNING(name.length == 0, "Empty anchor name");
    
    *(self->_emitter) << YAML::Anchor(name.UTF8String);
}

- (void)emitAlias:(nonnull NSString *)name {
    YAML_UNEXPECTED(name == nil);
    YAML_WARNING(name.length == 0, "Empty alias name");
    
    *(self->_emitter) << YAML::Alias(name.UTF8String);
}

- (void)emitTag:(YAML::_Tag)tag {
    YAML_WARNING(tag.content.length() == 0, "Empty tag content");
    
    *(self->_emitter) << tag;
}


//MARK: Convenience

- (BOOL)checkAndReturnError:(YAML_ERROR_TYPE)error {
    if (error != nil) {
        *error = self.error;
    }
    return self->_emitter->good();
}

- (YAML::_Tag)tagWithKind:(YAMLTagKind)kind name:(nonnull NSString *)name {
    YAML_UNEXPECTED(name == nil);
    
    switch (kind) {
        case YAMLTagKind_Verbatim: {
            std::string cpp_name = name.UTF8String;
            return YAML::VerbatimTag("!" + cpp_name);
        }
        case YAMLTagKind_BuiltIn:
            return YAML::SecondaryTag(name.UTF8String);
        case YAMLTagKind_UserDefined:
            return YAML::LocalTag(name.UTF8String);
    }
    
    YAML_UNEXPECTED(kind, "Unsupported kind: %td", kind);
    return YAML::LocalTag("");
}


//MARK: Writing Document

- (BOOL)beginDocumentWithError:(YAML_ERROR_TYPE)error {
    [self emitManipulator:YAML::BeginDoc];
    return [self checkAndReturnError:error];
}

- (BOOL)endDocumentWithError:(YAML_ERROR_TYPE)error {
    [self emitManipulator:YAML::EndDoc];
    return [self checkAndReturnError:error];
}

- (BOOL)writeDocument:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block error:(YAML_ERROR_TYPE)error {
    YAML_UNEXPECTED(block == nil);
    
    return YES
    && [self beginDocumentWithError:error]
    && block()
    && [self endDocumentWithError:error];
}


//MARK: Writing Array (Sequence)

- (BOOL)beginArrayWithError:(YAML_ERROR_TYPE)error {
    [self emitManipulator:YAML::BeginSeq];
    return [self checkAndReturnError:error];
}

- (BOOL)beginArrayWithStyle:(YAMLStyleArray)style error:(YAML_ERROR_TYPE)error {
    [self emitManipulator:[self arrayFormatManipulatorForStyle:style]];
    return [self beginArrayWithError:error];
}

- (BOOL)beginArrayWithStyle:(YAMLStyleArray)style indentation:(NSUInteger)spaces error:(YAML_ERROR_TYPE)error {
    [self applyLocalIndentation:spaces];
    return [self beginArrayWithStyle:style error:error];
}

- (BOOL)endArrayWithError:(YAML_ERROR_TYPE)error {
    [self emitManipulator:YAML::EndSeq];
    return [self checkAndReturnError:error];
}

- (BOOL)writeArray:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block error:(YAML_ERROR_TYPE)error {
    YAML_UNEXPECTED(block == nil);
    
    return YES
    && [self beginArrayWithError:error]
    && block()
    && [self endArrayWithError:error];
}


//MARK: Writing Dictionary (Map)

- (BOOL)beginDictionaryWithError:(YAML_ERROR_TYPE)error {
    [self emitManipulator:YAML::BeginMap];
    return [self checkAndReturnError:error];
}

- (BOOL)beginDictionaryWithStyle:(YAMLStyleDictionary)style error:(YAML_ERROR_TYPE)error {
    [self emitManipulator:[self dictionaryFormatManipulatorForStyle:style]];
    [self emitManipulator:[self dictionaryKeyFormatManipulatorForStyle:style]];
    return [self beginDictionaryWithError:error];
}

- (BOOL)beginDictionaryWithStyle:(YAMLStyleDictionary)style indentation:(NSUInteger)spaces error:(YAML_ERROR_TYPE)error {
    [self applyLocalIndentation:spaces];
    return [self beginDictionaryWithStyle:style error:error];
}

- (BOOL)endDictionaryWithError:(YAML_ERROR_TYPE)error {
    [self emitManipulator:YAML::EndMap];
    return [self checkAndReturnError:error];
}

- (BOOL)writeDictionary:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block error:(YAML_ERROR_TYPE)error {
    YAML_UNEXPECTED(block == nil);
    
    return YES
    && [self beginDictionaryWithError:error]
    && block()
    && [self endDictionaryWithError:error];
}

- (BOOL)expectKeyWithError:(YAML_ERROR_TYPE)error {
    [self emitManipulator:YAML::Key];
    return [self checkAndReturnError:error];
}

- (BOOL)expectKeyAsLong:(BOOL)longKey error:(YAML_ERROR_TYPE)error {
    [self emitManipulator:(longKey? YAML::LongKey : YAML::Auto)];
    return [self expectKeyWithError:error];
}

- (BOOL)expectValueWithError:(YAML_ERROR_TYPE)error {
    [self emitManipulator:YAML::Value];
    return [self checkAndReturnError:error];
}

- (BOOL)writeKey:(nonnull NSString *)key value:(nonnull YAMLWriterBlock YAML_NO_ESCAPE)block {
    YAML_UNEXPECTED(key == nil);
    YAML_UNEXPECTED(block == nil);
    
    return YES
    && [self expectKeyWithError:nil]
    && [self writeString:key error:nil]
    && [self expectValueWithError:nil]
    && block();
}


//MARK: Writing Scalars

- (BOOL)writeString:(nullable NSString *)string error:(YAML_ERROR_TYPE)error {
    if (string == nil) {
        [self writeNullWithError:error];
    }
    else {
        [self emitString:string];
    }
    return [self checkAndReturnError:error];
}

- (BOOL)writeString:(nullable NSString *)string style:(YAMLStyleString)style error:(YAML_ERROR_TYPE)error {
    [self emitManipulator:[self stringFormatManipulatorForStyle:style]];
    [self emitManipulator:[self stringCharsetManipulatorForStyle:style]];
    return [self writeString:string error:error];
}

- (BOOL)writeBoolean:(BOOL)boolean error:(YAML_ERROR_TYPE)error {
    [self emitBoolean:boolean];
    return [self checkAndReturnError:error];
}

- (BOOL)writeBoolean:(BOOL)boolean style:(YAMLStyleBoolean)style error:(YAML_ERROR_TYPE)error {
    [self emitManipulator:[self booleanFormatManipulatorForStyle:style]];
    [self emitManipulator:[self booleanCaseManipulatorForStyle:style]];
    [self emitManipulator:[self booleanLengthManipulatorForStyle:style]];
    return [self writeBoolean:boolean error:error];
}

- (BOOL)writeInteger:(NSInteger)integer error:(YAML_ERROR_TYPE)error {
    [self emitInteger:integer];
    return [self checkAndReturnError:error];
}

- (BOOL)writeInteger:(NSInteger)integer style:(YAMLStyleInteger)style error:(YAML_ERROR_TYPE)error {
    [self emitManipulator:[self integerBaseManipulatorForStyle:style]];
    return [self writeInteger:integer error:error];
}

- (BOOL)writeNumber:(double)number error:(YAML_ERROR_TYPE)error {
    [self emitDouble:number];
    return [self checkAndReturnError:error];
}

- (BOOL)writeNumber:(double)number precision:(NSUInteger)precision error:(YAML_ERROR_TYPE)error {
    [self applyLocalNumberPrecision:precision];
    return [self writeNumber:number error:error];
}

- (BOOL)writeNullWithError:(YAML_ERROR_TYPE)error {
    [self emitNull];
    return [self checkAndReturnError:error];
}

- (BOOL)writeData:(nullable NSData *)data error:(YAML_ERROR_TYPE)error {
    if (data == nil) {
        [self writeNullWithError:error];
    }
    else {
        [self emitData:data];
    }
    return [self checkAndReturnError:error];
}


//MARK: Writing Comments & Whitespace

- (BOOL)writeComment:(nonnull NSString *)comment error:(YAML_ERROR_TYPE)error {
    [self emitComment:comment];
    return [self checkAndReturnError:error];
}

- (BOOL)writeNewLineWithError:(YAML_ERROR_TYPE)error {
    [self emitManipulator:YAML::Newline];
    return [self checkAndReturnError:error];
}


//MARK: Writing Anchors & Aliases

- (BOOL)writeAnchor:(nonnull NSString *)name error:(YAML_ERROR_TYPE)error {
    [self emitAnchor:name];
    return [self checkAndReturnError:error];
}

- (BOOL)writeAlias:(nonnull NSString *)name error:(YAML_ERROR_TYPE)error {
    [self emitAlias:name];
    return [self checkAndReturnError:error];
}


//MARK: Writing Tags

- (BOOL)writeTagURI:(nonnull NSString *)URI error:(YAML_ERROR_TYPE)error {
    [self emitTag:YAML::VerbatimTag(URI.UTF8String)];
    return [self checkAndReturnError:error];
}

- (BOOL)writeTag:(nonnull NSString *)name kind: (YAMLTagKind)kind error:(YAML_ERROR_TYPE)error {
    [self emitTag:[self tagWithKind:kind name:name]];
    return [self checkAndReturnError:error];
}


@end

