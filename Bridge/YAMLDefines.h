//
//  YAMLDefines.h
//  YAML Bridge
//
//  Created by Martin Kiss on 16 April 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//

#import <Foundation/Foundation.h>


#pragma mark Annotations

#define YAML_EXTERN \
    FOUNDATION_EXTERN

#define YAML_UNAVAILABLE(msg) \
    __attribute__((unavailable(msg)))

#define YAML_NO_ESCAPE \
    __attribute__((noescape))

#define YAML_SWIFT_NAME(name) \
    NS_SWIFT_NAME(name)

#define YAML_ENUM(name) \
    typedef NS_ENUM(NSInteger, name)

#define YAML_ENUM_ANONYMOUS \
    NS_ENUM(NSInteger)


#pragma mark Validation

#define YAML_UNEXPECTED(condition, message...) \
    ( (void) ({ \
        if (!!(condition)) { \
            _YAMLPrintValidationMessage(__PRETTY_FUNCTION__, __LINE__, @"Unexpected", #condition, @"" message); \
            abort(); \
        } \
    }) )

#define YAML_WARNING(condition, message...) \
    ( (BOOL) ({ \
        BOOL __result = !!(condition); \
        if (__result) { \
            _YAMLPrintValidationMessage(__PRETTY_FUNCTION__, __LINE__, @"Warning", #condition, @"" message); \
        } \
        __result; \
    }) )


#pragma mark Types

#define YAML_ERROR_TYPE \
    NSError * _Nullable * _Nullable

typedef BOOL (^YAMLWriterBlock)(void);


#pragma mark - Errors

extern NSString * const YAMLErrorDomain;

YAML_ENUM_ANONYMOUS {
    YAMLErrorNone = 0,
    YAMLErrorWriter,
};


#pragma mark - Internal

YAML_EXTERN void _YAMLPrintValidationMessage(const char *function, int line, NSString *label, const char *code, NSString *message, ...) NS_FORMAT_FUNCTION(5, 6);
