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
        "item arg carried",
        "item arg in room with player",
        "item arg carried or in room with player",
        "player in room arg", // 3
        "item arg not in room with player", // 4
        "item arg not carried", // 5
        "player not in room arg", // 6
        "bitflag arg is set",
        "bitflag arg is false",
        "something carried",
        "nothing carried",
        "item arg not carried or in room with player", // 11
        "item arg in game", // 12
        "item arg not in game", // 13
        "current counter less than arg", // 14
        "current counter greater than arg", // 15
        "object arg in initial location", // 16
        "object arg not in initial location", // 17
        "current counter equals arg"
    ]

    static let conditionsWithItems: [Int] = [0, 1, 2, 5, 11, 12, 13, 16, 17]

    static let actions: [String] = [
        "get item ARG1, check if can carry", // 52
        "drops item ARG1 into current room", // 53
        "move room ARG1", // 54
        "Item ARG1 is removed from the game (put in room 0)", // 55
        "set darkness flag",
        "clear darkness flag",
        "set ARG1 flag", // 58
        "Item ARG1 is removed from the game (put in room 0)", // 59
        "set ARG1 flag", // 60
        "Death, clear dark flag, move to last room",
        "item ARG1 is moved to room ARG2", // 62
        "game over",
        "look",
        "score", // 65
        "output inventory",
        "Set bit 0 true",
        "Set bit 0 false",
        "refill lamp",
        "clear screen",
        "save game",
        "swap item locations ARG1 ARG2", // 72
        "continue with next action",
        "take item ARG1, no check done to see if can carry", // 74
        "put item 1 ARG1 with item2 ARG2", // 75
        "look",
        "decrement current counter", // 77
        "output current counter", // 77
        "set current counter value arg1",
        "swap location with saved location",
        "Select counter arg1. Current counter is swapped with backup counter", // 80
        "add to current counter", // 81
        "subtract from current counter", // 82
        "echo noun without cr", // 83
        "echo noun",
        "Carriage Return", // 85
        "Swap current location value with backup location-swap value", // 86
        "wait 2 seconds"
    ]

    static let twoArgActions: [Int] = [62, 72, 75]
    static let oneActionArgs: [Int] = [52, 53, 54, 55, 58, 59, 60, 74, 78, 81, 82, 83, 79]

    static let actionArgsWithOneItem: [Int] = [52, 53, 55, 59, 74, 62] // note 62, a two arg action which moves item arg1 to room arg2
    static let actionsWithTwoItems: [Int] = [72, 75]
}
