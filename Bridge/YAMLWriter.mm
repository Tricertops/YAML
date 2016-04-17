//
//  YAMLWriter.mm
//  YAML
//
//  Created by Martin Kiss on 16.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//

#import <YAMLCore/YAMLCore.h>
#import "YAMLWriter.h"
#import "YAMLFileDescriptorOutputBuffer.h"


#pragma mark - Private Properties

@interface YAMLWriter ()

@property (readonly) YAML::Emitter *emitter;

@end


#pragma mark - Base Implementation

@implementation YAMLWriter

- (void)dealloc {
    delete self->_emitter;
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
    
    if (YAML_WARNING(fileHandle == nil, @"Failed to create %@ for URL ‘%@’: %@", NSFileHandle.class, fileURL, error.localizedDescription)) {
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

