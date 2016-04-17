//
//  YAMLDefines.mm
//  YAML Bridge
//
//  Created by Martin Kiss on 17 April 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//

#import "YAMLDefines.h"


NSString * const YAMLErrorDomain = @"YAMLErrorDomain";


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
