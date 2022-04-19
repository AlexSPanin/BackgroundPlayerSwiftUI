//
//  PlayerViewModel.swift
//  BackgroundPlayerSwiftUI
//
//  Created by Александр Панин on 17.04.2022.
//

import AVFoundation
import MediaPlayer

class  PlayerViewModel: ObservableObject {
    
    @Published var playerModel: PlayerModel!
    @Published var indexAudioFile: Int
    let audioFilesModels: [AudioFileModel]
    let maxIndexAudioFile: Int
    
   
    private var sessionObserver: NSObjectProtocol!
    //    private var isEmptyAudioFile: Bool
    @Published var isPlaying = false
    {
        didSet
        {
            changePlayButton()
        }
    }
    
    private var needsScheduled = true
    private var audioEngine = AVAudioEngine()
    private var audioPlayerNode = AVAudioPlayerNode()
    private var audioFile = AVAudioFile()
    private var displayLink = CADisplayLink()
    
    init() {
        self.audioFilesModels = AudioFileDataManager.audioFilesModels
        self.maxIndexAudioFile = audioFilesModels.count - 1
        self.indexAudioFile = 0
        if !self.audioFilesModels.isEmpty { prepareAudioFile(audioFileModel: audioFilesModels[indexAudioFile])}
        settingPlayerButtons()
        
        prepareAudioFile(audioFileModel: audioFilesModels[indexAudioFile])
        prepareEngine()
        setupDisplayLink()
        
        do {
            try setupObservel()
            try setupRemoteComande(commandHandler: setupPlayerCommand(command:event:))
        }
        catch {
            print("ERROR setupRemoteComande")
        }
        //      handlePlaybackChange()
    }
    
    func setupRemoteComande(commandHandler: @escaping (PlayerCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus) throws {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        for command in PlayerCommand.allCases {
            command.setEnabled(true)
            command.addHandler (commandHandler)
        }
        PlayerMetadataManager.setStaticMetadata(audioFilesModels[indexAudioFile].metadata)
    }
    
    func setupPlayerCommand(command: PlayerCommand, event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        switch  command {
        case .back:
            backButton()
            PlayerMetadataManager.setStaticMetadata(audioFilesModels[indexAudioFile].metadata)
        case .togglePausePlay:
            playPauseButton()
        case .stop:
            stopButton()
        case .forward:
            forwardButton()
            PlayerMetadataManager.setStaticMetadata(audioFilesModels[indexAudioFile].metadata)
        case .changePlaybackPosition:
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed}
            changePlaybackPosition(to: event.positionTime)
        }
        return .success
    }
    
    
    
    func setupObservel() throws {
        
        let audioSession = AVAudioSession.sharedInstance()
        
        // Observe interruptions to the audio session.
        
        sessionObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: audioSession, queue: .current) {
            [unowned self] notification in
            self.handleAudioSessionInterruption(notification: notification)
            print("Notification \(notification)")
        }
        setupAudioSession()
        startEngine()
    }
    
    private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let interruptionTypeUInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeUInt) else { return }
        
        switch interruptionType {
            
        case .began:
            
            // When an interruption begins, just invoke the handler.
            
            print("Began \(userInfo)")
            
        case .ended:
            
            // When an interruption ends, determine whether playback should resume
            // automatically, and reactivate the audio session if necessary.
            
            do {
                
                try AVAudioSession.sharedInstance().setActive(true)
                
                if let optionsUInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
                   AVAudioSession.InterruptionOptions(rawValue: optionsUInt).contains(.shouldResume) {
                }
                
                print("Ended \(userInfo)")
            }
            
            // When the audio session cannot be resumed after an interruption,
            // invoke the handler with error information.
            
            catch {
                print("Catch \(userInfo)")
            }
            
        @unknown default:
            break
        }
    }
    
}

//MARK: - Display Link
extension PlayerViewModel {
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink.add(to: .current, forMode: .default)
        displayLink.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 50, __preferred: 30)
        displayLink.isPaused = true
    }
    
    @objc func updateDisplay() {
        let length = Float(audioFile.length) / Float(audioFile.fileFormat.sampleRate)
        if playerModel.passedTime < length {
        
        let rate = audioPlayerNode.rate
        guard let nodeTime = audioPlayerNode.lastRenderTime else {
            print("Error Node Time")
            return }
        guard let playerTime = audioPlayerNode.playerTime(forNodeTime: nodeTime) else {
            print("Error playerTime")
            return }
        let position = Float(playerTime.sampleTime) / Float(playerTime.sampleRate)
       
        
        playerModel.passedTime = position + playerModel.seekTime
        playerModel.leftTime = length - playerModel.passedTime
        

        
        let metadata = DynamicMetadataModel(rate: rate,
                                            position: playerModel.passedTime,
                                            duration: length)
        PlayerMetadataManager.setDinamicMetadata(metadata)
        } else {
            
            stopButton()
            
           
        }
    }
}

//MARK: - PlayerButtons
extension PlayerViewModel {
    
