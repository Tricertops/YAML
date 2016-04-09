//
//  YAMLCore.mm
//  YAML Core
//
//  Created by Martin Kiss on 9.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wextra-semi"

#import "yaml-cpp/yaml.h"

#pragma clang diagnostic pop



@interface YAMLCore : NSObject

@end


@implementation YAMLCore

+ (void)link {
    YAML::LoadAll("");
}

@end

