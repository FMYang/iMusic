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
    
    var playOrPauseClosure: (()->Void)?
    var nextClosure: (()->Void)?
    var iconTapClosure: (()->Void)?
    
    lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 27
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        view.image = UIImage(named: "svg_kg_playpage__album_default_01")
        
        let ges = UITapGestureRecognizer(target: self, action: #selector(iconTapAction))
        view.addGestureRecognizer(ges)
        
        return view
    }()
    
    lazy var nameLabel: ScrollingLabel = {
        let label = ScrollingLabel(frame: CGRectMake(0, 0, kScreenWidth-180, 54))
        label.isUserInteractionEnabled = true

        let ges = UITapGestureRecognizer(target: self, action: #selector(iconTapAction))
        label.addGestureRecognizer(ges)
        
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
        
        statusObservers.append(statusObserver)
        statusObservers.append(indexObserver)
    }
        
    func config(song: Song) {
        iconImageView.kf.setImage(with: URL(string: song.img)!, placeholder: UIImage(named: "svg_kg_playpage__album_default_01"))
        nameLabel.text = song.song_name + " - " + song.author_name
    }
    
    func startAnimation() {
        iconImageView.layer.removeAllAnimations()
        // 创建旋转动画
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: 2*Double.pi)
        rotationAnimation.duration = 10.0
        rotationAnimation.repeatCount = .greatestFiniteMagnitude
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = .forwards
        iconImageView.layer.add(rotationAnimation, forKey: "")
    }
    
    func stopAnimation() {
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
        addSubview(playOrPauseButton)
        addSubview(nextButton)
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(54)
            make.top.left.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(15)
            make.centerY.equalToSuperview()
            make.right.equalTo(playOrPauseButton.snp.left).offset(-10)
            make.height.equalTo(54)
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
    }
}
