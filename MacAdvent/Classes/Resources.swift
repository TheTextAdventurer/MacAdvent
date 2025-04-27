//
//  Strings.swift
//  MacAdvent
//
//  Created by Andy Stobirski on 20/03/2025.
//

class Resources {
    
    static let StringImIn : String = "I'm in a "
    static let StringObviousExits : String = "Obvious exits: "
    static let StringIcanSee: String = "I can see: "
    static let StringCarraigeReturn: String = "\n"
    
    static let conditions: [String] = [
        "item '%@' carried",                                // 0
        "item '%@' in room with player",                    // 1
        "item '%@' carried or in room with player",         // 2
        "player in room %d",                                // 3
        "item '%@' not in room with player",                // 4
        "item '%@' not carried",                            // 5
        "player not in room %d",                            // 6
        "bitflag %d is set",                                // 7
        "bitflag %d is false",                              // 8
        "something carried",                                // 9
        "nothing carried",                                  // 10
        "item '%@' not carried or in room with player",     // 11
        "item '%@' in game",                                // 12
        "item '%@' not in game",                            // 13
        "current counter less than %d",                     // 14
        "current counter greater than '%d'",                // 15
        "object '%@' in initial location",                  // 16
        "object '%@' not in initial location",              // 17
        "current counter equals %d"                         // 18
    ]

    static let ConditionsNoArg: [Int] = [9, 10]
    static let ConditionsOneItem: [Int] = [0, 1, 2, 4, 5, 11, 12, 13, 16, 17]
    static let ConditionOneRoom: [Int] = [3, 6]
    static let ConditionOneInteger: [Int] = [7, 8, 14, 15, 18]
    


    static let actions: [String] = [
        // 0 Does nothing
        // 1 - 51 print messages 1 to 51
        "get item '%@', check if can carry",                                    // 52  ONE ITEM*
        "drops item '%@' into current room",                                    // 53  ONE ITEM*
        "move room %d",                                                         // 54  ROOM*
        "Item '%@' is removed from the game (put in room 0)",                   // 55  ONE ITEM*
        "set darkness flag",                                                    // 56  NO ARGS*
        "clear darkness flag",                                                  // 57  NO ARGS*
        "set %d flag",                                                          // 58  FLAG INTEGER*
        "Item '%@' is removed from the game (put in room 0)",                   // 59  ONE ITEM*
        "set %d flag",                                                          // 60  FLAG INTEGER*
        "Death, clear dark flag, move to last room",                            // 61  NO ARGS*
        "item '%@' is moved to room %d",                                        // 62  ITEM ROOM*
        "game over",                                                            // 63  NO ARGS*
        "look",                                                                 // 64  NO ARGS*
        "score",                                                                // 65  NO ARGS*
        "output inventory",                                                     // 66  NO ARGS*
        "Set bit 0 true",                                                       // 67  NO ARGS*
        "Set bit 0 false",                                                      // 68  NO ARGS*
        "refill lamp",                                                          // 69  NO ARGS*
        "clear screen",                                                         // 70  NO ARGS*
        "save game",                                                            // 71  NO ARGS*
        "swap item locations '%@' and '%@'",                                    // 72  TWO ARGS ITEM*
        "continue with next action",                                            // 73  NO ARG*
        "take item '%@', no check done to see if can carry",                    // 74  ONE ARG ITEM*
        "put item 1 '%@' with item2 '%@'",                                      // 75  TWO ARGS ITEM*
        "look",                                                                 // 76  NO ARGS*
        "decrement current counter",                                            // 77  NO ARGS*
        "output current counter",                                               // 78  NO ARGS*
        "set current counter value %d",                                         // 79  ONE ARG COUNTER*
        "swap location with saved location",                                    // 80  NO ARGS*
        "Select counter %d. Current counter is swapped with backup counter",    // 81  ONE ARG COUNTER*
        "add to current counter",                                               // 82  NO ARGS*
        "subtract from current counter",                                        // 83  NO ARGS*
        "echo noun without cr",                                                 // 84  NO ARGS*
        "echo noun",                                                            // 85  NO ARGS*
        "Carriage Return",                                                      // 86  NO ARGS*
        "Swap current location value with backup location-swap value",          // 87  NO ARGS*
        "wait 2 seconds",                                                       // 88  NO ARGS*
        "Load Game"                                                             // 88  NO ARGS*
        // 102+ print messages 52 to 99
        
    ]

    static let ActioNoArgs: [Int] = [56, 57,61, 63, 64, 65, 66, 67, 68, 69, 70, 71, 73, 76, 77, 78, 80, 82, 83, 84, 85, 86, 87, 88]
    static let ActionOneItem: [Int] = [52, 53, 55, 59, 74]
    static let ActionTwoItems : [Int] = [72, 75]
    static let ActionItemRoom: [Int] = [62]
    static let ActionRoom: [Int] = [54]
    static let ActionInteger: [Int] = [58, 60, 79, 81]
    
    
    static let playerPrompt = "Tell me what to do: "
     
    private static let inventoryLocations = [-1, 255]
     
     /// Used by all Scott Adams adventure games. Do not change.
     enum Constants: Int {
         case inventory = -1
         case store = 0
         case verbTake = 10
         case verbDrop = 18
         case verbGo = 1
         case darknessFlag = 15
         case lightOutFlag = 16
         case lightSource = 9
     }
     
     static let sysMessages: [String] = [
         "OK\r\n", // 0
         " is a word I don't know...sorry!\r\n", // 1
         "I can't go in that direction\r\n", // 2
         "I'm in a ", // 3
         "Visible items here: ", // 4
         "Obvious exits: ", // 5
         "Tell me what to do", // 6
         "I don't understand\r\n", // 7
         "I'm carrying too much\r\n", // 8
         "I'm carrying:\r\n", // 9
         "Give me a direction too!\r\n", // 10
         "What?\r\n", // 11
         "Nothing\r\n", // 12
         "I've stored %d treasures. On a scale of 0 to 100, that rates %d\r\n", // 13
         "It's beyond my power to do that.\r\n", // 14
         "I don't understand your command.\r\n", // 15
         "I can't see. It is too dark!\r\n", // 16
         "Dangerous to move in the dark!\r\n", // 17
         "I fell down and broke my neck.\r\n", // 18
         "Light has run out!\r\n", // 19
         "Your light is growing dim.\r\n", // 20
         "Nothing taken.\r\n", // 21
         "Nothing dropped.\r\n", // 22
         "none.\r\n", // 23
         "I am dead.\r\n", // 24
         "\r\nThis game is now over\r\n", // 25
         "You have collected all the treasures!\r\n" // 26
     ]
     
     static let DirectionsLong = ["North", "South", "East", "West", "Up", "Down"]
    
    static let Abbreviations: [[String]] =
    [
        ["I", "INVENTORY"]
        , ["L", "LOOK"]
        , ["X", "EXAMINE"]
        , ["Z", "WAIT"]
        , ["T", "TAKE"]
        , ["D", "DROP"]
    ]

}
