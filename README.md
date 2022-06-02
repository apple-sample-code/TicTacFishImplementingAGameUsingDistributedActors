# TicTacFish: Implementing a game using distributed actors

Use distributed actors to take your Swift concurrency and actor-based apps beyond a single process.

## Overview

- Note: This sample code project is associated with WWDC22 session [110356: Meet distributed actors in Swift](https://developer.apple.com/wwdc22/110356/).

## Configure the sample code project

Because the sample app uses new Swift language features introduced in Swift 5.7, you need at least the following versions of iOS, macOS, and Xcode to edit and run the samples:

To run the iOS app:

- iOS 16
- macOS 13
- Xcode 14

To run the server-side application on your local Mac:

- macOS 13
- Xcode 14

To run the server-side application on a Linux server, compile and run the `Server` package using:

- Any supported Linux distribution
- Swift 5.7

You can try out the peer-to-peer local networking part of the sample app by starting multiple simulators (such as an iPhone 13 and an iPhone 13 Pro) from the same Xcode project.

