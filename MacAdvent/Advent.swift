//
//  Advent.swift
//  MacAdvent
//
//  Created by Andy Stobirski on 17/03/2025.
//
import Foundation

extension String {
    func trimEdges() -> String {
        let unwantedCharacters = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "\"'"))
        return self.trimmingCharacters(in: unwantedCharacters)
    }
}


class Advent {

    var onGameMessage: ((String) -> Void)?
    var GameFile : DatFile?

    init(){
    }
    
    func load(pGame: String){
        GameFile = ConvertDat.Load(pGame: pGame)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func GameMessage(pMessage: String )
    {
        onGameMessage?(pMessage)
    }

    func UserInput(pInput: String)
    {
        GameMessage(pMessage: pInput)
    }
}

