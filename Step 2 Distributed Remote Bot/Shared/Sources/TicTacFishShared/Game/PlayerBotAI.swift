/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Fake "AI" implementation for our bot player.
*/

protocol PlayerBotAI {
    mutating func decideNextMove(given gameState: inout GameState) throws -> GameMove
}

enum BotAIDifficulty: String {
    case easy
    case hard
}

struct RandomPlayerBotAI: PlayerBotAI {
    let playerID: ActorIdentity
    let team: CharacterTeam
    
    private var movesMade: Int = 0
    
    init(playerID: ActorIdentity, team: CharacterTeam) {
        self.playerID = playerID
        self.team = team
    }
    
    mutating func decideNextMove(given gameState: inout GameState) throws -> GameMove {
        guard gameState.checkWin() == nil else {
            throw NoMoveAvailable()
        }
        
        var selectedPosition: Int?
        for position in gameState.availablePositions.shuffled() {
            if gameState.at(position: position) == nil {
                selectedPosition = position
                break
            }
        }
        guard let selectedPosition = selectedPosition else {
            throw NoMoveAvailable()
        }
        
        movesMade += 1
        let move = GameMove(
            playerID: playerID,
            position: selectedPosition,
            team: team,
            teamCharacterID: movesMade % 2)
        
        try gameState.mark(move)
        return move
    }
}

struct NoMoveAvailable: Error {}
