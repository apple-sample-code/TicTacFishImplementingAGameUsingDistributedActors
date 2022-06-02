/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Global values, specifically the actor systems, which are singletons shared by the entire application.
*/

import Distributed

/// Shared instance of the local testing actor system used in the sample app.
let localTestingActorSystem = LocalTestingDistributedActorSystem()
