//
//  YAMLDefines.h
//  YAML
//
//  Created by Martin Kiss on 16.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
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


#pragma mark Validation

#define YAML_UNEXPECTED(condition, message...) \
    ( (void) ({ \
        if (condition) { \
            _YAMLPrintValidationMessage(__PRETTY_FUNCTION__, __LINE__, @"Unexpected", #condition, @"" message); \
            abort(); \
        } \
    }) )

#define YAML_WARNING(condition, message...) \
    ( (BOOL) ({ \
        BOOL __result = (condition); \
        if (__result) { \
            _YAMLPrintValidationMessage(__PRETTY_FUNCTION__, __LINE__, @"Warning", #condition, @"" message); \
        } \
        __result; \
    }) )


#pragma mark Types

#define YAML_ERROR_TYPE \
    NSError * _Nullable * _Nullable

typedef BOOL (^YAMLWriterBlock)(void);


#pragma mark - Internal

YAML_EXTERN void _YAMLPrintValidationMessage(const char *function, int line, NSString *label, const char *code, NSString *message, ...) NS_FORMAT_FUNCTION(5, 6);
