//
//  AudioPlayer.swift
//  iMusic
//
//  Created by yfm on 2023/11/21.
//

import Foundation
import MobileVLCKit
import MediaPlayer
import Kingfisher

class AudioPlayer: NSObject {
    
    enum PlayMode: Int {
        case list
        case single
        case random
        
        var imageName: String {
            switch self {
            case .list:
                return "svg_kg_common_ic_player_mode_all_default"
            case .single:
                return "svg_kg_common_ic_player_mode_single_default"
            case .random:
                return "svg_kg_common_ic_player_mode_random_default"
            }
        }
    }
    
    enum ClockTime: Int {
        case close
        case time10
        case time15
        case time30
        case time60
        
        var seconds: Int {
            switch self {
            case .close: 0
            case .time10: 10 * 60
            case .time15: 15 * 60
            case .time30: 30 * 60
            case .time60: 60 * 60
            }
        }
    }
    
    static let shared = AudioPlayer()
    private override init() {
        super.init()
        playMode = localPlayMode
    }
    
    @objc dynamic var playState: VLCMediaPlayerState = .stopped
    @objc dynamic var time: Float = 0.0
    @objc dynamic var curIndex: Int = 0 {
        didSet {
            updateNowPlayingInfo(lrc: curSong.song_name)
            lrcData = LRCParse.parse(content: curSong.lrc)
        }
    }
    
    var lrcData: [LRCLine] = []
    
    // 播放模式
    var playMode: PlayMode = .list {
        didSet {
            switch playMode {
            case .list: playerList.repeatMode = .repeatAllItems
            case .single: playerList.repeatMode = .repeatCurrentItem
            case .random: playerList.repeatMode = .doNotRepeat
            }
            
            localPlayMode = playMode
        }
    }
    
    // 定时关闭
    var timer: Timer?
    @objc dynamic var countdownSeconds: Int = 0
    var clockTime: ClockTime = .close {
        didSet {
            if clockTime == .close {
                timer?.invalidate()
            } else {
                setupTimer()
            }
        }
    }
    
    var songs: [Song] = []
    
    var curSong: Song {
        return songs[curIndex]
    }
    
    var mediaList = VLCMediaList(array: [])! {
        didSet {
            playerList.mediaList = mediaList
        }
    }
    
    lazy var playerList: VLCMediaListPlayer = {
        let playerList = VLCMediaListPlayer()
        playerList.delegate = self
        playerList.mediaPlayer.delegate = self
        playerList.repeatMode = .repeatAllItems
        return playerList
    }()
    
    // 锁屏信息
    func updateNowPlayingInfo(lrc: String) {
        var dic: [String: Any] = [:]
        
        // 歌曲名
        dic[MPMediaItemPropertyTitle] = lrc
        
        // 作者名
        dic[MPMediaItemPropertyArtist] = AudioPlayer.shared.curSong.author_name + " - " + AudioPlayer.shared.curSong.song_name
        
        // 封面
        if let image = ImageCache.default.retrieveImageInMemoryCache(forKey: AudioPlayer.shared.curSong.img) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
            dic[MPMediaItemPropertyArtwork] = artwork
        }
        
        // 歌曲时长
        let duration = Float(AudioPlayer.shared.curSong.timelength) / 1000.0
        dic[MPMediaItemPropertyPlaybackDuration] = duration
        
        // 歌曲播放的时长
        let time = Double(truncating: AudioPlayer.shared.playerList.mediaPlayer.time.value ?? 0) / 1000.0
        dic[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
        
        // 速率
        dic[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = dic
    }
    
    func playOrPause() {
        if !playerList.mediaPlayer.isPlaying {
            playerList.mediaPlayer.play()
        } else {
            playerList.mediaPlayer.pause()
        }
    }
    
    func play() {
        if !playerList.mediaPlayer.isPlaying {
            playerList.mediaPlayer.play()
        }
    }
    
    func pause() {
        if playerList.mediaPlayer.isPlaying {
            playerList.mediaPlayer.pause()
        }
    }
    
    func playNext() {
        if playMode == .random {
            curIndex = randomIndex()
        } else {
            if curIndex < mediaList.count - 1 {
                curIndex += 1
            } else {
                curIndex = 0
            }
        }
        playItem(index: curIndex)
    }
    
    func playPrevious() {
        if playMode == .random {
            curIndex = randomIndex()
        } else {
            if curIndex > 0 {
                curIndex -= 1
            } else {
                curIndex = mediaList.count - 1
            }
        }
        playItem(index: curIndex)
    }
    
    func playItem(index: Int) {
        curIndex = index
        playerList.playItem(at: NSNumber(integerLiteral: index))
    }
    
    func seek(position: Float) {
        playerList.mediaPlayer.position = position
    }
    
    func randomIndex() -> Int {
        return Int(arc4random_uniform(UInt32(mediaList.count)))
    }
    
    func setupTimer() {
        timer?.invalidate()
        countdownSeconds = AudioPlayer.shared.clockTime.seconds
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.countdownSeconds -= 1
            if self.countdownSeconds <= 0 {
                self.timer?.invalidate()
                AudioPlayer.shared.pause()
                self.clockTime = .close
            }
        }
        timer?.fire()
        RunLoop.current.add(timer!, forMode: .common)
    }
}

extension AudioPlayer: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        let player = aNotification.object as! VLCMediaPlayer
        let state = player.state
        playState = state
                
//        switch state {
//        case .stopped:
//            print("stopped")
//        case .opening:
//            print("opening")
//        case .buffering:
//            print("buffering")
//        case .ended:
//            print("ended")
//        case .error:
//            print("error")
//        case .playing:
//            print("playing")
//        case .paused:
//            print("paused")
//        case .esAdded:
//            print("esAdded")
//        @unknown default:
//            break
//        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        let player = aNotification.object as! VLCMediaPlayer
        time = Float(truncating: player.time.value) / 1000
        
        let line = self.findCurPlayIndex(time: time)
        let lrcLineText = lrcData[line].text
        updateNowPlayingInfo(lrc: lrcLineText)
    }
    
    func findCurPlayIndex(time: Float) -> Int {
        var index = 0
        for i in 0..<lrcData.count {
            let line = lrcData[i]
            let lineTime = Float(CMTimeGetSeconds(line.time))
            if time <= lineTime {
                if i > 0 {
                    index = i - 1
                }
                break
            } else {
                index = lrcData.count - 1
            }
        }
        return index
    }
}

extension AudioPlayer: VLCMediaListPlayerDelegate {
    func mediaListPlayer(_ player: VLCMediaListPlayer!, nextMedia media: VLCMedia!) {
        let curMedia = player.mediaPlayer.media
        if let path = curMedia?.url.lastPathComponent {
            let mediaName = (path as NSString).deletingPathExtension
            for i in 0..<songs.count {
                let song = songs[i]
                if song.song_name == mediaName {
                    curIndex = i
                    break
                }
            }
        }
    }
    
    func mediaListPlayerStopped(_ player: VLCMediaListPlayer!) {
    }
    
    func mediaListPlayerFinishedPlayback(_ player: VLCMediaListPlayer!) {
    }
}

extension AudioPlayer {
    var localPlayMode: PlayMode {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: "localPlayMode")
            return PlayMode(rawValue: rawValue) ?? .list
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "localPlayMode")
            UserDefaults.standard.synchronize()
        }
    }
}
