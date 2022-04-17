//
//  PlayerViewModel.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import AVFoundation

class  PlayerViewModel: ObservableObject {
    
    @Published var audioFilesModels: [AudioFileModel]
    
    var isPlaying = false
    var needsScheduled = true
    
    
    
    
    private var isEmptyAudioFile: Bool
    private var indexAudioFile: Int
    private var maxIndexAudioFile: Int
    
    private var audioEngine = AVAudioEngine()
    private var audioPlayerNode = AVAudioPlayerNode()
    private var audioFile = AVAudioFile()
    
    init(audioFilesModels: [AudioFileModel]) {
        self.audioFilesModels = audioFilesModels
        self.indexAudioFile = 0
        self.maxIndexAudioFile = audioFilesModels.count - 1
        isEmptyAudioFile = audioFilesModels.isEmpty
        if !isEmptyAudioFile { prepareAudioFile(audioFileModel: audioFilesModels[indexAudioFile])}
    }
    
    func playPauseButton() {
        
        switch isPlaying {
            
        case true:
            isPlaying.toggle()
            audioPlayerNode.pause()
            closeAudioSession()
        case false:
            isPlaying.toggle()
            setupAudioSession()
            prepareEngine()
            if needsScheduled { scheduleAudioFile() }
            audioPlayerNode.play()
        }
    }
    
    func stopButton() {
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
        closeAudioSession()
        isPlaying = false
        needsScheduled = true
    }
    
    func backButton() {
        if indexAudioFile != 0 {
            stopButton()
            indexAudioFile -= 1
            playPauseButton()
        }
    }
    
    func forwardButton() {
        if indexAudioFile < maxIndexAudioFile {
            stopButton()
            indexAudioFile += 1
            playPauseButton()
        }
    }
    
    
    func prepareAudioFile(audioFileModel: AudioFileModel) {
        
        do {
            audioFile = try AVAudioFile(forReading: audioFileModel.url)
        } catch {
            print("ERROR prepare Audio File")
        }
    }
    
    func prepareEngine() {
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode , format: audioFile.processingFormat)
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("ERROR prepare Engine")
        }
    }
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback,
                                    mode: .default,
                                    options: [.mixWithOthers, .defaultToSpeaker, .allowAirPlay])
          }
          catch {
              print("ERROR Playback Session")
          }
        do {
            try session.setActive(true)
        } catch {
            print("ERROR Active Audio Session")
        }
    }
    
    private func closeAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch {
            print("ERROR Close Audio Session")
        }
    }
   
    private func scheduleAudioFile() {
        audioPlayerNode.scheduleFile(audioFile, at: nil)
        needsScheduled = false
    }
}
