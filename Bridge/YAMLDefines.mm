//
//  YAMLDefines.m
//  YAML
//
//  Created by Martin Kiss on 17.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//

#import "YAMLDefines.h"


void _YAMLPrintValidationMessage(const char *function, int line, NSString *label, const char *code, NSString *format, ...) {
    NSMutableString *log = [NSMutableString new];
    [log appendFormat:@"YAML: %s#%i  ", function, line];
    [log appendFormat:@"%@! “%s”", label ?: @"Invalid", code];
    
    va_list vargs;
    va_start(vargs, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:vargs];
    va_end(vargs);
    
    if (message.length) {
        [log appendFormat:@" – %@", message];
    }
    
    NSLog(@"%@", log); \
}
