//
//  ContentView.swift
//  WordScramble
//
//  Created by JooMin Choi on 15/09/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("\(rootWord)")
                        .font(.system(size: 20))
                        .frame(maxWidth: .infinity, alignment: .center)
                } header: {
                    Text("Word to scramble")
                } footer: {
                    Text("Rules: \n- Word has to be original \n- Word has to be possible from given word \n- Word has to be real \n- Word has to be more than 3 letters \n- Word can't be the starting word \n\n Scoring system: \n - 1 point for 4 letter word \n - 1 point for every extra letter after")
                }
                
                Section {
                    Text("\(score)")
                        .frame(maxWidth: .infinity, alignment: .center)
                } header: {
                    Text("Score")
                }
                
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                } header: {
                    Text("Answer")
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                } header: {
                    Text("Valid answers ✔️")
                }
            }
            .navigationTitle("WordScramble")
            
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("New word", action: startGame)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isMoreThanThreeLetters(word: answer) else {
            wordError(title: "Word too short", message: "Word has to be longer than 3 letters")
            return
        }
        
        guard isNotTheStartWord(word: answer) else {
            wordError(title: "Cheeky", message: "Word can't be the starting word")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            if answer.count == 4 {
                score += 1
            } else {
                score += answer.count - 3
            }
        }
        
        newWord = ""
            
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start",
                                               withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                score = 0
                usedWords = []
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isMoreThanThreeLetters(word: String) -> Bool {
        word.count > 3
    }
    
    func isNotTheStartWord(word: String) -> Bool {
        word != rootWord
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
