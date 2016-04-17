//
//  YAMLFileDescriptorOutputBuffer.h
//  YAML Bridge
//
//  Created by Martin Kiss on 17 April 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//
//  Inspired by http://www.josuttis.com/cppcode/fdstream.hpp
//  Copyright © 2001 Nicolai M. Josuttis
//
//    Permission to copy, use, modify, sell and distribute this software
//    is granted provided this copyright notice appears in all copies.
//    This software is provided "as is" without express or implied
//    warranty, and with no claim as to its suitability for any purpose.
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

