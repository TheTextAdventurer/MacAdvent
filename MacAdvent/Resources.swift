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
        "item '%@' carried",                              // 0
        "item '%@' in room with player",                  // 1
        "item '%@' carried or in room with player",       // 2
        "player in room %d",                            // 3
        "item '%@' not in room with player",              // 4
        "item '%@' not carried",                          // 5
        "player not in room %d",                        // 6
        "bitflag %d is set",                            // 7
        "bitflag %d is false",                          // 8
        "something carried",                            // 9
        "nothing carried",                              // 10
        "item '%@' not carried or in room with player",   // 11
        "item '%@' in game",                              // 12
        "item '%@' not in game",                          // 13
        "current counter less than %d",                 // 14
        "current counter greater than '%@'",              // 15
        "object '%@' in initial location",                // 16
        "object '%@' not in initial location",            // 17
        "current counter equals %d"                     // 18
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
        "take item '%@'1, no check done to see if can carry",                   // 74  ONE ARG ITEM*
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
        "wait 2 seconds"                                                        // 88  NO ARGS*
        // 102+ print messages 52 to 99
        
    ]

    static let ActioNoArgs: [Int] = [56, 57,61, 63, 64, 65, 66, 67, 68, 69, 70, 71, 73, 76, 77, 78, 80, 82, 83, 84, 85, 86, 87, 88]
    static let ActionOneItem: [Int] = [52, 53, 55, 59, 74]
    static let ActionTwoItems : [Int] = [72, 75]
    static let ActionItemRoom: [Int] = [62]
    static let ActionRoom: [Int] = [54]
    static let ActionInteger: [Int] = [58, 60, 79, 81]

}
