//
//  ConvertDat.swift
//
//  Data is either a string or a number. The string is defined by a pair
//  of inverted commas, which can span multiple lines
//
//  Created by Andy Stobirski on 19/03/2025.
//

import Foundation


class ConvertDat {
    
    static var Position = 0
    static var GameData: [String] = []
    
    private static func Left(_ string: String, n: Int) -> String {
        guard n >= 0 else { return "" }
        return String(string.prefix(n))
    }
    
    private static func Right(_ string: String, n: Int) -> String {
        guard n >= 0 else { return "" }
        return String(string.suffix(n))
    }
    
    private static func countOccurrences(of substring: String, in text: String) -> Int {
        guard !substring.isEmpty else { return 0 }
        let components = text.components(separatedBy: substring)
        return components.count - 1
    }
    
    private static func trimWhitespace(from input: String) -> String {
        return input.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private static func trimCharacter(input: String, trimCharacter: String) -> String {
        return input.trimmingCharacters(in: CharacterSet(charactersIn: trimCharacter))
    }
    
    //  Populate the array with discrete data units
    private static func PopulateGameData(pGame: String) {
        let data = pGame.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }  // trim swhitespace
        
        var line = ""
        var ctr = 0
        let arrLength = data.count
        
        while ctr < arrLength {
            
            if Left(data[ctr], n: 1) == "\""
            {
                line=""
                repeat {
                    line += (data[ctr] + "\n")
                    ctr += 1
                } while countOccurrences(of: "\"", in: line) < 2
                
                line = trimWhitespace(from: line)
                if Left(line, n: 1) == "\"" && Right(line, n: 1) == "\""
                {
                    //if the string begins and ends with " trim them off
                    line = String(line.dropFirst().dropLast())
                }
                GameData+=[line]
            }
            else
            {
                GameData+=[data[ctr]]
                ctr += 1
            }
        }
    }
    
    static func GetNItems(_ n: Int) -> [String] {
        let arr =  Array(GameData[Position..<Position+n])
        Position+=n
        return arr
    }
    
