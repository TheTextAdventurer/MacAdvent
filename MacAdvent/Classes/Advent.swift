//
//  Game engine
//
//  Created by Andy Stobirski on 17/03/2025.
//
import Foundation


class Advent {
    
    class Settings:Codable
    {
        var CurrentRoom : Int = 0
        var CurrentCounter : Int = 0
        var BitFlags: [Bool] = Array(repeating: false, count: 32)
        var SavedRooms: [Int] = Array(repeating: 0, count: 16)
        var Counters: [Int] = Array(repeating: 0, count: 16)
        var TurnCounter : Int = 0
        var TakeSuccess : Bool?
        var EndGame: Bool = false
        var NounStr: String?
        var VerbStr: String?
        var NounInt: Int = 0
        var VerbInt: Int = 0
        var LampLife: Int = 0
        var SavedRoom: Int = 0
        var MovedItems: [[Int]] = []// Items moved from their origin room [ItemID,RoomID]
        var AdventureNumber:Int = 0
        
        init(){}
        
        init(pCurrentRoom: Int, pLampLife: Int, pAdventureNumber: Int)
        {
            self.TurnCounter = 0
            self.Counters = Array(repeating: 0, count: 16)
            self.BitFlags = Array(repeating: false, count: 32)
            self.SavedRooms = Array(repeating: 0, count: 16)
            self.CurrentCounter = 0
            self.CurrentRoom = pCurrentRoom
            self.TakeSuccess = nil
            self.EndGame = false
            self.LampLife = pLampLife
            self.SavedRoom = 0
            self.MovedItems = []
            self.AdventureNumber = pAdventureNumber
        }
        
        //
        func AddMovedItem(_ pItemID: Int, _ pRoomID: Int)
        {
            if let index = MovedItems.firstIndex(where: { $0.first == pItemID}  ) {
                self.MovedItems[index] = [pItemID,pRoomID]
            }
            else
            {
                self.MovedItems.append([pItemID,pRoomID])
            }
        }
        
        //
        func RemovedMoveItem(_ pItemID: Int)
        {
            if let index = MovedItems.firstIndex(where: { $0.first == pItemID}  ) {
                MovedItems.remove(at: index)
            }
        }
    }
    
    var onGameMessage: ((String, Bool) -> Void)?
    
    // Game file, converted from DAT
    var GameFile : DatFile?
    
    // Required for game operation and states
    var GameSettings: Settings
    
    // Messages generated store here, prior to output
    var MessagesOutput:[String] = []
    
    // Set by ActionID
    var ContinueWithAction: Bool = false
    
    init(){
        GameSettings = Settings()
    }
    
    // Save the game state to the specified URL
    func SaveGameState(pURL: URL)
    {
        Utils.SaveAsJSON(item: self.GameSettings, fileURL: pURL)
    }
    
    // Load the specified game state
    func LoadGameState(pURL: URL)
    {
        if let gameSettings = Utils.DecodeFromJSON(fileURL: pURL, as: Advent.Settings.self)
        {
            
            if (gameSettings.AdventureNumber == GameFile!.Header.AdventureNumber)
            {
                
                self.GameSettings = gameSettings
                self.GameSettings.MovedItems.forEach { item in
                    GameFile!.Items[item[0]].RoomID = item[1]
                }
                Look()
            }
            else
            {
                RoomView(pMessage: String(format: "Adventure number mismatch: save file %d, loaded game %d", gameSettings.AdventureNumber, GameFile!.Header.AdventureNumber), pRefresh: true )
            }
        }
        else
        {
            fatalError("Load Game State failed")
        }
    }
    
    
    //  Load provdided data file
    func load(pGame: String){
        GameFile = ConvertDat.Load(pGame: pGame)
    }
    
    // Begin the game
    func start()
    {
        GameSettings = Settings(pCurrentRoom: GameFile!.Header.startRoom, pLampLife: GameFile!.Header.lightDuration, pAdventureNumber: GameFile!.Header.AdventureNumber)
     
        Look()
        MessagesOutput = []
        SearchActions(pVerb: -1, pNoun: -1)
        RoomView(
            pMessage: MessagesOutput.joined(separator: Resources.StringCarraigeReturn),
            pRefresh: false
        )
    
    }
    
