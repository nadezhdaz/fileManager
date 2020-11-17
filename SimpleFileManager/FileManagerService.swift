//
//  FileManagerService.swift
//  SimpleFileManager
//
//  Created by Надежда Зенкова on 23.09.2020.
//  Copyright © 2020 Надежда Зенкова. All rights reserved.
//

import UIKit

struct File: Comparable {
    static func < (lhs: File, rhs: File) -> Bool {
        return lhs.name < rhs.name
    }

    var name: String
    var path: String
    var isDirectory: Bool
}

class FileManagerService {
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    func getListOfFiles(from directory: String) -> [File?] {
        var contents = [File]()
        var sortedUrls = [URL]()
        var directoryURL: URL?
        if directory == "Documents" {
            directoryURL = documentsDirectory
        }
        else {
            if let documents = documentsDirectory {
                let directoryPath = documents.path + "/" + directory
                directoryURL = URL(fileURLWithPath: directoryPath)
            }
            
        }
        
        if let directory = directoryURL, let directoryContents = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles) {
            
            sortedUrls = directoryContents.sorted(by: {
                guard let urlAIsDirectory = try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory else { return false }
                guard let urlBIsDirectory = try? $1.resourceValues(forKeys: [.isDirectoryKey]).isDirectory else { return false }
                
                let nameA = $0.deletingPathExtension().lastPathComponent
                let nameB = $1.deletingPathExtension().lastPathComponent
                
                if urlAIsDirectory != urlBIsDirectory {
                    return urlAIsDirectory ? true : false
                } else {
                    return nameA < nameB
                }
                
            })
            
            for url in sortedUrls {
                contents.append(File(name: url.deletingPathExtension().lastPathComponent, path: url.path, isDirectory: isDirectory(url: url)))
            }
            
        }
        
        return contents
    }
    
    func writeFile(containing: String?, to directory: String, withName name: String) {
        guard let documents = documentsDirectory else { return }
        let directoryName = directory == "Documents" ? "" : directory
        let filePath = documents.path + "/" + directoryName + "/" + name
        let rawData: Data? = containing?.data(using: .utf8)
        FileManager.default.createFile(atPath: filePath, contents: rawData, attributes: nil)
    }
    
    func readFile(at directory: String, withName name: String) -> String? {
        guard let documents = documentsDirectory else { return nil }
        let directoryName = directory == "Documents" ? "" : directory
        let filePath = documents.path + "/" + directoryName + "/" + name
        //let filePath = documents.path + "/" + directory + "/" + name
        
        guard let fileContent = FileManager.default.contents(atPath: filePath),
            let fileContentEncoded = String(bytes: fileContent, encoding: .utf8) else {
                return nil
        }
        
        return fileContentEncoded
    }
    
    func deleteFile(at path: String?) {
        guard let path = path else { return }
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }
    
    func createDirectory(withName name: String, in parentDirectory: String) {
        guard let documents = documentsDirectory else { return }
        let parentDirectoryName = parentDirectory == "Documents" ? "" : parentDirectory
        let directoryPath = documents.path + "/" + parentDirectoryName + "/" + name
        
        do {
            try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }
    
    private func isDirectory(url: URL) -> Bool {
        let values = try? url.resourceValues(forKeys: [.isDirectoryKey])
        return values?.isDirectory ?? false
    }
}
