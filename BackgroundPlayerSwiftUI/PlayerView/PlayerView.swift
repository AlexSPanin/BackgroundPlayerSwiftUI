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
        VStack(alignment: .leading, spacing: 20) {
            Text(viewModel.audioFilesModels[viewModel.indexAudioFile].metadata.title)
            
            HStack {
                Text(TimeManager.timeFormated(to: viewModel.playerModel.passedTime))
                Spacer()
                Text(TimeManager.timeFormated(to: viewModel.playerModel.leftTime))
            }
            .frame(width: 190, height: 40)

            
            HStack(spacing: 10) {
                ForEach(viewModel.playerModel.buttons, id: \.self) { button in
                    Button {
                        viewModel.pressPlayerButtons(command: button.type)
                    } label: {
                        Image(systemName: button.name)
                    }
                    .frame(width: 40, height: 40, alignment: .center)
                    
                }
            }
            
        }
        .padding()
    }
    
    
    
    
    
}




//struct PlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayerView()
//    }
//}
