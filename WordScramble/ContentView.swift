//
//  ContentView.swift
//  WordScramble
//
//  Created by Роман Люкевич on 23/03/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var averageLength = 0.0
    @State private var longestWord = 0
    

    
    var body: some View {
        NavigationView {
            List {
                
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) {word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                
                
                
            }
            .navigationTitle(rootWord)
            .toolbar {
                Button("New word", action: startGame)
                    .foregroundColor(.purple)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Text("Words: \(usedWords.count)")
                            .font(.title2.bold())
                        Spacer()
                        VStack (alignment: .leading){
                            
                            Text("Average length: \(String(format: "%.1f", averageLength))")
                            Text("Longest word: \(longestWord)")
                        }
                        
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding(15)
                    .background(.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                }
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }

    }
    
    func addNewWord() {
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
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
        
        guard answer.count > 0 else { return }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        countWords()
        newWord = ""
    }
    
    func startGame() {
        usedWords.removeAll()
        averageLength = 0.0
        longestWord = 0
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from Bundle.")
    }
    
    func countWords() {
        var lengthCounter = 0.0
        if !usedWords.isEmpty {
            for words in usedWords {
                lengthCounter += Double(words.count)
            }
            averageLength = lengthCounter/Double(usedWords.count)
        }
        
        for words in usedWords {
            if words.count > longestWord {
                longestWord = words.count
            }
        }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        if word.count < 3 {
            return false
        }
        
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

//let people = ["Finn", "Leia", "Luke", "Rey"]
//List {
//    ForEach(0..<5) {
//        Text("Dynamic row \($0)")
//    }
//}
//.listStyle(.grouped)
//
//
//List(0..<5) {
//    Text("Dynamic row \($0)")
//}
//
//
//List(people, id: \.self) {
//            Text($0)
//        }
//
//let input = "a b c"
//let letters = input.components(separatedBy: " ")
//let input = """
//            a
//            b
//            c
//            """
//let letters = input.components(separatedBy: "\n")
//let letter = letters.randomElement()
//let trimmed = letter?.trimmingCharacters(in: .whitespacesAndNewlines)
//let word = "swift"
//let checker = UITextChecker()
//let range = NSRange(location: 0, length: word.utf16.count)
//let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
//let allGood = misspelledRange.location == NSNotFound
//
//func loadFile() {
//    if let fileURL = Bundle.main.url(forResource: "some-file", withExtension: "txt") {
//        if let fileContents = try? String(contentsOf: fileURL) {
//            fileContents
//        }
//    }
//}
