//
//  ContentView.swift
//  MacAdvent
//
//  Created by Andy Stobirski on 17/03/2025.
//

import SwiftUI
import UniformTypeIdentifiers


struct ContentView: View {
    
    @State private var TextGameOutput: String = "";
    @State private var TextUserInput: String = "";
    @State private var GameFileURL: URL? = URL(string : "file:///Users/andystobirski/Downloads/advgames/adv01.dat");
    
    var advent = Advent();
        
    

    var body: some View {
            VStack {
                // Multi-line text box
                TextEditor(text: $TextGameOutput)
                    .textFieldStyle(RoundedBorderTextFieldStyle()) 
                    .background(Color.gray.opacity(0.2))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .cornerRadius(8)
                    .frame(maxHeight: .infinity)
                    .onAppear {
                        advent.onGameMessage = {message in
                            TextGameOutput = message
                        }
                    }

                // One-line text box
                TextField("Tell me what to do...", text: $TextUserInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle()) // Use plain style to customize
                    .foregroundColor(.white)
                    .background(Color.black) 
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .cornerRadius(8)
                    .onSubmit {
                        advent.UserInput (pInput: self.TextUserInput)
                        self.TextUserInput = ""
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
                            openFile()
                        }
                        Button("Save") {
                            // Action for Save
                        }
                        Button("Reset") {
                            // Action for Save
                        }
                    } label: {
                        Label("File", systemImage: "folder")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color.white)
            .onAppear{
                
                if let fileURL = Bundle.main.url(forResource: "adv01", withExtension: "dat") {
                    do {
                        let gameContent = try String(contentsOf: fileURL, encoding: .utf8)
                        advent.load(pGame: gameContent)
                    } catch {
                        print("Error reading file: \(error)")
                    }
                } else {
                    print("File not found")
                }
            }
        }

    
    func openFile() {

            let panel = NSOpenPanel()
            panel.allowedContentTypes = [UTType.data] // General data type
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = false
            
            panel.begin { result in
                if result == .OK, let url = panel.url {
                    if url.pathExtension == "dat" { // Check for .dat extension
                        do {
                            GameFileURL = url
                            let content =  try String(contentsOf: url, encoding: .utf8)
                            advent.load(pGame: content)
                        } catch {
                            print("Error loading file: \(error)")
                        }
                    } else {
                        print("Invalid file type selected.")
                    }
                }
            }
        }
}

#Preview {
    ContentView()
}

