//
//  LRCVC.swift
//  iMusic
//
//  Created by yfm on 2023/11/20.
//

import UIKit
import CoreMedia
import MediaPlayer

class LRCVC: UIViewController {
    
    var statusObservers: [NSKeyValueObservation?] = []
    var collectionClosure: (() -> Void)?

    var interactor:Interactor? = nil
    var isDraging: Bool = false
    var datasource: [LRCLine] = [] {
        didSet {
            tableView.reloadData()
            noDataLabel.isHidden = datasource.count > 0
        }
    }
    
    var curPlayIndex: Int = 0 {
        didSet {
            tableView.reloadData()
            if !isDraging {
                if datasource.count > 0 && curPlayIndex < datasource.count {
                    tableView.scrollToRow(at: IndexPath(row: curPlayIndex, section: 0), at: .middle, animated: true)
                }
            }
        }
    }

    lazy var collectionBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "icon_collection_normal"), for: .normal)
        btn.setImage(UIImage(named: "icon_collection_select"), for: .selected)
        btn.addTarget(self, action: #selector(collectAction), for: .touchUpInside)
        btn.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    lazy var backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "device_down_arrow"), for: .normal)
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var backgroundView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        let backgroundImage = UIImage(named: "bg_playview_iPhoneX.jpg")
        view.image = backgroundImage
        
        let maskView = UIView()
        maskView.backgroundColor = .black.withAlphaComponent(0.3)
        view.addSubview(maskView)
        maskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .clear
        view.separatorStyle = .none
        view.delegate = self
        view.dataSource = self
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return view
    }()
    
    lazy var playOrPauseButton: UIButton = {
        let btn = UIButton()
        let isPlaying = AudioPlayer.shared.playerList.mediaPlayer.isPlaying
        btn.setImage(UIImage(named: isPlaying ? "playview_pause" : "playview_play"), for: .normal)
        btn.backgroundColor = .white.withAlphaComponent(0.2)
        btn.layer.cornerRadius = 35
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(playOrPauseAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var lastButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_player_btn_last_newMode"), for: .normal)
        btn.addTarget(self, action: #selector(previousAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_player_btn_next_newMode"), for: .normal)
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var minTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.text = "00:00"
        label.textColor = .white.withAlphaComponent(0.5)
        label.textAlignment = .right
        return label
    }()
    
    lazy var maxTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.text = "00:00"
        label.textAlignment = .left
        label.textColor = .white.withAlphaComponent(0.5)
        return label
    }()
    
    lazy var slider: CustomSlider = {
        let slider = CustomSlider()
        slider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.3)
        slider.addTarget(self, action: #selector(sliderAction(slider:)), for: .valueChanged)
        return slider
    }()
    
    lazy var clockButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "kg_ic_player_menu_music_clock_normal"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.titleLabel?.textColor = .white
        btn.addTarget(self, action: #selector(clockTimeAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var playModeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: AudioPlayer.shared.playMode.imageName), for: .normal)
        btn.addTarget(self, action: #selector(playModeSwitchAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无歌词"
        label.textColor = .white
        label.font = .systemFont(ofSize: 22)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(sender:)))
        view.addGestureRecognizer(pan)
        
        makeUI()
        loadData(song: AudioPlayer.shared.curSong)
        addKVO()
        updateClockButton()
        collectionBtn.isSelected = AudioPlayer.shared.curSong.isCollect
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func loadData(song: Song) {
        datasource = LRCParse.parse(content: song.lrc)
        
        let seconds = Float(song.timelength) / 1000.0
        maxTimeLabel.text = String.format(time: seconds)
    }
    
    func addKVO() {
        let statusObserver = AudioPlayer.shared.observe(\.playState, options: [.new]) { [weak self] model, change in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let playing = model.playerList.mediaPlayer.isPlaying
                self.playOrPauseButton.setImage(UIImage(named: playing ? "playview_pause" : "playview_play"), for: .normal)
            }
        }
        statusObservers.append(statusObserver)

        let timeObserver = AudioPlayer.shared.observe(\.time, options: [.new]) { [weak self] model, change in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.curPlayIndex = AudioPlayer.shared.lrcLineIndex
                self.slider.value = AudioPlayer.shared.playerList.mediaPlayer.position
                self.minTimeLabel.text = String.format(time: model.time)
            }
        }
        statusObservers.append(timeObserver)
        
        let indexObserver = AudioPlayer.shared.observe(\.curIndex, options: [.new]) { [weak self] model, change in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let index = AudioPlayer.shared.curIndex
                let song = AudioPlayer.shared.songs[index]
                self.loadData(song: song)
            }
        }
        statusObservers.append(indexObserver)
        
        let countDownObserver = AudioPlayer.shared.observe(\.countdownSeconds, options: [.new]) { [weak self] model, change in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateClockButton()
            }
        }
        statusObservers.append(countDownObserver)
    }
    
    func updateClockButton() {
        if AudioPlayer.shared.clockTime != .close {
            let countDownSeconds = AudioPlayer.shared.countdownSeconds
            let countDownText = String.format(time: Float(countDownSeconds))
            self.clockButton.setTitle(countDownText, for: .normal)
            self.clockButton.setImage(nil, for: .normal)
        } else {
            clockButton.setImage(UIImage(named: "kg_ic_player_menu_music_clock_normal"), for: .normal)
            clockButton.setTitle("", for: .normal)
        }
    }
    
    // MARK: - action
    @objc func collectAction() {
        collectionBtn.isSelected = !collectionBtn.isSelected
        var song = AudioPlayer.shared.curSong
        song.isCollect = collectionBtn.isSelected
        if (song.isCollect) {
            CollectionDataManager.shared.add(song: song)
        } else {
            CollectionDataManager.shared.delete(song: song)
        }
        collectionClosure?()
    }
    
    @objc func backAction() {
        dismiss(animated: true)
    }
    
    @objc func playOrPauseAction() {
        AudioPlayer.shared.playOrPause()
    }
    
    @objc func previousAction() {
        curPlayIndex = 0
        AudioPlayer.shared.playPrevious()
    }
    
    @objc func nextAction() {
        curPlayIndex = 0
        AudioPlayer.shared.playNext()
    }
    
    @objc func sliderAction(slider: UISlider) {
        var position = slider.value
        if position > 0.99 { position = 0.99 }
        AudioPlayer.shared.seek(position: position)
    }
    
    @objc func playModeSwitchAction() {
        var mode = AudioPlayer.shared.playMode.rawValue
        if mode < 2 {
            mode += 1
        } else {
            mode = 0
        }
        AudioPlayer.shared.playMode = AudioPlayer.PlayMode(rawValue: mode) ?? .list
        AudioPlayer.shared.localPlayMode = AudioPlayer.PlayMode(rawValue: mode) ?? .list
        playModeButton.setImage(UIImage(named: AudioPlayer.shared.playMode.imageName), for: .normal)
    }
    
    @objc func clockTimeAction() {
        var mode = AudioPlayer.shared.clockTime.rawValue
        if mode < 4 {
            mode += 1
        } else {
            mode = 0
        }
        AudioPlayer.shared.clockTime = AudioPlayer.ClockTime(rawValue: mode) ?? .close
        updateClockButton()
    }
        
    // MARK: - UI
    func makeUI() {
        view.addSubview(backgroundView)
        view.addSubview(tableView)
        view.addSubview(backButton)
        view.addSubview(lastButton)
        view.addSubview(nextButton)
        view.addSubview(playOrPauseButton)
        view.addSubview(minTimeLabel)
        view.addSubview(slider)
        view.addSubview(maxTimeLabel)
        view.addSubview(clockButton)
        view.addSubview(playModeButton)
        view.addSubview(noDataLabel)
        view.addSubview(collectionBtn)
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(kSafeAreaInsets.top)
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(44)
        }
        
        collectionBtn.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.width.height.equalTo(44)
            make.right.equalToSuperview().offset(-20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200)
            make.bottom.equalToSuperview().offset(-200)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
        
        playOrPauseButton.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kSafeAreaInsets.bottom-30)
        }
        
        lastButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerY.equalTo(playOrPauseButton)
            make.right.equalTo(playOrPauseButton.snp.left).offset(-30)
        }
        
        nextButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerY.equalTo(playOrPauseButton)
            make.left.equalTo(playOrPauseButton.snp.right).offset(30)
        }
        
        minTimeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(playOrPauseButton.snp.top).offset(-20)
            make.left.equalToSuperview().offset(30)
            make.width.equalTo(60)
        }
        
        maxTimeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(minTimeLabel)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(60)
        }
        
        slider.snp.makeConstraints { make in
            make.centerY.equalTo(minTimeLabel)
            make.left.equalTo(minTimeLabel.snp.right).offset(10)
            make.right.equalTo(maxTimeLabel.snp.left).offset(-10)
            make.height.equalTo(40)
        }
        
        clockButton.snp.makeConstraints { make in
            make.centerY.equalTo(nextButton)
            make.width.height.equalTo(50)
            make.left.equalTo(nextButton.snp.right).offset(20)
        }
        
        playModeButton.snp.makeConstraints { make in
            make.centerY.equalTo(nextButton)
            make.width.height.equalTo(50)
            make.right.equalTo(lastButton.snp.left).offset(-20)
        }
        
        noDataLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(kScreenWidth-40)
        }
    }
}

