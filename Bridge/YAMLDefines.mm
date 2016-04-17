//
//  YAMLDefines.m
//  YAML
//
//  Created by Martin Kiss on 17.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//

#import "YAMLDefines.h"


void _YAMLPrintUnexpectedMessage(const char *function, int line, const char *code, NSString *format, ...) {
    NSMutableString *log = [NSMutableString new];
    [log appendFormat:@"*** %s:%i  ", function, line];
    [log appendFormat:@"Unexpected “%s”", code];
    
    va_list vargs;
    va_start(vargs, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:vargs];
    va_end(vargs);
    
    if (message.length) {
        [log appendFormat:@": %@", message];
    }
    
    NSLog(@"%@", log); \
}
