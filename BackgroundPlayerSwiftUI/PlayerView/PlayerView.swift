//
//  PlayerView.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import SwiftUI

struct PlayerView: View {
    
    @StateObject private var viewModel = PlayerViewModel()

    
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(viewModel.playerButton.buttons, id: \.self) { button in
                Button {
                    viewModel.pressPlayerButtons(button: button)
                } label: {
                    Image(button.name)
                }
                    
                }
                
            }
            
            
        }
    
    
    
    
    
    }




//struct PlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayerView()
//    }
//}
