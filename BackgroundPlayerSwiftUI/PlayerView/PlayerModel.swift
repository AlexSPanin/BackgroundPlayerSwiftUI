//
//  PlayerModel.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import Foundation


struct ButtonPlayer {
    
    let type: PlayerCommand
    let name: String
    
    init(type: PlayerCommand, name: String) {
        self.type = type
        self.name = name
    }
}

struct PlayerModel {
    var title = ""
    var passedTime = 0.0
    var leftTime = 0.0
    var currentTime = 0.0
    var buttons: [ButtonPlayer] {
        [
            ButtonPlayer(type: .back, name: "backward"),
            ButtonPlayer(type: .play, name: "play"),
            ButtonPlayer(type: .stop, name: "stop"),
            ButtonPlayer(type: .pause, name: "pause"),
            ButtonPlayer(type: .forward, name: "forward")
        ]
    }
}
