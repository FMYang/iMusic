//
//  RootVC.swift
//  iMusic
//
//  Created by yfm on 2023/11/17.
//

import UIKit
import SnapKit
import MobileVLCKit
import CoreMedia

class RootVC: UIViewController {
    
    let interactor = Interactor()
    
    var mediaList = VLCMediaList(array: [])!
    
    var source: SourceView.Source = .channel1 {
        didSet {
            sourceButton.setTitle(source.rawValue, for: .normal)
            loadData()
            localSource = source
        }
    }
    
    var datasource: [Song] = [] {
        didSet {
            var medias: [VLCMedia] = []
            for song in datasource {
                if let path = Bundle.main.path(forResource: song.song_name, ofType: "mp3") {
                    if FileManager.default.fileExists(atPath: path) {
                        let media = VLCMedia(path: path)
                        medias.append(media)
                    }
                }
            }
            mediaList = VLCMediaList(array: medias)
            AudioPlayer.shared.songs = datasource
            AudioPlayer.shared.mediaList = mediaList
            tableView.reloadData()
        }
    }
    
    lazy var songView: PlayerView = {
        let view = PlayerView()
        view.isHidden = true
        
        view.playOrPauseClosure = { [weak self] in
            guard let self = self else { return }
            AudioPlayer.shared.playOrPause()
        }
        
        view.nextClosure = { [weak self] in
            guard let self = self else { return }
            AudioPlayer.shared.playNext()
        }
        
        view.iconTapClosure = { [weak self] in
            guard let self = self else { return }
            let vc = LRCVC()
            vc.transitioningDelegate = self
            vc.interactor = self.interactor
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
        
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.register(SongCell.self, forCellReuseIdentifier: "cell")
        return view
    }()
    
    lazy var sourceButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.setTitle("", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.addTarget(self, action: #selector(sourceAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .medium)
        activityView.tintColor = .gray
        return activityView
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "iMusic"
        configNavation()
        makeUI()
        addRefresh()
        source = localSource
    }
    
    func configNavation() {
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = .white
//        // hide bottom line
//        appearance.shadowImage = UIImage.imageWithColor(color: .white)
//        appearance.backgroundImage = UIImage.imageWithColor(color: .white)
//        navigationController?.navigationBar.standardAppearance = appearance
//        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.addSubview(sourceButton)
                
        sourceButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(120)
            make.top.bottom.equalToSuperview()
        }
    }
    
    func addRefresh() {
        self.tableView.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
            self?.loadData()
        })
    }
    
    func makeUI() {
        view.addSubview(tableView)
        view.addSubview(songView)
        view.addSubview(activityView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        songView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(54)
            make.bottom.equalToSuperview().offset(-kSafeAreaInsets.bottom)
        }
        
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func loadData() {
        datasource = []
        activityView.startAnimating()
        APIService.request1(target: ListAPI.list(source), type: [Song].self) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let songs):
                let filterData = songs.filter { $0.is_free_part == 0 && !$0.song_name.isEmpty }
                self.datasource = self.filterFile(data: filterData)
            case .failure(let err):
                print(err)
//                self.view.showToast("\(err.localizedDescription)")
            }
            self.tableView.headRefreshControl?.endRefreshing()
            self.activityView.stopAnimating()
        }
    }
    
    func filterFile(data: [Song]) -> [Song] {
        var list: [Song] = []
        for song in data {
            if let path = Bundle.main.path(forResource: song.song_name, ofType: "mp3") {
                if FileManager.default.fileExists(atPath: path) {
                    list.append(song)
                }
            }
        }
        return list
    }
    
    @objc func sourceAction() {
        let sourceView = SourceView(frame: UIScreen.main.bounds, type: source)
        sourceView.dismiss = { [weak self] source in
            if self?.source != source {
                self?.source = source
            }
        }
        sourceView.tag = 1001
        navigationController?.view.addSubview(sourceView)
    }
}

extension RootVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song = datasource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SongCell
        cell.config(song: song)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        play(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}

extension RootVC {
    func play(index: Int) {
        songView.isHidden = false
        songView.config(song: datasource[index])
        AudioPlayer.shared.playItem(index: index)
    }
}

extension RootVC: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

extension RootVC {
    var localSource: SourceView.Source {
        get {
            guard let channel = UserDefaults.standard.string(forKey: "localPlayMode") else { return .channel1 }
            return SourceView.Source(rawValue: channel) ?? .channel1
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "localPlayMode")
            UserDefaults.standard.synchronize()
        }
    }
}

extension UIImage {
    class func imageWithColor(color:UIColor) -> UIImage?{
        let rect = CGRect.init(x:0, y:0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
