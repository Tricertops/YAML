//
//  YAMLWriter.mm
//  YAML Bridge
//
//  Created by Martin Kiss on 16 April 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
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


#pragma mark - Result Accessors

@implementation YAMLWriter (ResultAccessors)

- (NSUInteger)outputLength {
    return self->_emitter->size();
}

- (nonnull NSString *)outputString {
    return @(self->_emitter->c_str());
}

- (nullable NSError *)error {
    if (self->_emitter->good()) {
        return nil;
    }
    
    NSString *message = @(self->_emitter->GetLastError().c_str());
    return [NSError errorWithDomain:YAMLErrorDomain
                               code:YAMLErrorWriter
                           userInfo:@{ NSLocalizedDescriptionKey: message }];
}

@end
