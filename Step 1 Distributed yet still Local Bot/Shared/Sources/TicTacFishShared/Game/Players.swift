/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Player actor implementations for the game.
*/

import Distributed

// ======= ------------------------------------------------------------------------------------------------------------
// - MARK: Bot Player

public distributed actor BotPlayer: Identifiable {
    public typealias ActorSystem = LocalTestingDistributedActorSystem
    
    var botAI: RandomPlayerBotAI
    var gameState: GameState
    
    public init(team: CharacterTeam, actorSystem: LocalTestingDistributedActorSystem) {
        self.actorSystem = actorSystem
        self.gameState = .init()
        self.botAI = RandomPlayerBotAI(playerID: self.id, team: team)
    }
    
    public distributed func makeMove() throws -> GameMove {
        return try botAI.decideNextMove(given: &gameState)
    }
    
    public distributed func opponentMoved(_ move: GameMove) async throws {
        try gameState.mark(move)
    }
    
}

// ======= ------------------------------------------------------------------------------------------------------------
// - MARK: GamePlayer Protocol

/// A general game player protocol.
///
/// As all players in our game are represented as actors, we use the AnyActor protocol here, which gives us the
/// freedom to implement this protocol using an `actor` or `distributed actor`.
public protocol GamePlayer: AnyActor, Identifiable where ID == ActorIdentity {

    /// Ask this player to make a move of their own.
    func makeMove() async throws -> GameMove
    
    /// Inform this player their opponent has made the passed `move`.
    func opponentMoved(_ move: GameMove) async throws
    
}

// ======= ------------------------------------------------------------------------------------------------------------
// - MARK: Offline Player

public actor OfflinePlayer: GamePlayer {
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

