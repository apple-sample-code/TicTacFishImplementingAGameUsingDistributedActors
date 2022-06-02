/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The main view of the application from which the user can select a game mode, and team to play as.
*/

import SwiftUI
import TicTacFishShared

/// ## Important: Run the `TicTacFishServer` to try this game mode
///
/// To run the this app you'll need to first launch the server-side application;
/// To do so select the `TicTacFishServer` scheme in Xcode, and run it,
/// afterwards you can switch back (while the server is running) to the `TicTacFish` scheme and run it.
/// This way the mobile game will connect to the localhost served server-side bot player this step is showcasing.
struct MainMenuView: View {
    
    @State private var selectedGameMode: GameMode?
    @State private var selectedTeam: CharacterTeam = .fish

    var body: some View {
        NavigationView {
            VStack {
                TitleView(selectedTeam: selectedTeam, mode: nil)
                Text("The distributed actor TicTacToe game!")
                    .font(.title2)
                
                VStack {
                    Text("Select Team:")
                    Picker("Select Team:", selection: $selectedTeam) {
                        Text("Fish (\(CharacterTeam.fish.emojiArray.joined(separator: "")))").tag(CharacterTeam.fish)
                        Text("Rodents (\(CharacterTeam.rodents.emojiArray.joined(separator: "")))").tag(CharacterTeam.rodents)
                    }.pickerStyle(.segmented)
                }.padding(5)
                
                VStack {
                    Button("Play offline") { selectedGameMode = .offline }.bold()
                    Text("(Against Fishy AI)").fontWeight(.light)
                }
                
                VStack {
                    Button("Play Online Match vs. AI") { selectedGameMode = .internet }.bold()
                    Text("(Internet)").fontWeight(.light)
                }.padding(2)

                Spacer()
            }.navigate(using: $selectedGameMode, using: $selectedTeam, destination: makeGameView)
        }
    }
    
    func makeGameView(mode: GameMode, team: CharacterTeam) -> some View {
        GameView(mode: mode, team: team)
    }
}

// - MARK: Navigation helpers

extension NavigationLink where Label == EmptyView {
    init?<Value1, Value2>(
        _ binding1: Binding<Value1?>,
        _ binding2: Binding<Value2>,
        @ViewBuilder destination: (Value1, Value2) -> Destination
    ) {
        guard let value1 = binding1.wrappedValue else {
            return nil
        }
        let value2 = binding2.wrappedValue

        let isActive = Binding(
            get: {
                true
            },
            set: { newValue in
                if !newValue {
                    binding1.wrappedValue = nil
                }
            }
        )

        self.init(destination: destination(value1, value2), isActive: isActive, label: EmptyView.init)
    }
}

extension View {
    @ViewBuilder
    func navigate<Value1, Value2, Destination: View>(
        using binding1: Binding<Value1?>,
        using binding2: Binding<Value2>,
        @ViewBuilder destination: (Value1, Value2) -> Destination
    ) -> some View {
        background(NavigationLink(binding1, binding2, destination: destination))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
