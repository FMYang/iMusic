//
//  PlayerView.swift
//  iMusic
//
//  Created by yfm on 2023/11/20.
//

import UIKit
import MobileVLCKit

class PlayerView: UIView {
    
    var playing: Bool = false {
        didSet {
            let iconName = playing ? "miniapp_playbar_pause" : "miniapp_playbar_play"
            playOrPauseButton.setImage(UIImage(named: iconName), for: .normal)
            playing ? startAnimation() : stopAnimation()
        }
    }
    
    var didAddAnimation = false
    var playOrPauseClosure: (()->Void)?
    var nextClosure: (()->Void)?
    var iconTapClosure: (()->Void)?
    
    lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 27
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        view.image = UIImage(named: "svg_kg_playpage__album_default_01")
        return view
    }()
    
    lazy var nameLabel: UILabel = {
//        let label = ScrollingLabel(frame: CGRectMake(0, 0, kScreenWidth-180, 20))
        let label = UILabel()
        label.textColor = .black.withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 16)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var lrcLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 16)
        label.text = ""
        return label
    }()
    
    lazy var playOrPauseButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(playOrPauseAction), for: .touchUpInside)
        btn.setImage(UIImage(named: "miniapp_playbar_pause"), for: .normal)
        return btn
    }()
    
    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        btn.setImage(UIImage(named: "miniapp_playbar_next"), for: .normal)
        return btn
    }()
    
    lazy var tapView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        let ges = UITapGestureRecognizer(target: self, action: #selector(iconTapAction))
        view.addGestureRecognizer(ges)
        return view
    }()
    
    lazy var progressView: ProgressView = {
        let view = ProgressView()
        return view
    }()
    
    var statusObservers: [NSKeyValueObservation?] = []
    
    init() {
        super.init(frame: .zero)
        layer.cornerRadius = 27
        backgroundColor = UIColor(valueRGB: 0xf2ebef)
        makeUI()
        addKVO()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addKVO() {
        let statusObserver = AudioPlayer.shared.observe(\.playState, options: [.new]) { [weak self] model, change in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.playing = model.playerList.mediaPlayer.isPlaying
                
//                if model.playerList.mediaPlayer.state == .ended {
//                    self.progressView.progress = 0.0
//                }
            }
        }
        
        let indexObserver = AudioPlayer.shared.observe(\.curIndex, options: [.new]) { [weak self] model, change in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let index = AudioPlayer.shared.curIndex
                let song = AudioPlayer.shared.songs[index]
                self.config(song: song)
            }
        }
        
        let timeObserver = AudioPlayer.shared.observe(\.time, options: [.new]) { [weak self] model, change in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let index = AudioPlayer.shared.lrcLineIndex
                let data = AudioPlayer.shared.lrcData
                if index < data.count {
                    let lrcLine = data[index]
                    self.lrcLabel.text = lrcLine.text
                }
                
//                self.progressView.progress = CGFloat(AudioPlayer.shared.playerList.mediaPlayer.position)
            }
        }
        statusObservers.append(timeObserver)
        statusObservers.append(statusObserver)
        statusObservers.append(indexObserver)
    }
        
    func config(song: Song) {
        iconImageView.kf.setImage(with: URL(string: song.img)!, placeholder: UIImage(named: "svg_kg_playpage__album_default_01"))
        nameLabel.text = song.song_name + " - " + song.author_name
        lrcLabel.text = song.song_name
    }
    
    func startAnimation() {
        if !didAddAnimation {
            iconImageView.layer.removeAllAnimations()
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = NSNumber(value: 2*Double.pi)
            rotationAnimation.duration = 10.0
            rotationAnimation.repeatCount = .greatestFiniteMagnitude
            rotationAnimation.isRemovedOnCompletion = false
            rotationAnimation.fillMode = .forwards
            iconImageView.layer.add(rotationAnimation, forKey: "")
            didAddAnimation = true
        }
    }
    
    func stopAnimation() {
        didAddAnimation = false
        iconImageView.layer.removeAllAnimations()
    }
    
    @objc func playOrPauseAction() {
        playOrPauseClosure?()
    }
    
    @objc func nextAction() {
        nextClosure?()
    }
    
    @objc func iconTapAction() {
        iconTapClosure?()
    }
    
    func makeUI() {
        addSubview(iconImageView)
        addSubview(nameLabel)
        addSubview(lrcLabel)
        addSubview(playOrPauseButton)
        addSubview(nextButton)
//        addSubview(progressView)
        addSubview(tapView)
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(54)
            make.top.left.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(15)
            make.bottom.equalToSuperview().offset(-5)
            make.right.equalTo(playOrPauseButton.snp.left).offset(-10)
            make.height.equalTo(20)
        }
        
        lrcLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(15)
            make.top.equalToSuperview().offset(5)
            make.right.equalTo(playOrPauseButton.snp.left).offset(-10)
            make.height.equalTo(20)
        }
        
        playOrPauseButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.right.equalTo(nextButton.snp.left)
        }
        
        nextButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
        
        tapView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(playOrPauseButton.snp.left).offset(-10)
        }
        
//        progressView.snp.makeConstraints { make in
//            make.left.right.equalTo(lrcLabel)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(2)
//        }
    }
}
