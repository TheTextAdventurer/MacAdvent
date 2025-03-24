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
        var Index: Int = 0
        var Verb: Int = 0   //ID of verb in DAT file list
        var Noun: Int = 0
        var Conditions:[ActionComponent] = []
        var Actions:[ActionComponent] = []
        var Comment: [String] = []
        //private var comments: [String] = [String]
        
        init(actions: [Int]) {
            Verb = actions[0] / 150
            Noun = actions[0] % 150
            
            if (Verb > 0)
            {
                Verb-=1
                Noun-=1
            }
            
            var ActionArgs:[Int] = []
            
            // Process conditions
            for c in 1...5 {
                
                let con = actions[c]
                
                let contNum = con % 20 - 1
                let conArg = con / 20 
                
                if (contNum > 0)
                {
                    self.Conditions += [ActionComponent(ItemID: contNum, ArgID: conArg)]
                }
                else
                {
                    ActionArgs += [contNum]
                }
            }
            
            // Get actions 1 / 2
            for a in 6...7 {
                let arg1 = actions[a] / 150
                let arg2 = actions[a] % 150
                
                if (arg1 > 0)
                {
                    self.Actions += [ActionComponent(ItemID: arg1)]
                }
                
                if (arg2 > 0)
                {
                    self.Actions += [ActionComponent(ItemID: arg2)]
                }
            }
            
            /*
            
            // Examine actions and assign arguments to then
            var x = 0
            self.Actions.forEach { (ac) in
                
                if Resources.actionArgsWithOneItem.contains(ac.ItemID) {
                    ac.ArgID += [ActionArgs[x]]
                    x+=1
                }
                else if Resources.actionsWithTwoItems.contains(ac.ItemID) {
                    ac.ArgID += [ActionArgs[x]]
                    ac.ArgID += [ActionArgs[x + 1]]
                    x+=2
                }
                
            }
             */
            
        }
        
        class ActionComponent: Codable {
            
            var ItemID: Int = 0
            var ArgID: [Int] = []
            
            init(ItemID: Int, ArgID: Int) {
                self.ItemID = ItemID
                self.ArgID += [ArgID]
            }
            
            init(ItemID: Int) {
                self.ItemID = ItemID
            }
        }
        
        class Condition: Codable {
            
            var ConditionID: Int = 0
            var ConditionDescription: String = ""
            var ArgID: Int = 0
            var ArgDescription: String = ""
            
            init(ConditionID: Int, ArgID: Int) {
                self.ConditionID = ConditionID
                self.ArgID = ArgID
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