    // Evaluate the provided condition, return a bool
    // All conditions verified as correct
    func ConditionTest(pCondition: Int, pArg: Int) -> Bool
    {
        
        var bResult : Bool = false

        switch pCondition {
            
            case 0 : // "item '%@' carried"
                bResult = ItemInLocationRoom(pItemID: pArg, pRoomID: Resources.inventoryLocations)
            
            case 1 : // "item '%@' in room with player"
                bResult = ItemInLocationRoom(pItemID: pArg, pRoomID: [self.GameSettings.CurrentRoom])
            
            case 2 : // "item '%@' carried or in room with player"
                bResult = ConditionTest(pCondition: 0, pArg: pArg)
                    || ConditionTest(pCondition: 1, pArg: pArg)
            
            case 3 : // "player in room %d"
                bResult = GameSettings.CurrentRoom == pArg
            
            case 4 : // "item '%@' not in room with player"
                bResult = ConditionTest(pCondition: 1, pArg: pArg) == false
            
            case 5 : // "item '%@' not carried"
                bResult = ConditionTest(pCondition: 0, pArg: pArg) == false
            
            case 6 : // "player not in room %d"
                bResult = GameSettings.CurrentRoom != pArg
            
            case 7 : // "bitflag %d is set"
                bResult = GameSettings.BitFlags[pArg] == true
            case 8 : // "bitflag %d is false"
                bResult = GameSettings.BitFlags[pArg] == false
            
            case 9 : // "something carried"
                bResult = GetItemsInRoom(pRoomID: Resources.inventoryLocations).count > 0
            
            case 10: // "nothing carried"
                bResult = GetItemsInRoom(pRoomID: Resources.inventoryLocations).count == 0
            
            case 11: // "item '%@' not carried or in room with player"
                bResult = ConditionTest(pCondition: 5,pArg: pArg) && ConditionTest(pCondition: 4,pArg: pArg)
            
            case 12: // "item '%@' in game"
                bResult = self.GameFile!.Items[pArg].RoomID != Resources.Constants.store.rawValue
            
            case 13: // "item '%@' not in game"
                bResult =  self.GameFile!.Items[pArg].RoomID == Resources.Constants.store.rawValue
            
            case 14: // "current counter less than %d"
                bResult = GameSettings.CurrentCounter < pArg
            
            case 15: // "current counter greater than '%@'"
                bResult = GameSettings.CurrentCounter > pArg
            
            case 16: // "object '%@' in initial location"
                bResult = GameFile!.Items[pArg].IsMoved() == false
            
            case 17: // "object '%@' not in initial location"
                bResult = GameFile!.Items[pArg].IsMoved() == true
            
            case 18: // "current counter equals %d"
                bResult = GameSettings.CurrentCounter == pArg
                
            default:
                fatalError(String(format: "Condition ID: %d not known", pCondition))
        }
        
        return bResult
    }
    
    // If you don't know what this does, give up
    func Random()->Int
    {
        return Int.random(in: 1...100)
    }

