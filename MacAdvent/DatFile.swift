//
//  DatFile.swift - contains the converted dat file
//

class DatFile : Codable {
    
    var Header: gameHeader!
    var Actions: [Action] = []
    var Verbs: [Word] = []
    var Nouns: [Word] = []
    var Rooms: [Room] = []
    var Messages: [String] = []
    var Items:[Item] = []   

    
    enum CodingKeys: String, CodingKey {
          case Header
          case Actions
          case Verbs
          case Nouns
          case Rooms
          case Messages
          case Items
      }

    
    // Custom encoding method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Header, forKey: .Header)
        try container.encode(Actions, forKey: .Actions)
        try container.encode(Verbs, forKey: .Verbs)
        try container.encode(Nouns, forKey: .Nouns)
        try container.encode(Rooms, forKey: .Rooms)
        try container.encode(Messages, forKey: .Messages)
        try container.encode(Items, forKey: .Items)
    }
    
    class gameHeader : Codable  {
        var unknown: Int
        var numItems: Int
        var numActions: Int
        var numNounVerbs: Int
        var numRooms: Int
        var maxCarry: Int
        var startRoom: Int
        var totalTreasures: Int
        var wordLength: Int
        var lightDuration: Int
        var numMessages: Int
        var treasureRoom: Int

        init(pVals: [Int]) {
            unknown = pVals[0]
            numItems = pVals[1] + 1
            numActions = pVals[2] + 1
            numNounVerbs = pVals[3] + 1
            numRooms = pVals[4] + 1
            maxCarry = pVals[5]
            startRoom = pVals[6]
            totalTreasures = pVals[7]
            wordLength = pVals[8]
            lightDuration = pVals[9]
            numMessages = pVals[10] + 1
            treasureRoom = pVals[11]
        }
        
    }
    
    class Action : Codable {
        /*
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy:    CodingKeys.self)
            try container.encode(Index, forKey: .Actions)
            try container.encode(Comment, forKey: .Comment)
            try container.encode(Verb, forKey: .Conditions)
            try container.encode(Noun, forKey: .Index)
            try container.encode(Conditions, forKey: .Noun)
            try container.encode(Actions, forKey: .Verb)
        }
         */
        
        var Index: Int = 0
        var Verb: Int = 0   //ID of verb in DAT file list
        var Noun: Int = 0
        var Conditions:[ActionComponent] = []
        var Actions:[ActionComponent] = []
        var Comment: String = ""

        init(actions: [Int]) {
            Verb = actions[0] / 150
            Noun = actions[0] % 150
            
            if (Verb > 0)
            {
                Verb-=1
                Noun-=1
            }
            
            var ActionArgs:[Int] = []
            var ctr: Int = 0
            
            // Process conditions
            for c in 1...5 {
                
                let con = actions[c]
                
                let contNum = con % 20 
                let conArg = con / 20 
                
                if (contNum > 0)
                {
                    self.Conditions += [ActionComponent(ItemID: contNum - 1, ArgID: conArg, Index: ctr)]
                    ctr+=1
                }
                else
                {
                    ActionArgs += [conArg]
                }
            }
            
            // Get actions 1 / 2
            ctr = 0
            for a in 6...7 {
                let arg1 = actions[a] / 150
                let arg2 = actions[a] % 150
                
                if (arg1 > 0)
                {
                    self.Actions += [ActionComponent(ItemID: arg1, Index: ctr)]
                    ctr+=1
                }
                
                if (arg2 > 0)
                {
                    self.Actions += [ActionComponent(ItemID: arg2, Index: ctr)]
                    ctr+=1
                }
            }
            
            
            
            // Examine actions and assign arguments to then
            var x = 0
            self.Actions.forEach { (ac) in
                
                if Resources.ActionOneItem.contains(ac.ItemID)
                    || Resources.ActionRoom.contains(ac.ItemID)
                    || Resources.ActionInteger.contains(ac.ItemID){
                    
                    ac.ArgID += [ActionArgs[x]]
                    x+=1
                }
                else if Resources.ActionTwoItems.contains(ac.ItemID)
                || Resources.ActionItemRoom.contains(ac.ItemID) {
                    ac.ArgID += [ActionArgs[x]]
                    ac.ArgID += [ActionArgs[x + 1]]
                    x+=2
                }
                
            }
             
            
        }
        
        class ActionComponent: Codable {
            
            func AsCondition() -> String {
                return "ConditionID \(ItemID) ArgID \(ArgID.first ?? 0)"
            }
            
            func AsAction() -> String {
                return "ActionID \(ItemID) ArgID \(ArgID.map { String($0) }.joined(separator: ", "))"
            }
            
            var ItemID: Int = 0
            var ArgID: [Int] = []
            var Index: Int
            var Description: String = ""
            
            init(ItemID: Int, ArgID: Int, Index: Int) {
                self.ItemID = ItemID
                self.ArgID += [ArgID]
                self.Index = Index
            }
            
            init(ItemID: Int, Index: Int) {
                self.ItemID = ItemID
                self.Index = Index
            }
        }
                
    }

    class Word : Codable {
        var Index: Int = 0
        var Word: String
        var Aliases: [String] = []
        init(word: String) {
            self.Word = word
        }
    }
    
    class Room : Codable {
        var Description: String = ""
        var Exits: [Int] = []
        
        init (pRoomExits: [Int], pDescription: String){
            Exits = pRoomExits
            Description = pDescription
        }
    }
    
    class Item : Codable {
        var Index: Int = 0
        var GetDrop: String? = nil
        var RoomID: Int = 0
        var Description: String = ""
        init(pRoomID:Int, pDescription: String, pGetDrop: String?)
        {
            GetDrop = pGetDrop
            Description = pDescription
            RoomID = pRoomID
        }
    }
}