    // You'll never guess what this does
    static func convertStringsToInts(_ stringArray: [String]) -> [Int] {
        return stringArray.compactMap { Int($0) }
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Return the first match of the regex
    static func firstMatch(for pattern: String, in input: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(input.startIndex..., in: input)
            
            if let match = regex.firstMatch(in: input, options: [], range: range) {
                let matchRange = match.range(at: 0) // Get the full match
                if let range = Range(matchRange, in: input) {
                    return String(input[range]) // Return the matching string
                }
            }
        } catch {
            print("Invalid regex pattern: \(error)")
        }
        return "" // No match found
    }
    
    
    //
    //  Convert the sring representing the dat file into a DatFile class
    //
    static func Load(pGame: String) -> DatFile{
   
        PopulateGameData(pGame: pGame)
        
        let datFile = DatFile()
        
        // Header
        let header = GetNItems(12)
        datFile.Header = DatFile.gameHeader(pVals: convertStringsToInts(header))
        
        var ctr = 0
        
        //
        // Actions
        //
        var action: DatFile.Action!
        while ctr < datFile.Header.numActions {
            action = DatFile.Action(actions: convertStringsToInts(GetNItems(8)))
            action.Index = ctr
            datFile.Actions+=[action]
            ctr+=1
        }
        
        //
        // Words
        //
        
        var verbsRAW: [String] = [] //Only used in building comments for the action
        var nounsRAW: [String] = [] //Only used in building comments for the action
        
        var Words = GetNItems(datFile.Header.numNounVerbs * 2)
        Words.removeFirst(2)
        ctr = 0
        var verbCtr = 0
        var nounCtr = 0
        Words.forEach {worditem in
            
            if Left(worditem, n: 1) == "*" { //synonym
                
                let alias = String(worditem.dropFirst())
                
                if ctr % 2 == 0 {
                    if  let V = datFile.Verbs.last
                    {
                        V.Aliases += [alias]
                        verbsRAW+=[worditem]
                    }
                } else {
                    if  let N = datFile.Nouns.last
                    {
                        N.Aliases += [alias]
                        nounsRAW+=[worditem]
                    }
                }
            }
            else
            {
                let word = DatFile.Word(word: worditem)
                if ctr % 2 == 0 {
                    verbsRAW+=[worditem]
                    datFile.Verbs += [word]
                    word.Index = verbCtr
                    verbCtr+=1
                } else {
                    nounsRAW+=[worditem]
                    datFile.Nouns += [word]
                    word.Index = nounCtr
                    nounCtr+=1
                }
            }
            ctr+=1
        }
        
        //
        //  Rooms
        //
        ctr = 0
        var room: DatFile.Room        
        while ctr < datFile.Header.numRooms {
            
            room = DatFile.Room(pRoomExits : convertStringsToInts(GetNItems(6)), pDescription: GetNItems(1).first ?? "")
            datFile.Rooms += [room]
            ctr+=1
            
        }
        
        //
        //  Messages
        //
        let Messages = GetNItems(datFile.Header.numMessages)
        Messages.forEach {message in
            datFile.Messages+=[message]
        }
        
        //
        //  Items
        //
        let Items = GetNItems(datFile.Header.numItems)
        var indexctr = 0
        Items.forEach {item in
            
            let itemDescription = trimCharacter( input: firstMatch(for: "\"([^\"/]*)", in: item), trimCharacter: "\"")
            let getDrop =  trimCharacter( input: firstMatch(for: "/([^/]+)/" , in: item), trimCharacter: "/")
            let roomID = firstMatch(for: "(\\d+)$", in: item)
            let item = DatFile.Item(pRoomID: Int(roomID) ?? 0, pDescription: itemDescription, pGetDrop: getDrop)
            
            item.Index = indexctr
            indexctr+=1
            datFile.Items += [item]
        }
        
        //
        //  Action Comments
        //
        let ActionComments = GetNItems(datFile.Header.numActions)
        ctr = 0
        ActionComments.forEach {actionComment in
            if (actionComment.count > 0)
            {
                let Action = datFile.Actions[ctr]
                Action.Comment += [actionComment]
            }
            ctr+=1
        }
        
        //
        //  Update every action with descriptions for its condition and action components
        //
        
        datFile.Actions.forEach {action in
            
            print (action.Index, action.Comment.first ?? "")
            
            
            if action.Index == 34
            {
                print ("STOP")
            }
            
            if action.Verb > 0 {
                
                action.Comment += [String(format: "User command: %@ %@", verbsRAW[action.Verb], action.Noun > 0 ? nounsRAW[action.Noun] : "")]
            }
            else
            {
                action.Comment += [String(format: "Probability: %d",action.Noun)]
            }
            
            if (action.Conditions.count > 0)
            {
                action.Comment += ["if"]
                
                action.Conditions.forEach {condition in
                    
                    var con = Resources.conditions[condition.ItemID]
                    con = "\t\(con)"
                    
                    if Resources.conditionsWithItems.contains(condition.ItemID)
                    {
                        con = con.replacingOccurrences(of: "arg", with: datFile.Items[condition.ArgID.first ?? 0].Description)
                    }
                    else if con.range(of: "arg") != nil {
                        
                        con = con.replacingOccurrences(of: "arg", with: String(condition.ArgID.first ?? 0))
                        
                    }
                    
                    action.Comment += [con]
                    
                }
            }

        }
        
        
        
        //
        //  write the class to a JSON object
        //
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted] // Enable pretty printing
            let jsonData = try encoder.encode(datFile)
            let fileURL = getDocumentsDirectory().appendingPathComponent("adv01.json")
            try jsonData.write(to: fileURL)

        } catch {
            print("Error encoding user to JSON or writing to file: \(error)")
        }
        
        return datFile
        
    }
}
