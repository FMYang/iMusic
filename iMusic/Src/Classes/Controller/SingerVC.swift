//
//  SingerVC.swift
//  iMusic
//
//  Created by yfm on 2023/11/30.
//

import UIKit

class SingerVC: UIViewController {
    
    var datasource: [Singer] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.register(SingerCell.self, forCellReuseIdentifier: "cell")
        return view
    }()
    
    lazy var searchButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "cctop_search"), for: .normal)
        btn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "歌手列表"
        makeUI()
        configNavation()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchButton.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchButton.isHidden = true
    }
    
    func configNavation() {
        navigationController?.navigationBar.addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(60)
            make.top.bottom.equalToSuperview()
        }
    }
    
    func loadData() {
        guard let url = Bundle.main.url(forResource: "singerList", withExtension: "json"),
              let jsonData = try? Data(contentsOf: url) else {
            datasource = []
            return
        }
        
        guard let list = try? JSONDecoder().decode([Singer].self, from: jsonData) else {
            datasource = []
            return
        }
        
        datasource = list
    }
    
    @objc func searchAction() {
        let searchView = SingerSearchView(data: datasource)
        searchView.selectClosure = { [weak self] index in
            guard let self = self else { return }
            self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
        }
        navigationController?.view.addSubview(searchView)
    }
    
    // MARK: -
    func makeUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SingerVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let singer = datasource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SingerCell
        cell.config(singer: singer)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singer = datasource[indexPath.row]
        let vc = SongListVC(singer: singer)
        navigationController?.pushViewController(vc, animated: true)
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
