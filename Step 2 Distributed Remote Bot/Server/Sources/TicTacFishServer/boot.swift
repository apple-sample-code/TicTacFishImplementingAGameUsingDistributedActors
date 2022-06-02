/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The server-side Swift app that creates (on-demand) server-side bot players.
 Note that in this sample app they live forever, so we should implement some bounded
 lifecycle for them -- set up a deadline for a game to be played and then terminate
 the bot players to avoid them from lingering around forever.
*/

import Foundation
import Distributed
import TicTacFishShared

/// Run the server application by selecting the `TicTacFishServer` scheme when opening the Step 2 Workspace in Xcode.
/// You can also run this application directly from the command line, by invoking: `swift run` on macOS 13.
@main
struct Boot {
    
    static func main() {
        let system = try! WebSocketActorSystem(mode: .serverOnly(host: "localhost", port: 8888))
        
        system.registerOnDemandResolveHandler { id in
            // We create new BotPlayers "ad-hoc" as they are requested for.
            // Subsequent resolves are able to resolve the same instance.
            if system.isBotID(id) {
                return system.makeActorWithID(id) {
                    OnlineBotPlayer(team: .rodents, actorSystem: system)
                }
            }
            
            return nil // don't resolve on-demand
        }
        
        print("========================================================")
        print("=== TicTacFish Server Running on: ws://\(system.host):\(system.port) ==")
        print("========================================================")
        
        Thread.sleep(forTimeInterval: 100_000)
        print("Done.")
    }
}
