/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Global values, specifically the actor systems, which are singletons shared by the entire application.
*/

import Distributed
import TicTacFishShared

/// Shared instance of the local networking sample actor system.
///
/// Note also that in `Info.plist` we must define the appropriate NSBonjourServices
/// in order for the peer-to-peer nodes to be able to discover each other.
let localNetworkSystem = SampleLocalNetworkActorSystem()
