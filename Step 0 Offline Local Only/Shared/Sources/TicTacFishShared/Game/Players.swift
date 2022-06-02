/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Player actor implementations for the game.
*/

// ======= ------------------------------------------------------------------------------------------------------------
// - MARK: Bot Player

public actor BotPlayer: Identifiable {
    nonisolated public let id: ActorIdentity = .random
    
    var botAI: RandomPlayerBotAI
    var gameState: GameState
    
    public init(team: CharacterTeam) {
        self.gameState = .init()
        self.botAI = RandomPlayerBotAI(playerID: self.id, team: team)
    }
    
    public func makeMove() throws -> GameMove {
        return try botAI.decideNextMove(given: &gameState)
    }
    
    public func opponentMoved(_ move: GameMove) async throws {
        try gameState.mark(move)
    }
}

// ======= ------------------------------------------------------------------------------------------------------------
// - MARK: Offline Player

public actor OfflinePlayer: Identifiable {
    nonisolated public let id: ActorIdentity = .random

    let team: CharacterTeam
    let model: GameViewModel
    var movesMade: Int = 0

    public init(team: CharacterTeam, model: GameViewModel) {
        self.team = team
        self.model = model
    }

    /// Poll move from UI by awaiting on user clicking one of the game fields.
    public func makeMove() async throws -> GameMove {
        let field = await model.humanSelectedField()
        defer { movesMade += 1 }
        
        let move = GameMove(
            playerID: self.id,
            position: field,
            team: team,
            teamCharacterID: team.characterID(for: movesMade))

        return move
    }
    
    public func makeMove(at position: Int) async throws -> GameMove {
        defer { movesMade += 1 }
        let move = GameMove(
            playerID: id,
            position: position,
            team: team,
            teamCharacterID: team.characterID(for: movesMade))
        
        log("player", "Player makes move: \(move), moves made: \(movesMade)")
        _ = await model.userMadeMove(move: move)
        
        return move
    }

    public func opponentMoved(_ move: GameMove) async throws {
        do {
            try await model.markOpponentMove(move)
        } catch {
            log("player", "Opponent made illegal move! \(move)")
        }
    }

}

// ======= -------
// - MARK: Helper functions

public typealias MyPlayer = OfflinePlayer
public typealias OpponentPlayer = BotPlayer

func shouldWaitForOpponentMove(myselfID: ActorIdentity, opponentID: ActorIdentity) -> Bool {
    myselfID.hashValue < opponentID.hashValue
}

