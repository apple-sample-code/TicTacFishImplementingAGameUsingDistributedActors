/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Enum used to represent the team a player is part of. Each team has a few characters associated that are used for the moves the player will be making.
*/

/// Represents which "team" a player is playing for.
/// Currently two teams are available,
public enum CharacterTeam: Sendable, Codable {
    case fish
    case rodents

    /// Array of emojis used by the team.
    public var emojiArray: [String] {
        switch self {
        case .fish: return ["🐟", "🐠", "🐡"]
        case .rodents: return ["🐹", "🐭", "🐰"]
        }
    }

    /// Select an emoji for a given move number.
    ///
    /// - Parameter index: non negative move index
    /// - Returns: emoji identified by the move index
    public func select(_ index: Int) -> String {
        precondition(index >= 0)
        let arr = emojiArray
        return arr[index % arr.count]
    }

    /// Determine the character ID for a given move number.
    /// Concretely identifies a specific character from the emoji character set used by a team.
    /// - Parameter moveNumber: number of move
    /// - Returns: character id, which can be used to obtain character emoji
    static func characterID(for moveNumber: Int) -> Int {
        guard moveNumber > 0 else {
            return 0
        }

        return moveNumber % Self.fish.emojiArray.count
    }

    public func characterID(for moveNumber: Int) -> Int {
        Self.characterID(for: moveNumber)
    }

    public init?(_ emoji: String) {
        switch emoji {
        case "🐟", "🐠", "🐡": self = .fish
        case "🐹", "🐭", "🐰": self = .rodents
        default: return nil
        }
    }
}