    //
    func SearchActions(pVerb: Int, pNoun: Int)
    {
        //determines if we output a message upon completion
        //0 no message, 1 don't understand, 2 beyond my power
        //message used if input is via a user, pVerb > 0
        var msg = pVerb > 0 ? 1 : 0;

        
        var ConditionResult:Bool = false
        var ctr = 0
        while ctr < GameFile!.Actions.count
        {
            let action = GameFile!.Actions[ctr]
            
            if (
                    pVerb == -1  && action.Verb == 0  &&  Random() <= action.Noun) // probability action
                    || ((pVerb > 0) && (action.Verb == pVerb) && (action.Noun == pNoun || action.Noun  == 0) // user input
                )
            {
                ConditionResult = TestActionConditions(pConditions: action.Conditions)
                
                if (ConditionResult)
                {
                    
                    //print("Executed action \(action.Index)")
                    //GameMessage(pMessage: "Executed action \(action.Index) V:\(action.Verb) N:\(action.Noun)")
                    
                    self.ContinueWithAction = false //may be set if action 73 encountered
                    ExecuteOpcodes(pOpcodes: action.Opcodes)
                                        
                    if (self.ContinueWithAction)
                    {
                        // we can be sure at least one action is N0 V0
                        ctr += 1
                        while let cont = GameFile?.Actions[ctr], cont.Noun == 0 && cont.Verb == 0
                        {
                            if (TestActionConditions(pConditions: cont.Conditions))
                            {
                                //GameMessage(pMessage: "Continued action \(cont.Index)")
                                ExecuteOpcodes(pOpcodes: cont.Opcodes)
                            }
                            ctr += 1
                        }
                        self.ContinueWithAction = false
                        
                        ctr -= 1
                    }
                    
                }
                
                if (GameSettings.EndGame)
                {
                    Look()
                    return
                }
                
                if (pVerb > 0 && ConditionResult)
                {
                    //this is user input, and the same verb noun combination may be used
                    //under different conditions, so bail if we've successfully processed
                    //user input`
                    break
                }
            }
            
            ctr += 1
        }
        
        

        //output a can't do that message if we recognise a player verb in the list, but not a noun
        if (pVerb >  0 && !ConditionResult && GameFile!.Actions.filter {$0.Verb == pVerb }.count > 0)
        {
            msg = 2
        }
        
        if (pVerb > 0) //Only after player input
        {
            if (!ConditionResult)
            {
                if (msg == 1)
                {
                    // I don't understand
                    GameMessage(pMessage: Resources.sysMessages[15])
                }
                else if (msg == 2)
                {
                    // beyond my power to do 
                    GameMessage(pMessage: Resources.sysMessages[14])
                }
            }
            SearchActions(pVerb: 0, pNoun: 0)
        }
        
       // Look()
    }
    
    // Execute the provided actions
    func ExecuteOpcodes(pOpcodes: [DatFile.Action.ActionComponent] )
    {
        for opcode in pOpcodes
        {
            PerformAction(pActionID: opcode.ID, pArgs: opcode.ArgID)
        }
    }
    
    
    // Test the conditions associated with the provided action
    func TestActionConditions(pConditions: [DatFile.Action.ActionComponent] ) -> Bool
    {
        for condition in pConditions
        {
            if (ConditionTest(pCondition: condition.ID, pArg: condition.ArgID.first ?? 0) == false)
            {
                return false
            }
        }
        return true;
    }
    
