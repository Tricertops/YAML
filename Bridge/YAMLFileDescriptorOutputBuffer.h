//
//  YAMLFileDescriptorOutputBuffer.h
//  YAML
//
//  Created by Martin Kiss on 17.4.16.
//  Copyright © 2016 Tricertops. All rights reserved.
//


class YAMLFileDescriptorOutputBuffer : public std::streambuf {
public:
    YAMLFileDescriptorOutputBuffer (int fileDescriptor) : fileDescriptor(fileDescriptor) {}
    int fileDescriptor;
protected:
    virtual int_type overflow(int_type character) {
        if (character != traits_type::eof()) {
            std::streamsize length = 1;
            if (write(fileDescriptor, &character, length) != length) {
                return traits_type::eof();
            }
        }
        return character;
    }
    virtual std::streamsize xsputn(const char_type *string, std::streamsize length) {
        return write(fileDescriptor, string, length);
    }
};


class YAMLFileDescriptorOutputStream : public std::ostream {
protected:
    YAMLFileDescriptorOutputBuffer buffer;
public:
    YAMLFileDescriptorOutputStream (int fileDescriptor) : std::ostream(0), buffer(fileDescriptor) {
        rdbuf(&buffer);
    }
};

