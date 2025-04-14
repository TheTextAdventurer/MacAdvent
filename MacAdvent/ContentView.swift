//
//  ContentView.swift
//  MacAdvent
//
//  Created by Andy Stobirski on 17/03/2025.
//

//  https://www.ifiction.org/games/playz.php

import SwiftUI
import UniformTypeIdentifiers

struct CustomFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("Courier New", size: 14)) // Specify your font here
    }
}

extension View {
    func customFont() -> some View {
        self.modifier(CustomFontModifier())
    }
}

struct ContentView: View {
    
    @State private var TextRoomView: String = "";
    @State private var TextUserInput: String = "";
    @State private var GameFileURL: URL? = nil //URL(string : "file:///Users/andystobirski/Downloads/advgames/adv01.dat");
    @FocusState private var isInputFocused: Bool

    
    var advent = Advent();

    var body: some View {
        VStack(spacing: 0) {
            
            // Roomview
            TextEditor( text: $TextRoomView)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color.gray.opacity(0.2))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 5)
                    .cornerRadius(8)
                    .frame(minWidth: 300, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
                    .disabled(true)
                    .customFont()

            // Userinput
            TextField("Tell me what to do...", text: $TextUserInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.white)
                .background(Color.black)
                .padding(.horizontal, 5)
                .padding(.vertical, 5)
                .cornerRadius(8)
                .focused($isInputFocused)
                .frame(maxWidth: .infinity)
                .customFont()
                .onSubmit {
                    if self.TextUserInput.trimmingCharacters(in: .whitespaces).count > 0 {
                        advent.UserInput(pInput: self.TextUserInput)
                        self.TextUserInput = ""
                    }
                }
            }
        
            .navigationTitle("Advent")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Button("New") {
                            self.GameFileURL = nil
                        }
                        Button("Open") {
                            Utils.pickFile() { url in
                                if let url = url {
                                    do
                                    {
                                        GameFileURL = url
                                        let content =  try String(contentsOf: url, encoding: .utf8)
                                        advent.load(pGame: content)
                                        advent.start()
                                    } catch {
                                        print("Error reading file: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label("File", systemImage: "folder")
                    }
                }
            }
            .frame(minWidth: 600, maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color.black)
            .onAppear{
                isInputFocused = true
                advent.onGameMessage = {(message, refresh) in
                    
                    if (refresh)
                    {
                        self.TextRoomView = message
                    }
                    else
                    {
                        self.TextRoomView += ("\n\(message)")
                    }
                }
                if let fileURL = Bundle.main.url(forResource: "adv04", withExtension: "dat") {
                    do {
                        let gameContent = try String(contentsOf: fileURL, encoding: .utf8)
                        advent.load(pGame: gameContent)
                        advent.start()
                    } catch {
                        print("Error reading file: \(error)")
                    }
                }
                
            }
        }

 }


#Preview {
    ContentView()
}

