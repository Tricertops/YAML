//
//  Version.swift
//  YAML.framework
//
//  Created by Martin Kiss on 1 May 2016.
//  https://github.com/Tricertops/YAML
//
//  The MIT License (MIT)
//  Copyright © 2016 Martin Kiss
//


///  Version information about all YAML components.
public struct Version {
    
    //MARK: Values
    
    ///  Version of the top-level Swift YAML framework.
    public static let Framework = Version(major: 1, minor: 0, patch: 0)
    
    ///  Version of the underlaying C library.
    public static let Library: Version = {
        var major: Int32 = 0
        var minor: Int32 = 0
        var patch: Int32 = 0
        yaml_get_version(&major, &minor, &patch)
        return Version(major: Int(major), minor: Int(minor), patch: Int(patch))
    }()
    
    ///  Version of the supported YAML specification.
    public static let YAML = Version(major: 1, minor: 1, string: "1.1")
    
    //MARK: Members
    
    ///  Version string of the form "major.minor.patch".
    public let string: String
    
    ///  Major version number.
    public let major: Int
    ///  Minor version number.
    public let minor: Int
    ///  Patch version number.
    public let patch: Int
    
    //MARK: Private
    
    ///  Private constructor.
    private init(major: Int, minor: Int = 0, patch: Int = 0, string: String? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.string = string ?? "\(major).\(minor).\(patch)"
    }
    
}
