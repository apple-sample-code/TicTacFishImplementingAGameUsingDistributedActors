/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Global values, specifically the actor systems, which are singletons shared by the entire application.
*/

import Distributed
import TicTacFishShared

/// Shared instance of the sample websocket actor system used in this step.
///
/// It is started in "client only" mode, which makes it connect to the remote peer.
/// If the remote peer (server-side application) is not started yet, this will crash at startup.
/// To do this, select the `TicTacFishServer` scheme in Xcode and click run. Then, without quitting
/// the server process, switch back to `TicTacFish` and run it
///
/// As this is just a sample actor system implementation, it allows itself to be so aggressive about crashing.
/// In a solid implementation one might want to retry connecting and be a bit more lenient or even lazy about
/// connection establishment.
let webSocketSystem = try! WebSocketActorSystem(mode: .clientFor(host: "localhost", port: 8888))
