/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View representing a game of tic-tac-fish. Includes information which mode we're playing in, and a game field representation.
*/

import SwiftUI
import TicTacFishShared
import Distributed

/// ## Important: Run the `TicTacFishServer` to try this game mode
///
/// To run the this app you'll need to first launch the server-side application;
/// To do so select the `TicTacFishServer` scheme in Xcode, and run it,
/// afterwards you can switch back (while the server is running) to the `TicTacFish` scheme and run it.
/// This way the mobile game will connect to the localhost served server-side bot player this step is showcasing.
struct GameView: View {
    
    @StateObject private var model: GameViewModel
    
    let mode: GameMode
    
    // Change the typealias as we move through different implementations
    let player: MyPlayer
    
    init(mode: GameMode, team: CharacterTeam) {
        let model = GameViewModel(team: team)
        self._model = .init(wrappedValue: model)
        self.mode = mode
        
        switch mode {
        case .offline:
            fatalError("Only works during step 1")
            
        case .internet:
            // STEP 2: against remote AI
            let player = OfflinePlayer(team: team, model: model)
            self.player = player
            model.opponent = nil // we'll kick off searching for an opponent immediately as View appears

        case .localNetwork:
             fatalError("Only works during step 3")
        }
    }
    
    var body: some View {
        TitleView(selectedTeam: model.team, mode: mode)
        
        Text("My Player ID")
        Text("\(String(describing: self.player.id))").fontWeight(.light)
        
        if let opponent = model.opponent {
            Text("Opponent ID")
            Text(String(describing: opponent.id)).fontWeight(.light)
        } else {
            matchMakingView()
        }
        
        Spacer()
        
        LazyVGrid(columns: model.columns) {
            ForEach(model.fields, id: \.self) { position in
                GameFieldView(position: position, model: model) { position in
                    _ = try await player.makeMove(at: position)
                }
            }
        }
        
        gameResultRowView()
        
        Spacer()
    }
    
}

// - MARK: Additional Views

extension GameView {
    
    func titleText() -> some View {
        let text: Text
        switch mode {
        case .offline:
            text = Text("Playing offline")
        case .localNetwork:
            text = Text("Playing over LocalNetwork")
        case .internet:
            text = Text("Playing Online")
        }
        
        return VStack {
            Text("Tic Tac Fish 🐟").bold().font(.title)
            text
        }.padding(3)
    }
    
    func matchMakingView() -> some View {
        HStack {
            ProgressView().padding(2)
            Text("Looking for opponent...")
        }.onAppear {
            startMatchMaking()
        }
    }
    
    func gameResultRowView() -> some View {
        switch model.gameResult {
        case .win(let winnerID):
            if player.id == winnerID {
                return Text("You win!")
            } else {
                return Text("Opponent won!")
            }
        case .draw:
            return Text("Game ended in a Draw!")
        case .none:
            return Text("")
        }
    }
}

// - MARK: Minimal logic helpers

extension GameView {
    
    func startMatchMaking() {
        guard model.opponent == nil else {
            return
        }
        
        // Play with online bot
        switch mode {
        case .internet:
            let opponentID = webSocketSystem.opponentBotID(for: player)
            let opponent = try! OnlineBotPlayer.resolve(id: opponentID, using: webSocketSystem)
            model.opponent = opponent
            return
        default:
            break
        }
    }
    
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(mode: .offline, team: .fish)
    }
}
