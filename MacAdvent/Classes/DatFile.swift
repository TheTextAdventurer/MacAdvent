//
//  DatFile.swift - contains the converted dat file
//

import Foundation

class DatFile : Codable {
    
    var Header: gameHeader!
    var Actions: [Action] = []
    var Verbs: [Word] = []
    var Nouns: [Word] = []
    var Rooms: [Room] = []
    var Messages: [String] = []
    var Items:[Item] = []   
    
    
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
        var AdventureNumber: Int = 0
        
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

        var Contents:[Int] = []
        var Index: Int = 0
        var Verb: Int = 0   //ID of verb in DAT file list
        var Noun: Int = 0
        var Conditions:[ActionComponent] = []
        var Opcodes:[ActionComponent] = []
        var Comment: String = ""
        
        init()
        {
            
        }
        
        init(actions: [Int]) {
            Contents = actions
            Verb = actions[0] / 150
            Noun = actions[0] % 150
            
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
                    self.Opcodes += [ActionComponent(ItemID: arg1, Index: ctr)]
                    ctr+=1
                }
                
                if (arg2 > 0)
                {
                    self.Opcodes += [ActionComponent(ItemID: arg2, Index: ctr)]
                    ctr+=1
                }
            }
            
            // Examine actions and assign arguments to then
            var x = 0
            self.Opcodes.forEach { (ac) in
                
                if Resources.ActionOneItem.contains(ac.ID)
                    || Resources.ActionRoom.contains(ac.ID)
                    || Resources.ActionInteger.contains(ac.ID){
                    
                    ac.ArgID += [ActionArgs[x]]
                    x+=1
                }
                else if Resources.ActionTwoItems.contains(ac.ID)
                || Resources.ActionItemRoom.contains(ac.ID) {
                    ac.ArgID += [ActionArgs[x]]
                    ac.ArgID += [ActionArgs[x + 1]]
                    x+=2
                }
            }
        }
        
        
        class ActionComponent: Codable {
            
            func AsCondition() -> String {
                return "ConditionID \(ID) ArgID \(ArgID.first ?? 0)"
            }
            
            func AsAction() -> String {
                return "ActionID \(ID) \(ArgID.count > 0 ? "ArgID " + ArgID.map { String($0) }.joined(separator: ", ") : "")"
            }
            
            var ID: Int = 0
            var ArgID: [Int] = []
            var Index: Int
            var Description: String = ""
            
            init(ItemID: Int, ArgID: Int, Index: Int) {
                self.ID = ItemID
                self.ArgID += [ArgID]
                self.Index = Index
            }
            
            init(ItemID: Int, Index: Int) {
                self.ID = ItemID
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
        var Index: Int = 0
        var Description: String = ""
        var Text:String = ""
        var Exits: [Int] = []
        
        init (pRoomExits: [Int], pDescription: String, pIndex: Int){
            
            self.Index = pIndex
            self.Text = pDescription
            if (pDescription.first == "*")
            {
                Description = pDescription
                Description.removeFirst()
            }
            else
            {
                Description = String(format: "%@%@", Resources.StringImIn, pDescription)
            }
            
            Description = "\(Description)" // - I:\(pIndex)"
            
            var exits:[String] = []
            
            // exits
            for e in 0...pRoomExits.count-1 {
                if (pRoomExits[e] > 0)
                {
                    exits += [Resources.DirectionsLong[e]]
                }
            }

            if (exits.count > 0)
            {
                Description = String(format: "%@%@%@%@%@", Description
                                     , Resources.StringCarraigeReturn
                                     , Resources.StringCarraigeReturn
                                     , Resources.StringObviousExits
                                     , exits.joined(separator: ", ")  )
            }
            
            Exits = pRoomExits
        }
    }
    
    
    class Item : Codable {
        var Index: Int = 0
        var GetDrop: String? = nil
        var RoomID: Int = 0 {
             didSet {
                // self.onItemLocationChange?(self)
             }
         }
        var OriginalRoom: Int = 0
        var Description: String = ""
        init(pRoomID:Int, pDescription: String, pGetDrop: String?, pIndex: Int)
        {
            GetDrop = pGetDrop
            Description = "\(pDescription)" // - I:\(pIndex)"
            RoomID = pRoomID
            OriginalRoom = pRoomID
            Index = pIndex
        }
        
        func IsMoved() -> Bool {
            return (OriginalRoom != RoomID)
        }
    }
}

