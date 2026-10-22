import SwiftUI
import Playgrounds

struct ContentView: View {
    @State private var isGameOver = false
    @State private var maxiumNumberOfGuessesReached = false
    @State private var guesses = [String]()
    @State private var guess = ""
    @State private var answer = ""
    @AppStorage("maximumGuesses") var maximumGuesses = 100
    @AppStorage("answerLength") var answerLength = 4
    @AppStorage("enableHardMode") var enableHardMode = false
    @AppStorage("showGuessCount") var showGuessCount = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Enter a guess", text: $guess)
                    .onSubmit(submitGuess)
                Button("Go", action: submitGuess)
            }
            .padding()
            
            List(0..<guesses.count, id: \.self) { index in
                let guess = guesses[index]
                let shouldShowResult = (enableHardMode == false) ||
                (enableHardMode && index == 0)
                HStack {
                    Text(guess)
                    Spacer()
                    if shouldShowResult {
                        Text(result(for: guess))
                    }
                }
            }
            .listStyle(.sidebar)
            
            if showGuessCount {
                Text("Guesses: \(guesses.count)/\(maximumGuesses)")
                    .padding()
            }
        }
        .frame(width: 250)
        .frame(minHeight: 300)
        .onChange(of: answerLength, initial: true) {
            startNewGame()
        }
        .alert("Game Over", isPresented: $maxiumNumberOfGuessesReached) {
            Button("OK", action: startNewGame)
        } message: {
            Text("You've reached the maximum number of guesses. Start again.")
        }
        .alert("You win!", isPresented: $isGameOver) {
            Button("OK", action: startNewGame)
        } message: {
            Text("Congratulations! Click OK to play again.")
        }
        .navigationTitle("Cows and Bulls")
    }
    
    private func startNewGame() {
        guard answerLength >= 3 && answerLength <= 8 else { return }
        
        guess = ""
        guesses.removeAll()
        answer = ""
        
        let numbers = (0...9).shuffled()
        
        for i in 0..<answerLength {
            answer.append(String(numbers[i]))
        }
    }
    
    private func result(for guess: String) -> String {
        var bulls = 0
        var cows = 0
        
        let guessLetters = Array(guess)
        let answerLetters = Array(answer)
        
        for (i, letter) in guessLetters.enumerated() {
            if letter == answerLetters[i] {
                bulls += 1
            } else if answerLetters.contains(letter) {
                cows += 1
            }
        }
        
        return "\(bulls)b \(cows)c"
    }
    
    private func submitGuess() {
        print(answer)
        guard guesses.count < maximumGuesses else {
            maxiumNumberOfGuessesReached = true
            return
        }
        guard Set(guess).count == answerLength else { return }
        guard guess.count ==  answerLength else { return }
        
        let notAllowedCharacters = CharacterSet(charactersIn: "0123456789").inverted
        guard guess.rangeOfCharacter(from: notAllowedCharacters) == nil else { return }
        
        withAnimation {
            guesses.insert(guess, at: 0)
        }
        
        if guess == answer {
            isGameOver = true
        }
        
        guess = ""
    }
}

#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
