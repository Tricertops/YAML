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
            _YAMLPrintUnexpectedMessage(__PRETTY_FUNCTION__, __LINE__, #condition, @"" message); \
            abort(); \
        } \
    }) )


#pragma mark Types

#define YAML_ERROR_TYPE \
    NSError * _Nullable * _Nullable

typedef BOOL (^YAMLWriterBlock)(void);


#pragma mark - Internal

YAML_EXTERN void _YAMLPrintUnexpectedMessage(const char *function, int line, const char *code, NSString *message, ...) NS_FORMAT_FUNCTION(4, 5);
