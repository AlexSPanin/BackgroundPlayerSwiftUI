//
//  PlayerModel.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import Foundation


struct ButtonPlayer: Hashable {
    
    let type: PlayerCommand
    let name: String
    
    init(type: PlayerCommand, name: String) {
        self.type = type
        self.name = name
    }
}

struct PlayerModel: Hashable {
    var title = ""
    var passedTime = 0.0
    var leftTime = 0.0
    var currentTime = 0.0
    let buttons: [ButtonPlayer]
    
    init(buttons: [ButtonPlayer]) {
        self.buttons = buttons
    }
}
