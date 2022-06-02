/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Player actor implementations for the game.
*/

import Distributed

public typealias MyPlayer = OfflinePlayer
public typealias OpponentPlayer = OnlineBotPlayer

// ======= ------------------------------------------------------------------------------------------------------------
// - MARK: GamePlayer Protocol

public protocol GamePlayer: Sendable, Identifiable where ID == ActorIdentity {

    /// Ask this player to make a move of their own.
    func makeMove() async throws -> GameMove
    
    /// Inform this player their opponent has made the passed `move`.
    func opponentMoved(_ move: GameMove) async throws
}

// ======= ------------------------------------------------------------------------------------------------------------
// - MARK: Offline Player

#if canImport(SwiftUI)
public actor OfflinePlayer: GamePlayer {
    nonisolated public let id: ActorIdentity = .random

    let team: CharacterTeam
    let model: GameViewModel
    var movesMade: Int = 0

    public init(team: CharacterTeam, model: GameViewModel) {
        self.team = team
        self.model = model
    }

    public func makeMove() async throws -> GameMove {
        let field = await model.humanSelectedField()

        movesMade += 1
        let move = GameMove(
            playerID: self.id,
            position: field,
            team: team,
            teamCharacterID: movesMade % 2)

        return move
    }

    public func makeMove(at position: Int) async throws -> GameMove {
        let move = GameMove(
            playerID: id,
            position: position,
            team: team,
            teamCharacterID: movesMade % 2)

        log("player", "Player makes move: \(move)")
        _ = await model.userMadeMove(move: move)

        movesMade += 1
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
#endif

// ======= ------------------------------------------------------------------------------------------------------------
// - MARK: Distributed Bot Player

/// Local only distributed bot player
public distributed actor OnlineBotPlayer: GamePlayer {
    public typealias ActorSystem = WebSocketActorSystem

    var botAI: PlayerBotAI!
    var gameState: GameState

    public init(team: CharacterTeam, actorSystem: ActorSystem) {
        self.actorSystem = actorSystem
        self.botAI = RandomPlayerBotAI(playerID: self.id, team: team)
        self.gameState = .init()
    }

    public distributed func makeMove() throws -> GameMove {
        return try botAI.decideNextMove(given: &gameState)
    }

    public distributed func opponentMoved(_ move: GameMove) throws {
        try gameState.mark(move)
    }

}

// ======= ------------------------------------------------------------------------------------------------------------
// - MARK: Helper functions

func shouldWaitForOpponentMove(myselfID: ActorIdentity, opponentID: ActorIdentity) -> Bool {
    myselfID.hashValue < opponentID.hashValue
}
