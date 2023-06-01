//
//  FileManager+.swift
//  
//
//  Created by p-x9 on 2023/05/29.
//  
//

import Foundation

extension FileManager {
    func isDirectory(_ path: String) -> Bool {
        var isDir: ObjCBool = false
        if fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue {
                return true
            }
        }
        return false
    }

    func isDirectory(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        if fileExists(atPath: url.path, isDirectory: &isDir) {
            if isDir.boolValue {
                return true
            }
        }
        return false
    }
}

extension FileManager {
    // swiftlint:disable:next discouraged_optional_collection
    func createDirectoryIfNotExisted(at url: URL, withIntermediateDirectories: Bool, attributes: [FileAttributeKey: Any]? = nil) throws {
        guard !self.fileExists(atPath: url.path) else {
            return
        }

        try self.createDirectory(at: url,
                                 withIntermediateDirectories: withIntermediateDirectories,
                                 attributes: attributes)
    }

    // swiftlint:disable:next discouraged_optional_collection
    func createDirectoryIfNotExisted(atPath path: String, withIntermediateDirectories: Bool, attributes: [FileAttributeKey: Any]? = nil) throws {
        guard !self.fileExists(atPath: path) else {
            return
        }

        try self.createDirectory(atPath: path,
                                 withIntermediateDirectories: withIntermediateDirectories,
                                 attributes: attributes)
    }

}
