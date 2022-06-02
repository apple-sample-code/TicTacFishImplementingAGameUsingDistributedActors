/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Global values, specifically the actor systems, which are singletons shared by the entire application.
*/

import TicTacFishShared
import Distributed

let localTestingActorSystem: LocalTestingDistributedActorSystem = LocalTestingDistributedActorSystem()
