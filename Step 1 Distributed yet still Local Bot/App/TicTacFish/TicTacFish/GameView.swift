/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View representing a game of tic-tac-fish. Includes information which mode we're playing in, and a game field representation.
*/

import SwiftUI
import TicTacFishShared

struct GameView: View {
    
    @StateObject private var model: GameViewModel
    
    let mode: GameMode
    let player: MyPlayer
    
    init(mode: GameMode, team: CharacterTeam) {
        let model = GameViewModel(team: team)
        self._model = .init(wrappedValue: model)
        self.mode = mode
        
        switch mode {
        case .offline:
            self.player = OfflinePlayer(team: team, model: model)
            let opponentTeam: CharacterTeam = team == .fish ? .rodents : .fish
            model.opponent = BotPlayer(team: opponentTeam, actorSystem: localTestingActorSystem)

        default:
            fatalError("Mode not implemented in this Step: \(model), check the other Step projects of the Sample App")
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
            } else if model.opponent != nil {
                return Text("Opponent won!")
            } else {
                fatalError("Unexpected winner? \(winnerID)")
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
        
        // Matchmaking not really required, for now we only ever play offline.
        // This will be popualted during next steps of the sample app.
    }

}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(mode: .offline, team: .fish)
    }
}