    func PerformAction (pActionID: Int, pArgs: [Int])
    {
        if (pActionID < 52 || pActionID > 101)
        {
            let msg = self.GameFile!.Messages[pActionID - (pActionID > 101 ? 50 : 0)]
            GameMessage(pMessage: msg);
            //PerformAction(pActionID: 86, pArgs: [0,0] );//carriage return
        }
        else
        {
            let ArgID1 : Int = pArgs.first ?? 0
            let ArgID2 : Int = pArgs.last ?? 0
            
            switch pActionID
            {
                
                case 52://"get item '%@', check if can carry" CHECKED
                    GameSettings.TakeSuccess = false
                    if (GetItemsInRoom(pRoomID: Resources.inventoryLocations)).count < GameFile!.Header.maxCarry
                    {
                        ChangeItemLocation(pItemID: ArgID1, pRoomID: Resources.Constants.inventory.rawValue)
                        Look()
                        GameMessage(pMessage: Resources.sysMessages[0])
                    }
                    else
                    {
                        GameMessage(pMessage: Resources.sysMessages[8])
                    }
                
                case 53://"drops item '%@' into current room" CHECKED
                    ChangeItemLocation(pItemID: ArgID1, pRoomID: GameSettings.CurrentRoom)
                
                case 54://"move room %d" CHECKED
                    GameSettings.CurrentRoom = ArgID1
                    PerformAction(pActionID: 76, pArgs: [ArgID1])
                
                case 55 , 59 ://"Item '%@' is removed from the game (put in room 0)"
                    ChangeItemLocation(pItemID: ArgID1, pRoomID: Resources.Constants.store.rawValue)
                
                case 56://"set darkness flag"
                    GameSettings.BitFlags[Resources.Constants.darknessFlag.rawValue] = true
                
                case 57://"clear darkness flag"
                    GameSettings.BitFlags[Resources.Constants.darknessFlag.rawValue] = false
                
                case 58://"set %d flag"
                    GameSettings.BitFlags[ArgID1] = true
                
                case 60://"set %d flag"
                    GameSettings.BitFlags[ArgID1] = false
                
                case 61://"Death, clear dark flag, move to last room"
                    PerformAction(pActionID: 57, pArgs: [])
                    GameSettings.CurrentRoom = self.GameFile!.Rooms.count - 1
                    GameMessage(pMessage: Resources.sysMessages[24])
                
                case 62://"item '%@' is moved to room %d"
                    ChangeItemLocation(pItemID: ArgID1, pRoomID: ArgID2)
                
                case 63://"game over",
                    self.GameSettings.EndGame = true
                    GameMessage(pMessage: Resources.sysMessages[25])
                
                case 65://"score"
                
                    //count treasure items in treasure room
                    let treasures = GetItemsInRoom(pRoomID: [GameFile!.Header.treasureRoom])
                    .filter { $0.Description.first == "*" }
                
                    let msg = String(format: Resources.sysMessages[13], treasures.count, Int(Double(treasures.count) / Double(GameFile!.Header.totalTreasures) * 100))
                
                    GameMessage(pMessage: msg)
                
                    if (treasures.count == GameFile!.Header.totalTreasures)
                    {
                        GameMessage(pMessage:  Resources.sysMessages[26])
                        PerformAction(pActionID: 63, pArgs: [0,0])
                    }
                
                case 66://"output inventory"
                
                    var msg: String = ""
                
                    if (GameSettings.BitFlags[Resources.Constants.darknessFlag.rawValue]  == true && ConditionTest(pCondition: 11, pArg: Resources.Constants.lightSource.rawValue))
                    {
                        msg = Resources.sysMessages[16]
                    }
                    else
                    {
                        msg = Resources.sysMessages[9]
                        let items = GetItemsInRoom(pRoomID: Resources.inventoryLocations)
                        msg += items.count == 0 ? "\n" + Resources.sysMessages[12]
                            : "\n" + items.map{ $0.Description }.joined(separator: ", ")
                        
                    }
                    GameMessage(pMessage: msg)
                    PerformAction(pActionID: 86, pArgs: [0,0])
                
                
                case 67://"Set bit 0 true"
                    GameSettings.BitFlags[0] = true
                
                case 68://"Set bit 0 false"
                    GameSettings.BitFlags[0] = false
                
                case 69://"refill lamp"
                    GameSettings.LampLife = GameFile!.Header.lightDuration
                    GameSettings.BitFlags[Resources.Constants.lightOutFlag.rawValue] = false
                
                case 70://"clear screen"
                    onGameMessage?( "", true)
                
                case 71://"save game"
                
                    Utils.saveFile { url in
                        if let url = url {
                            print("File will be saved at: \(url)")
                            self.SaveGameState(pURL: url)
                        }
                    }
                
                case 72://"swap item locations '%@' and '%@'"
                    let i1 = GetItem(pIndex: ArgID1)
                    let i2 = GetItem(pIndex: ArgID2)
                    let tmp = i1!.RoomID
                    i1!.RoomID = i2!.RoomID
                    i2!.RoomID = tmp
                    
                case 73://"continue with next action"
                    self.ContinueWithAction = true
                
                case 74://"take item '%@', no check done to see if can carry"
                    ChangeItemLocation(pItemID: ArgID1, pRoomID: Resources.Constants.inventory.rawValue)

                case 75://"put item 1 '%@' with item2 '%@'"
                    ChangeItemLocation(pItemID: ArgID1, pRoomID: GetItem(pIndex: ArgID2)!.RoomID)
                
                case 64, 76://"look"
                    
                    let room = GameFile!.Rooms[GameSettings.CurrentRoom]
                    var description = ""
                
                    if (IsDark())
                    {
                        description = Resources.sysMessages[16]
                    }
                    else
                    {
                        description = String(format: "%@ ", room.Description)
                        
                        let items = GetItemsInRoom(pRoomID: [GameSettings.CurrentRoom])
                        if (items.count > 0)
                        {
                            description = String(format: "%@%@%@%@%@%@"
                                                 , room.Description
                                                 , Resources.StringCarraigeReturn
                                                 , Resources.StringCarraigeReturn
                                                 , Resources.StringIcanSee
                                                 , items.map { "\($0.Description)" }.joined(separator: ", ")
                                                 , Resources.StringCarraigeReturn
                            )
                        }
                    }
                    
                RoomView(pMessage: description, pRefresh: true)
                
                case 77://"decrement current counter"
                    if (GameSettings.CurrentCounter > 0 )
                    {
                        GameSettings.CurrentCounter -= 1
                    }
            
                case 78://"output current counter"
                    GameMessage(pMessage: "\(GameSettings.CurrentCounter)")
        
                case 79://"set current counter value %d"
                    GameSettings.CurrentCounter = ArgID1
        
                case 80://"swap location with saved location"
                    let s = GameSettings.SavedRoom
                    GameSettings.SavedRoom = GameSettings.CurrentRoom
                    GameSettings.CurrentRoom = s
        
                case 81://"Select counter %d. Current counter is swapped with backup counter"
                    let t = GameSettings.CurrentCounter
                    GameSettings.CurrentCounter = GameSettings.Counters[ArgID1]
                    GameSettings.Counters[ArgID1] = t
                
                case 82://"add to current counter"
                    GameSettings.CurrentCounter += ArgID1
        
                case 83://"subtract from current counter"
                    GameSettings.CurrentCounter -= ArgID1
        
                case 84://"echo noun without cr"
                    GameMessage(pMessage: GameSettings.NounStr ?? "" + Resources.StringCarraigeReturn)

                case 85://"echo noun"
                    GameMessage(pMessage: GameSettings.NounStr ?? "" + Resources.StringCarraigeReturn)
        
                case 86://"Carriage Return"
                    GameMessage(pMessage: Resources.StringCarraigeReturn)
        
                case 87://"Swap current location value with backup location-swap value"
                    let temp = GameSettings.CurrentRoom
                    GameSettings.CurrentRoom = GameSettings.SavedRooms[ArgID1]
                    GameSettings.SavedRooms[ArgID1] = temp
                
                case 88://"wait 2 seconds"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        // Code to execute after the delay
                        self.GameMessage(pMessage: "2 seconds later")
                    }
        
                case 89://  load game - CUSTOM FEATURE FOR THIS GAME, NOT PRESENT IN ORIGINAL SAGA SPECS
                    Utils.pickFile() { url in
                        if let url = url {
                            self.LoadGameState(pURL: url)
                        }
                    }
                
                default:
                    fatalError(String(format: "Action ID: %d not known", pActionID))
            }
        }
    }
    
    // Return an item of the specified index
    func GetItem (pIndex: Int) -> DatFile.Item!
    {
        return GameFile!.Items[pIndex]
    }
    
    // Check if the item is in the room, note that the inventory is treated as a room
    func ItemInLocationRoom (pItemID: Int, pRoomID: [Int]) -> Bool
    {
        return GameFile!.Items.first { $0.Index == pItemID && pRoomID.contains($0.RoomID) } != nil
    }
    
    // Quick trigger for refreshing room
    func Look()
    {
        PerformAction(pActionID: 64, pArgs: [0])
    }
    
    //  Return all the items in the specified room
    func GetItemsInRoom(pRoomID: [Int]) -> [DatFile.Item]
    {
        var items : [DatFile.Item] = []
        for item in GameFile!.Items {
            if pRoomID.contains(item.RoomID) {
                items.append(item)
            }
        }
        return items
    }
    
    // Search a word list
    func SearchWordList(pIsVerb: Bool, pSearchWord: String) -> Int
    {
        let list = (pIsVerb ? GameFile!.Verbs : GameFile!.Nouns)
        for (_, item) in list.enumerated() {
            if item.Word.prefix(MinWordLength())  == pSearchWord  || item.Aliases.contains(pSearchWord){
                return item.Index
            }
        }
        return -1
    }

    // Check if the string corresponds to a direction
    func IsDirection (pDir: String) -> Int
    {
        for(index, item) in Resources.DirectionsLong.enumerated() {
  
            if ((pDir.compare(item, options: .caseInsensitive) == .orderedSame) || (pDir.count == 1 && pDir.compare(item.prefix(1), options: .caseInsensitive) == .orderedSame)
                || (pDir.prefix(MinWordLength()).compare(item.prefix(MinWordLength()), options: .caseInsensitive) == .orderedSame)
            )
            {
                return index + 1
            }
        }
        return -1
    }
    
    // Minimum word length
    func MinWordLength() -> Int
    {
        return GameFile!.Header.wordLength
    }
    
    //  Append to the GameMessage array
    private func GameMessage(pMessage: String)
    {
        MessagesOutput += [pMessage]
    }
    
    // output the current roomview
    private func RoomView(pMessage: String, pRefresh: Bool = false )
    {
        onGameMessage?(pMessage, pRefresh)
    }

    // Process the user provided text
    func UserInput(pInput: String)
    {
        
        MessagesOutput = []
        let components = pInput.uppercased().split(separator: " ").map { String($0) }
        
        // DEBUG
        if let f = components[0].first, f == "#"
        {
            GameMessage(pMessage: "> " + pInput)
            switch components[0].uppercased()
            {
            case "#A":
                let act = Int(components[1]) ?? 0
                let args  = components.dropFirst(2).map { Int($0) ?? 0}
                PerformAction(pActionID: act, pArgs: args)
                
            case "#C":
                let con = Int(components[1]) ?? 0
                let arg = components.dropFirst(2).map { Int($0) ?? 0}.first ?? 0
                let outcome = ConditionTest(pCondition: con, pArg: arg)
                GameMessage(pMessage: String(outcome))
                
            case "#CURRENTROOM":
                GameMessage(pMessage: "Current room: \(GameSettings.CurrentRoom)")
                
            case "#TURNS":
                GameMessage(pMessage: "Turn counter: \(GameSettings.TurnCounter)")
                
            case "#LAMP":
                GameMessage(pMessage: "Lamp life: \(GameSettings.LampLife)")
                
            case "#ITEMS":
                let items = GameFile!.Items.filter{ $0.RoomID == GameSettings.CurrentRoom}.map{"\($0.Description)-\($0.Index)"}
                GameMessage(pMessage: items.joined(separator: ", "))
                
            case "#MD":
                Utils.saveFile { url in
                    if let url = url {
                        ConvertDat.OutputAsMD(pOutput: url, pDatFile: self.GameFile!)
                    }
                }
                
            case "#JSON":
                Utils.saveFile { url in
                    if let url = url {
                        Utils.SaveAsJSON(item: self.GameFile, fileURL: url)
                    }
                }
                
            case "#MAP":
                Utils.saveFile { url in
                    if let url = url {
                        ConvertDat.OutputRoomMap(pOutput: url, pDatFile: self.GameFile!)
                    }
                }
                
            default:
                GameMessage(pMessage: "Not recognised: \(components[0])")
            }
        }
        else
        {
            
            
            // PROCESS GAME INPUT
            GameMessage(pMessage: "")
            self.GameSettings.TurnCounter += 1
            
            
            var Verb = components[0]
            var Noun = components.count > 1 ? components[1] : ""
            
            // Special case for abbreviations
            if let Abbr = SearchAbbreviations(pSearch: Verb)
            {
                Verb = Abbr
            }
            
            Verb = Verb.count > MinWordLength() ? String(Verb.prefix(MinWordLength())) : Verb
            Noun = Noun != "" ? (Noun.count > MinWordLength() ? String(Noun.prefix(MinWordLength())) : Noun) : ""
            
 
            
            GameSettings.VerbInt = SearchWordList(pIsVerb: true, pSearchWord: Verb)
            GameSettings.NounInt = Noun != "" ? SearchWordList(pIsVerb: false, pSearchWord: Noun) : -1
           
            if (GameSettings.VerbInt == -1  && GameSettings.NounInt == -1 && IsDirection(pDir: Verb ) > -1)
            {
                //If one word is entered, and it's a direction the verb / noun to GO DIR
                GameSettings.VerbInt = Resources.Constants.verbGo.rawValue
                GameSettings.NounInt = IsDirection(pDir: Verb)
                
            }
            
            // Start examining the input
            if (GameSettings.VerbInt == -1 )
            {
                GameMessage(pMessage: Resources.sysMessages[11]) //What?
            }
            else if ((GameSettings.VerbInt == Resources.Constants.verbTake.rawValue || GameSettings.VerbInt == Resources.Constants.verbDrop.rawValue) && GameSettings.NounInt == -1 )
            {
                GameMessage(pMessage: Resources.sysMessages[11]) //What?
            }
            // Moving, go n/s/e/w/u/d
            else if (GameSettings.VerbInt == Resources.Constants.verbGo.rawValue && GameSettings.NounInt > -1 && GameSettings.NounInt < 7)
            {
                
                let Dir = GameSettings.NounInt - 1
                
                let IsDark = IsDark()
                let DirectionExist = GameFile!.Rooms[GameSettings.CurrentRoom].Exits[Dir] > 0
                
                if (DirectionExist)
                {
                    
                    PerformAction(pActionID: 54, pArgs: [GameFile!.Rooms[GameSettings.CurrentRoom].Exits[Dir] ])
                    // Dangerous to move in dark / OK
                    GameMessage(pMessage: IsDark ? Resources.sysMessages[17] : Resources.sysMessages[0])
                }
                else
                {
                    if (IsDark)
                    {
                        GameMessage(pMessage: Resources.sysMessages[18])
                    }
                    else
                    {
                        GameMessage(pMessage: Resources.sysMessages[2])    // can't go in that direction
                    }
                }
            }
            else if (GameSettings.VerbInt == Resources.Constants.verbGo.rawValue && GameSettings.NounInt == -1)
            {
                GameMessage(pMessage: Resources.sysMessages[10])
            }
            else
            {
                //we've exhausted the standard actions, so look for a specific action
                SearchActions(pVerb: GameSettings.VerbInt, pNoun: GameSettings.NounInt)
            }
            
            SearchActions(pVerb: -1, pNoun: -1)
            
            //Check lamp life, provide the lightsource in the the game and lit
            if (ConditionTest(pCondition: 12, pArg: Resources.Constants.lightSource.rawValue) && GameSettings.LampLife > 0)
            {
                GameSettings.LampLife -= 1
            }
            
        }
        
        Look()
        RoomView(
            pMessage: MessagesOutput.joined(separator: Resources.StringCarraigeReturn),
            pRefresh: false
        )
        
    }
    
    // Search abbreviations
    func SearchAbbreviations (pSearch: String) -> String?
    {
        for entry in Resources.Abbreviations {
               if entry[0].caseInsensitiveCompare(pSearch) == .orderedSame {
                   return entry[1] // Return the second element if a match is found
               }
           }
           return nil // Return nil if no match is found
    }
    
    // An items's location has changed, update settings
    func ChangeItemLocation (pItemID: Int, pRoomID: Int)
    {
        let item = GameFile!.Items[pItemID]
        item.RoomID = pRoomID
        if (item.IsMoved())
        {
            GameSettings.AddMovedItem(pItemID, pRoomID)
        }
        else
        {
            GameSettings.RemovedMoveItem(pItemID)
        }
    }
    
    // Is it dark - the darkness flag is set, and lantern is not carried OR in room with player
    func IsDark() -> Bool {
        return GameSettings.BitFlags[Resources.Constants.darknessFlag.rawValue] && ConditionTest(pCondition: 11, pArg: Resources.Constants.lightSource.rawValue)
    }
    
    
    private static func Left(_ string: String, n: Int) -> String {
        guard n >= 0 else { return "" }
        return String(string.prefix(n))
    }
}