    func pressPlayerButtons(command: PlayerCommand) {
        switch  command {
        case .back:
            backButton()
        case .togglePausePlay:
            playPauseButton()
        case .stop:
            stopButton()
        case .forward:
            forwardButton()
        case .changePlaybackPosition:
            changePlaybackPosition(to: 10)
        }
    }
    
    private func settingPlayerButtons() {
        playerModel = PlayerModel(buttons: [
            ButtonPlayer(type: .back, name: "backward"),
            ButtonPlayer(type: .stop, name: "stop"),
            ButtonPlayer(type: .togglePausePlay, name: isPlaying ? "pause" : "play"),
            ButtonPlayer(type: .forward, name: "forward")
        ])
    }
    
    private func changePlayButton() {
        let name =  isPlaying ? "pause" : "play"
        playerModel.buttons[2].changeName(to: name)
    }
    
    private func playPauseButton() {
        
        switch isPlaying {
            
        case true:
            displayLink.isPaused = true
            isPlaying.toggle()
            audioPlayerNode.pause()
            audioEngine.pause()
        case false:
            isPlaying.toggle()
            startEngine()
            displayLink.isPaused = false
            if needsScheduled { scheduleAudioFile() }
            audioPlayerNode.play()
        }
    }
    
    private func stopButton() {
        displayLink.isPaused = true
        audioPlayerNode.stop()
   //     audioEngine.stop()
        needsScheduled = true
        playerModel.passedTime = 0
        playerModel.seekTime = 0
        playerModel.leftTime = Float(audioFile.length) / Float(audioFile.fileFormat.sampleRate)
        isPlaying = false
        displayLink.isPaused = true
        
    }
    
    private func backButton() {
        displayLink.isPaused = true
        if indexAudioFile != 0 {
            let wasPlaing = isPlaying
            if isPlaying { stopButton() }
            indexAudioFile -= 1
     //       audioEngine.reset()
            prepareAudioFile(audioFileModel: audioFilesModels[indexAudioFile])
      //      prepareEngine()
            needsScheduled = true
            playerModel.passedTime = 0
            playerModel.seekTime = 0
            playerModel.leftTime = Float(audioFile.length) / Float(audioFile.fileFormat.sampleRate)
            if wasPlaing { playPauseButton() }
        }
    }
    
    private func forwardButton() {
  
        if indexAudioFile < maxIndexAudioFile {
            let wasPlaing = isPlaying
            if isPlaying { stopButton() }
            indexAudioFile += 1
    //        audioEngine.reset()
            prepareAudioFile(audioFileModel: audioFilesModels[indexAudioFile])
     //       prepareEngine()
            needsScheduled = true
            playerModel.passedTime = 0
            playerModel.seekTime = 0
            playerModel.leftTime = Float(audioFile.length) / Float(audioFile.fileFormat.sampleRate)
            if wasPlaing { playPauseButton() }
        }
    }
    
    private func changePlaybackPosition(to position: TimeInterval) {

        seekPlaybackPosition(to: position - Double(playerModel.passedTime))
  
    }
    
    private func seekPlaybackPosition(to time: TimeInterval) {
        
      
        displayLink.isPaused = true
   //     audioEngine.pause()
        audioPlayerNode.stop()

        let length = Float(audioFile.length) / Float(audioFile.fileFormat.sampleRate)
        playerModel.seekTime = (Float(time) + playerModel.passedTime)
      
        playerModel.passedTime = playerModel.seekTime
        playerModel.leftTime = length - playerModel.passedTime
        
        scheduleAudioFile()
 
//        startEngine()
        if isPlaying { audioPlayerNode.play() }
        displayLink.isPaused = false
        
        
        
    }
    
    private func scheduleAudioFile() {

        let sampleRate = audioFile.fileFormat.sampleRate

        let startSample = AVAudioFramePosition(Double(playerModel.passedTime) * sampleRate)
        let countSample = AVAudioFrameCount(audioFile.length - startSample)
        audioPlayerNode.scheduleSegment(audioFile,
                                        startingFrame: startSample,
                                        frameCount: countSample,
                                        at: nil)
        needsScheduled = false

    }
    
//    private func scheduleAudioFile() {
//        audioPlayerNode.scheduleFile(audioFile, at: nil)
//        needsScheduled = false
//    }
    
}

//MARK: - AudioFile
extension PlayerViewModel {
    
    private  func prepareAudioFile(audioFileModel: AudioFileModel) {
        
        do {
            audioFile = try AVAudioFile(forReading: audioFileModel.url)
        } catch {
            print("ERROR prepare Audio File")
        }
    }
    
   
   
}

//MARK: - AudioEngine
extension PlayerViewModel {
    
    private func startEngine() {
        do {
            try audioEngine.start()
        } catch {
            print("ERROR start Engine")
        }
    }
    
    private func prepareEngine() {
        audioEngine.attach(audioPlayerNode)
        audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode , format: audioFile.processingFormat)
        audioEngine.prepare()
     
    }
}

//MARK: - AudioSession
extension PlayerViewModel {
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback,
                                    mode: .default)
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
}


