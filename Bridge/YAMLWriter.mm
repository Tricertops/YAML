//
//  YAMLWriter.mm
//  YAML
//
//  Created by Martin Kiss on 16.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//

#import <YAMLCore/YAMLCore.h>
#import "YAMLWriter.h"


@implementation YAMLWriter

+ (BOOL)test {
    YAML::Emitter emitter;
    
    emitter << YAML::Null;
    
    NSLog(@"YAML:\n%@", @(emitter.c_str()));
    return emitter.good();
}

@end

