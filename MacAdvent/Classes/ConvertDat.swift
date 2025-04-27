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
        
        GameData = []
        Position = 0
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
        return ""
    }
    
    
    //
    //  Convert the sring representing the dat file into a DatFile class
    //
    static func Load(pGame: String) -> DatFile{
   
        PopulateGameData(pGame: pGame)
        
        let datFile = DatFile()
        
        //
        // Header
        //
        let header = GetNItems(12)
        datFile.Header = DatFile.gameHeader(pVals: convertStringsToInts(header))
        
        var ctr = 0
        
        //
        // Actions
        //
        var action: DatFile.Action!
        while ctr < datFile.Header.numActions {
            
            // some actions can be entirely empty, for example
            // in adv04, voodoo castle, actions 3, 4, 9, 13, 21, 22 and 24 are empty
            let a = convertStringsToInts(GetNItems(8))
            
            action = DatFile.Action(actions: a)
            action.Index = ctr
            datFile.Actions+=[action]
        
            ctr+=1
        }
        
        //
        // Words
        //
        var verbsRAW: [String] = [] //Only used in building comments for the action
        var nounsRAW: [String] = [] //Only used in building comments for the action
        
        let Words = GetNItems(datFile.Header.numNounVerbs * 2)
        //Words.removeFirst(2)
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
                        verbCtr+=1
                    }
                } else {
                    if  let N = datFile.Nouns.last
                    {
                        N.Aliases += [alias]
                        nounsRAW+=[worditem]
                        nounCtr+=1
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
            
            room = DatFile.Room(pRoomExits : convertStringsToInts(GetNItems(6)), pDescription: GetNItems(1).first ?? "", pIndex: ctr)
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
            let roomID = firstMatch(for: "(-?\\d+)$", in: item)
            let item = DatFile.Item(pRoomID: Int(roomID) ?? 0, pDescription: itemDescription, pGetDrop: getDrop, pIndex: indexctr)
            indexctr+=1
            datFile.Items += [item]
            
            if (getDrop != "")
            {
                
                // Generate take action
                let aTake = DatFile.Action()
                aTake.Index = datFile.Actions.count + 1
                aTake.Verb = Resources.Constants.verbTake.rawValue
                aTake.Noun = datFile.Nouns.first(where:{ $0.Word == getDrop || $0.Aliases.contains(getDrop)})!.Index
                //Item in room with player
                aTake.Conditions +=
                [
                    DatFile.Action.ActionComponent(ItemID: 1, ArgID: item.Index, Index: aTake.Conditions.count+1)
                ]
                //Take item, check if can carry
                aTake.Opcodes +=
                [
                    DatFile.Action.ActionComponent(ItemID: 52, ArgID: item.Index, Index: aTake.Opcodes.count+1)
                    , DatFile.Action.ActionComponent(ItemID: 64, ArgID: 0, Index: aTake.Opcodes.count+2)
                ]
                aTake.Comment = "Take for item \(item.Description)"
                datFile.Actions += [aTake]
                
                // Generate drop action
                let aDrop = DatFile.Action()
                aDrop.Index = datFile.Actions.count + 1
                aDrop.Verb = Resources.Constants.verbDrop.rawValue
                aDrop.Noun = aTake.Noun
                //Item carried by player
                aDrop.Conditions +=
                [
                    DatFile.Action.ActionComponent(ItemID: 0, ArgID: item.Index, Index: aTake.Conditions.count+1)
                ]
                //Drop item into current room
                aDrop.Opcodes +=
                [
                    DatFile.Action.ActionComponent(ItemID: 53, ArgID: item.Index, Index: aTake.Opcodes.count+1)
                    , DatFile.Action.ActionComponent(ItemID: 64, ArgID: 0, Index: aTake.Opcodes.count+2)
                ]
                aDrop.Comment = "Drop for item \(item.Description)"
                datFile.Actions += [aDrop]
            }
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
                Action.Comment = actionComment
            }
            ctr+=1
        }
    
        //
        //  Last three numbers - version, adventure number, unknown
        //
        let Last3 = GetNItems(3)
        datFile.Header.AdventureNumber = Int(Last3[1]) ?? 0
    
        
        //
        //  LOAD / SAVE game
        //
        
        var wrdSAV:String = "SAVE"
        var wrdLOA:String = "LOAD"
        var wrdGAM:String = "GAME"
        
        wrdSAV = String(wrdSAV.prefix(datFile.Header.wordLength))
        wrdLOA = String(wrdLOA.prefix(datFile.Header.wordLength))
        wrdGAM = String(wrdGAM.prefix(datFile.Header.wordLength))
        
        var SAV:DatFile.Word
        var LOA:DatFile.Word
        var GAM:DatFile.Word
        if !verbsRAW.contains(wrdSAV)
        {
            verbsRAW.append(wrdSAV)
            SAV = DatFile.Word(word: wrdSAV)
            SAV.Index = verbsRAW.count + 1
            datFile.Verbs += [SAV]
        }
        else
        {
            SAV = datFile.Verbs.filter { $0.Word == wrdSAV }.first ?? DatFile.Word(word: wrdSAV)
        }
        
        if !verbsRAW.contains(wrdLOA)
        {
            verbsRAW.append(wrdLOA)
            LOA = DatFile.Word(word: wrdLOA)
            LOA.Index = verbsRAW.count + 1
            datFile.Verbs += [LOA]
        }
        else
        {
            LOA = datFile.Verbs.filter { $0.Word == wrdLOA }.first ?? DatFile.Word(word: wrdLOA)
        }
        
        if !nounsRAW.contains(wrdGAM)
        {
            nounsRAW.append(wrdGAM)
            GAM = DatFile.Word(word: wrdGAM)
            GAM.Index = nounsRAW.count + 1
            datFile.Nouns += [GAM]
        }
        else
        {
            GAM = datFile.Nouns.filter { $0.Word == wrdGAM }.first ?? DatFile.Word(word: wrdGAM)
        }
        
        // Search for load game action
        if (datFile.Actions.filter{$0.Verb == LOA.Index && $0.Noun == GAM.Index}.count == 0)
        {
            let aLoad = DatFile.Action()
            aLoad.Verb = LOA.Index
            aLoad.Noun = GAM.Index
            aLoad.Comment = "Manually added load game action"
            aLoad.Index =  datFile.Actions.count + 1
            aLoad.Opcodes +=
            [
                DatFile.Action.ActionComponent(ItemID: 89, ArgID: 0, Index:0)
            ]
            datFile.Actions += [aLoad]
        }
        
        // Search for save game action
        if (datFile.Actions.filter{$0.Verb == SAV.Index && $0.Noun == GAM.Index}.count == 0)
        {
            let aSave = DatFile.Action()
            aSave.Verb = SAV.Index
            aSave.Noun = GAM.Index
            aSave.Comment = "Manually added save game action"
            aSave.Index =  datFile.Actions.count + 1
            aSave.Opcodes +=
            [
                DatFile.Action.ActionComponent(ItemID: 71, ArgID: 0, Index:0)
            ]
            datFile.Actions += [aSave]
        }
        
        
      
        
        
        return datFile
    }
    

    
    private static var OutPut: [String] = []
    
    private static func AddLine( pLine: String) {
        self.OutPut.append(pLine)
    }
    
    private static func AddHeading(pLevel: Int,  pLine: String) {
        self.OutPut.append("\((String(repeating: "#", count: pLevel)) + " ")\(pLine)")
    }
    
    private static func AddTableHeader(pHeaders: [String]) {
        var line: String = ""
        
        pHeaders.forEach {header in
            line += "| \(header)"
        }
        
        line += " |"
        self.OutPut.append(line)
        
        line = ""
        pHeaders.forEach {header in
            line += "| \(String(repeating: "-", count: header.count))"
        }
        line += " |"
        self.OutPut.append(line)
    }
    
    private static func AddTableRow( pItems: [String]) {
        
        var line: String = ""
        
        pItems.forEach {item in
            line += "| \(item)"
        }
        
        line += " |"
        self.OutPut.append(line)
        
    }

    private static func escapeMarkdown(_ input: String) -> String {
        let charactersToEscape: [Character] = ["\\", "*", "_", "{", "}", "[", "]", "(", ")", ".", "!", "#", "+", "-", ">", "=", "|", "~"]
        
        var escapedString = input
        
        for character in charactersToEscape {
            escapedString = escapedString.replacingOccurrences(of: String(character), with: "\\\(character)")
        }
        
        return escapedString.replacingOccurrences(of: "\n", with: " ")
    }
    
    // Build a GraphViz map of room
    static func OutputRoomMap(pOutput: URL, pDatFile: DatFile)
    {
        
        var DotFile:[String] = []
        
        DotFile += ["digraph G {"]
        DotFile += ["node [shape=rect];"]
        DotFile += ["ranksep=1.0;"]
        DotFile += ["nodesep=1.0;"]
        DotFile += ["splines=true;"]
    
        // Output the rooms
        pDatFile.Rooms.forEach{ room in
            if room.Index > 0
            {
                DotFile += ["\(room.Index) [label=\"\(room.Text)\" \(room.Index == pDatFile.Header.startRoom ? "style=filled color=lightgray" : "")];"]
            }
        }
                        
        // Output the standard conditions between rooms
        pDatFile.Rooms.forEach{ room in
            if (room.Index > 0)
            {
                room.Exits.enumerated().forEach { (index,exit) in
                    
                    if (exit > 0)
                    {
                        DotFile += ["\(room.Index) -> \(exit) [label=\"\(Resources.DirectionsLong[index])\" fontsize=10];"]
                    }
                }
            }
        }
        
        
        
        let Arrow = "%d -> %d [label=\"%@\" fontsize=10 color=blue];"
        // Now look for actions that move the player between rooms
        pDatFile.Actions.forEach{ action in
            
            if (action.Verb > 0)
            {
                if let opcode = action.Opcodes.filter({ $0.ID == 54}).first { //an action that moves between rooms
            
                    let dir = "\(pDatFile.Verbs.filter{$0.Index == action.Verb}.first!.Word) \(pDatFile.Nouns.filter{$0.Index == action.Noun}.first!.Word)"
                    
                    if let condition = action.Conditions.filter({$0.ID == 3}).first// player in room
                    {
                        
                        DotFile += [String(format: Arrow, condition.ArgID.first!, opcode.ArgID.first!, dir)]
                        
                        //DotFile += ["\(condition.ArgID.first!) -> \(opcode.ArgID.first!)  [label=\"\(dir)\" fontsize=10];"]
                    }//
                    else if let condition = action.Conditions.filter({$0.ID == 1}).first// Item in room with player
                    {
                        
                        let item = pDatFile.Items[condition.ArgID.first!]
                        
                        if (item.RoomID > 0)
                        {
                            // 0 is the inventory room, and an item may be be bought into the game
                            // as a result of player action, so exclude if 0
                            
                            DotFile += [String(format: Arrow, item.RoomID, opcode.ArgID.first!, dir)]
                            
                            //DotFile += ["\(item.RoomID) -> \(opcode.ArgID.first!)  [label=\"\(dir)\" fontsize=10];"]
                        }
                    }
                }
            }
        }
        
        
        // Close
        DotFile += ["}"]
        
        let content = DotFile.joined(separator: "\n")
        
        do{
            try  content.write(to: pOutput, atomically: true, encoding: .utf8)
        } catch {
            print("Error encoding user to JSON or writing to file: \(error)")
        }
        
    }
    
    // Output the provided DatFile as a GitHub MD file
    static func OutputAsMD(pOutput: URL, pDatFile: DatFile) {
        
        self.OutPut = []
        
        //
        //  Table of contents
        //
        AddHeading(pLevel: 1, pLine: pOutput.deletingPathExtension().lastPathComponent)
        AddLine(pLine: "*Table of Contents*")
        AddLine(pLine: "-[Header](#Header)")
        AddLine(pLine: "-[Actions](#Actions)")
        AddLine(pLine: "-[Verbs](#Verbs)")
        AddLine(pLine: "-[Nouns](#Nouns)")
        AddLine(pLine: "-[Rooms](#Rooms)")
        AddLine(pLine: "-[Messages](#Messages)")
        AddLine(pLine: "-[Items](#Items)")
        
        //
        //  Header
        //
        AddHeading(pLevel: 2, pLine: "Header")
        AddTableHeader(pHeaders: ["Property", "Value"])
        AddTableRow(pItems: ["adventureNumber", "\(pDatFile.Header.AdventureNumber)"])
        AddTableRow(pItems: ["Unknown", "\(pDatFile.Header.unknown)"])
        AddTableRow(pItems: ["numItems", "\(pDatFile.Header.numItems)"])
        AddTableRow(pItems: ["numActions", "\(pDatFile.Header.numActions)"])
        AddTableRow(pItems: ["numNounVerbs", "\(pDatFile.Header.numNounVerbs)"])
        AddTableRow(pItems: ["numRooms", "\(pDatFile.Header.numRooms)"])
        AddTableRow(pItems: ["maxCarry", "\(pDatFile.Header.maxCarry)"])
        AddTableRow(pItems: ["startRoom", "\(pDatFile.Header.startRoom)"])
        AddTableRow(pItems: ["totalTreasures", "\(pDatFile.Header.totalTreasures)"])
        AddTableRow(pItems: ["wordLength", "\(pDatFile.Header.wordLength)"])
        AddTableRow(pItems: ["lightDuration", "\(pDatFile.Header.lightDuration)"])
        AddTableRow(pItems: ["numMessages", "\(pDatFile.Header.numMessages)"])
        AddTableRow(pItems: ["treasureRoom", "\(pDatFile.Header.treasureRoom)"])
        
        //
        // Describe Actions
        //
        AddHeading(pLevel: 2, pLine: "Actions")
        pDatFile.Actions.forEach {action in
            
            var description = ""
            
            var n: String = ""
            var v: String = ""
            
            if action.Verb > 0 {
                
                n = pDatFile.Nouns.first {$0.Index == action.Noun}?.Word ?? ""
                v = pDatFile.Verbs.first {$0.Index == action.Verb}?.Word ?? ""
                description = String(format: "Input: %@ %@", v, n)
            }
            else
            {
                description = String(format: "Probability: %d %%",action.Noun)
                n = "\(action.Noun)%"
            }
            
            AddHeading(pLevel: 3, pLine: "Action \(action.Index) - " + (action.Comment == "" ? "" : action.Comment + " - ")  +  description)
            
            
            AddTableHeader(pHeaders: ["Property", "Value", "Comment"])
            AddTableRow(pItems: ["Original values", action.Contents.map{String($0)}.joined(separator: ", "),""])
            
            if action.Verb > 0
            {
                AddTableRow(pItems: ["Verb", String(action.Verb), v])
                AddTableRow(pItems: ["Noun", String(action.Noun), n])
            }
            else
            {
                AddTableRow(pItems: ["Probability", n, ""])
            }
        
            //build the comments for conditions
            if (action.Conditions.count > 0)
            {
                action.Conditions.forEach {condition in
                    
                    //print(condition.AsCondition())
                    
                    var con = Resources.conditions[condition.ID]

                    if Resources.ConditionsOneItem.contains(condition.ID)
                    {
                        con = String(format: con,  escapeMarkdown(pDatFile.Items[condition.ArgID.first ?? 0].Description) + "(index:\(condition.ArgID.first ?? 0))")
                    }
                    else if Resources.ConditionOneRoom.contains(condition.ID)
                        || Resources.ConditionOneInteger.contains(condition.ID)
                    {
                        con = String(format: con, condition.ArgID.first ?? 0 )
                    }
                    
                    AddTableRow(pItems: ["Condition", condition.AsCondition(), con])
                }
            }
            
             
            // built the comments for actions
            if action.Opcodes.count > 0 {
                
                action.Opcodes.sorted(by: { $0.Index < $1.Index }).forEach {comp in
                    var act = ""

                    if (comp.ID > 0 && comp.ID < 52)
                    {
                        act = String(format: "Print message '%@'", escapeMarkdown(pDatFile.Messages[comp.ID]))
                    }
                    else if (comp.ID > 101)
                    {
                        act = String(format: "Print message '%@'", escapeMarkdown(pDatFile.Messages[comp.ID-50]))
                    }
                    else
                    {
                        let actID = comp.ID - 52
                        
                        act = Resources.actions[actID]
                        
                        if Resources.ActionOneItem.contains(comp.ID)
                        {
                            act = String(format: act, pDatFile.Items[comp.ArgID[0]].Description + "(index:\(comp.ArgID[0]))")
                        }
                        else if Resources.ActionTwoItems.contains(comp.ID)
                        {
                            act = String(format: act, pDatFile.Items[comp.ArgID[0]].Description + "(index:\(comp.ArgID[0]))", pDatFile.Items[comp.ArgID[1]].Description + "(index:\(comp.ArgID[1]))")
                        }
                        else if Resources.ActionItemRoom.contains(comp.ID)
                        {
                            act = String(format: act, pDatFile.Items[comp.ArgID[0]].Description + "(index:\(comp.ArgID[0]))", comp.ArgID[1])
                        }
                        else if Resources.ActionRoom.contains(comp.ID)
                                    || Resources.ActionInteger.contains(comp.ID){
                            act = String(format: act, comp.ArgID[0])
                        }
                        else
                        {
                            //No args required
                        }
                    }
                    AddTableRow(pItems: ["Action", comp.AsAction(), act])
                }
            }
        }
        
        //
        // Words
        //
        AddHeading(pLevel: 2, pLine: "Words")
        AddHeading(pLevel: 3, pLine: "Verbs")
        
        AddTableHeader(pHeaders: ["Word", "Index", "Aliases"])
        pDatFile.Verbs.forEach { (verb) in
            AddTableRow(pItems: [escapeMarkdown(verb.Word),String(verb.Index),verb.Aliases.joined(separator: ", ")])
        }
        
        AddHeading(pLevel: 3, pLine: "Nouns")
        AddTableHeader(pHeaders: ["Word", "Index", "Aliases"])
        pDatFile.Nouns.forEach { (Noun) in
            AddTableRow(pItems: [escapeMarkdown(Noun.Word),String(Noun.Index),Noun.Aliases.joined(separator: ", ")])
        }
        
        
        //
        //  Rooms
        //
        AddHeading(pLevel: 2, pLine: "Rooms")
        AddTableHeader(pHeaders: ["Index", "Description", "Exits (RoomIDs)"])
        pDatFile.Rooms.enumerated().forEach { (index,room) in
            
            var Exits:[String] = []
            
            room.Exits.enumerated().forEach { (index,exit) in
               
                if (exit > 0)
                {
                    Exits += ["\(Resources.DirectionsLong[index]): \(exit)"]
                }
            }
            AddTableRow(pItems: [String(room.Index),escapeMarkdown(room.Text), Exits.joined(separator: ", ")  ])
        }
        
        //
        //  Messages
        //
        AddHeading(pLevel: 2, pLine: "Messages")
        AddTableHeader(pHeaders: ["Index", "Text"])
        pDatFile.Messages.enumerated().forEach { (index,message) in
            AddTableRow(pItems: [String(index),escapeMarkdown(message)])
        }
        
        //
        //  Items
        //
        AddHeading(pLevel: 2,  pLine: "Items")
        AddTableHeader(pHeaders: ["Index", "Description","GetDrop", "RoomID"])
        pDatFile.Items.forEach { item in
            AddTableRow(pItems: [String(item.Index),escapeMarkdown(item.Description), item.GetDrop ?? "", String(item.RoomID)])
        }
        
        
        
        // Ouptut
        let content = OutPut.joined(separator: "\n")
        
        do{
            try  content.write(to: pOutput, atomically: true, encoding: .utf8)
        } catch {
            print("Error encoding user to JSON or writing to file: \(error)")
        }
        
    }
    
}