extension LRCVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lrcLine = datasource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.textLabel?.text = lrcLine.text
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = .white
        if indexPath.row == curPlayIndex {
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = .systemFont(ofSize: 20)
        } else {
            cell.textLabel?.textColor = .white.withAlphaComponent(0.7)
            cell.textLabel?.font = .systemFont(ofSize: 16)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let line = datasource[indexPath.row]
        let totalTime = Float(AudioPlayer.shared.curSong.timelength) / 1000.0
        let time = Float(CMTimeGetSeconds(line.time))
        var position = time / totalTime
        if position > 0.99 { position = 0.99 }
        AudioPlayer.shared.seek(position: position)
    }
}

extension LRCVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDraging = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(action), object: nil)
        perform(#selector(action), with: nil, afterDelay: 2)
    }
    
    @objc func action() {
        isDraging = false
    }
}

// MARK: - 交互式pop
extension LRCVC {
    @objc func handleGesture(sender: UIPanGestureRecognizer) {

        let percentThreshold: CGFloat = 0.3

        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch sender.state {
        case .began:
            interactor.hasStarted = true
            dismiss(animated: true, completion: nil)
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true)
    }
}

class CustomSlider: UISlider {
    private let thumbImageWidth: CGFloat = 0.0
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var customBounds = super.trackRect(forBounds: bounds)
        customBounds.size.height = 2 // 自定义轨道高度
        return customBounds
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var _rect = rect
        _rect.origin.x -= 5
        _rect.size.width += 10
        return super.thumbRect(forBounds: bounds, trackRect: _rect, value: value)
    }
}
