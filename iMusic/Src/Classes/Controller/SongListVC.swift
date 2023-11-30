//
//  SongListVC.swift
//  iMusic
//
//  Created by yfm on 2023/11/30.
//

import UIKit

class SongListVC: UIViewController {
    
    var singer: Singer!
    var page = 1
    
    var datasource: [SongInfo] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.register(SongListCell.self, forCellReuseIdentifier: "cell")
        return view
    }()
    
    init(singer: Singer) {
        self.singer = singer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "\(singer.singername)的歌曲"
        makeUI()
        addRefresh()
        tableView.headRefreshControl.beginRefreshing()
    }
        
    func addRefresh() {
        self.tableView.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
            self?.page = 1
            self?.loadData()
        })
        
        self.tableView.bindGlobalStyle(forFootRefreshHandler: { [weak self] in
            self?.loadData()
        })
    }
    
    func loadData() {
        APIService.request1(target: SingerAPI.song(Int32(singer.singerid), page), type: ListSong.self) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let list):
                guard let info = list.data?.info else { return }
                if self.page == 1 {
                    self.datasource = info
                } else {
                    self.datasource += info
                }
                self.page += 1
                if info.count < 500 {
                    self.tableView.footRefreshControl.endRefreshingAndNoLongerRefreshing(withAlertText: "没有更多了")
                }
            case .failure(let err):
                print(err)
            }
            self.tableView.headRefreshControl.endRefreshing()
            self.tableView.footRefreshControl.endRefreshing()
        }
    }
    
    func configNavation() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        // hide bottom line
        appearance.shadowImage = UIImage.imageWithColor(color: .white)
        appearance.backgroundImage = UIImage.imageWithColor(color: .white)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func makeUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SongListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song = datasource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SongListCell
        cell.config(filename: song.filename, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
