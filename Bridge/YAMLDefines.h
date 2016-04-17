//
//  YAMLDefines.h
//  YAML
//
//  Created by Martin Kiss on 16.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//

#import <Foundation/Foundation.h>


#define YAML_UNAVAILABLE(msg) \
    __attribute__((unavailable(msg)))

#define YAML_WRITEONLY_PROPERTY \
    YAML_UNAVAILABLE("This property is write-only.")

#define YAML_NO_ESCAPE \
    __attribute__((noescape))

#define YAML_SWIFT_NAME(name) \
    NS_SWIFT_NAME(name)
