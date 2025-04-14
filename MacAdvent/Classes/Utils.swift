//
//  Utiles.swift
//  MacAdvent
//
//  Created by Andy Stobirski on 07/04/2025.
//

import Foundation
import Cocoa

class Utils {
    
    public static func Summary()
    {
        let directoryPath = "/Users/andystobirski/Downloads/SAGA-Hint-Sheets/"
        let fileManager = FileManager.default
        
    
        var Output: [String] = []
        
        
        let Spoiler = "<details><summary>Answer</summary>%@</details>"
    
        do {
            // Get the contents of the directory
            let files = try fileManager.contentsOfDirectory(atPath: directoryPath)
            
            // Filter for .txt files
            let txtFiles = files.filter { $0.hasSuffix(".txt") }
            
            // Iterate through each .txt file
            for txtFile in txtFiles {
                let filePath = directoryPath + txtFile
                
                // Read the contents of the file
                if let content = try? String(contentsOfFile: filePath, encoding: .utf8) {
                    
                    // load the entire file into an array
                    let data = content.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter{ $0 != ""}  // trim swhitespace
                    
                    let dicloc = data.firstIndex(where: { $0.hasPrefix("* DICTIONARY *") }) ?? 0
                    
                    // Build dictionary
                    var dictionary: [(Int, String)] = []
                    var ctr:Int = dicloc + 1
                    while ctr < data.count
                    {
                        let components = data[ctr].split(whereSeparator: { $0.isWhitespace }).map(String.init)
                        for index in stride(from: 0, to: components.count, by: 2) {
                            if index + 1 < components.count,
                               let number = Int(components[index]) {
                                let text = components[index + 1]
                                dictionary.append((number, text))
                            }
                        }
                        ctr += 1
                    }
                    
                    // Output to file
                    Output = []
                    

                    let characterSet = CharacterSet(charactersIn: "* ").union(.whitespacesAndNewlines)
                    let title = data[0].trimmingCharacters(in: characterSet)

                    Output += ["# " + title]
                    
                    let qpattern = #"^\d+\s*-"#
                    ctr = 1
                    var qctr = 0
                    while ctr < dicloc
                    {
                        let line = data[ctr]
                        if line.range(of: qpattern, options: .regularExpression) != nil {
                            Output += [""]
                            Output += [qctr == 0 ? "## \(line)" : "**\(line)**"]
                            qctr += 1
                            
                            // the next line is a string of numbers
                            
                            var answer:[String]  = []
                            ctr += 1
                            while  !data[ctr].contains("-")
                            {
                                answer += data[ctr].split(separator: " ").map(String.init)
                                ctr += 1
                            }
                            
                            
                            
                            var answer1:[String]  = []
                            
                            answer.forEach{ num in
                                
                                answer1 += [
                                    
                                    dictionary.filter{$0.0 == Int(num)}.first?.1 ?? "N/A"
                                    
                                ]
                            }
                            
                            Output += [String(format: Spoiler, answer1.joined(separator: " "))]
                            
                            ctr -= 1
                        }
                        

                        if (qctr == 3)
                        {
                            qctr = 0
                            Output += [""]
                            Output += ["---"]
                            Output += [""]
                        }
                        
                        ctr += 1
                    }
                    
                    do{
                        
                        let nsFileName = NSString(string: txtFile)
                        let pOutput = directoryPath + "\(nsFileName.deletingPathExtension) \(title).md"
                        let fileURL = URL(fileURLWithPath : pOutput)
                        let content = Output.joined(separator: "\n")
                        try  content.write(to: fileURL, atomically: true, encoding: .utf8)
                    } catch {
                        print("Error encoding user to JSON or writing to file: \(error)")
                    }
                    
                    
                } else {
                    print("Failed to read \(txtFile)")
                }
            }
        } catch {
            print("Error reading directory: \(error)")
        }

    }
 
    public static func saveFile(completion: @escaping (URL?) -> Void) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        
        // Specify allowed content types
        savePanel.allowedContentTypes = [
            .plainText, 
            .json
        ]
        
        savePanel.begin { response in
            if response == .OK {
                completion(savePanel.url)
            } else {
                completion(nil)
            }
        }
    }
    
    public static func pickFile( completion: @escaping (URL?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        
        openPanel.begin { response in
            if response == .OK {
                completion(openPanel.url)
            } else {
                completion(nil)
            }
        }
    }
    
    // Encode into JSON the provided item to the specified URL
    public static func SaveAsJSON<T: Encodable>(item: T, fileURL: URL) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
            
            let jsonData = try encoder.encode(item)
            
            try jsonData.write(to: fileURL)
            print("Data saved successfully to \(fileURL).")
            
        } catch {
            print("Error encoding item to JSON or writing to file: \(error)")
        }
    }
    
    // Decode from JSON the item at URL
    public static func DecodeFromJSON<T: Decodable>(fileURL: URL, as type: T.Type) -> T? {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            
            let decodedItem = try decoder.decode(T.self, from: data)
            print("Data loaded successfully from \(fileURL).")
            return decodedItem
            
        } catch {
            print("Error decoding JSON or loading from file: \(error)")
            return nil
        }
    }
    
}
