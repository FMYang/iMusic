//
//  SourceView.swift
//  zhihu
//
//  Created by yfm on 2023/11/10.
//

import UIKit

class SourceView: UIView {
    
    enum Source: String, CaseIterable {
        case channel1   = "酷狗飙升榜"
        case channel2   = "top500"
        case channel3   = "蜂鸟流行音乐榜"
        case channel4   = "抖音热歌榜"
        case channel5   = "快手热歌榜"
        case channel6   = "DJ热歌榜"
        case channel7   = "内地榜"
        case channel8   = "香港地区榜"
        case channel9   = "台湾地区榜"
        case channel10  = "欧美榜"
        case channel11  = "日本榜"
        
        case channel12  = "ACG新歌榜"
        case channel13  = "电音热歌榜"
        case channel14  = "综艺新歌榜"
        case channel15  = "说唱先锋榜"
        case channel16  = "影视金曲榜"
        case channel17  = "粤语金曲榜"
        case channel18  = "酷狗音乐人原创榜"
        case channel19  = "酷狗雷达榜"
        case channel20  = "80后热歌榜"
        case channel21  = "90后热歌榜"
        case channel22  = "00后热歌榜"
        
        case channel23  = "美国BillBoard榜"
        case channel24  = "英国单曲榜"
        case channel25  = "日本公信榜"
        case channel26  = "韩国Melon音乐榜"
        case channel27  = "joox本地热歌榜"
        case channel28  = "KKBOX风云榜"
        case channel29  = "日本SPACE SHOWER榜"
        case channel30  = "Beatport电子舞曲榜"
        case channel31  = "小语种热歌榜"
    }
    
    class Section {
        var title: String = ""
        var rows: [Row] = []
    }
    
    class Row {
        var title: String = ""
        var selected: Bool = false
        var source: Source = .channel1
    }
    
    var datasource: [Section] = []
    
    var dismiss: ((Source) -> ())?
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.8)
        return view
    }()
    
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.register(SourceHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        return view
    }()

    init(frame: CGRect, type: Source = .channel1) {
        super.init(frame: frame)
        backgroundColor = .black.withAlphaComponent(0.5)
        
        for i in 0..<3 {
            let section = Section()
            if i == 0 {
                section.title = "热门榜单"
                let sources: [Source] = [.channel1, .channel2, .channel3, .channel4, .channel5, .channel6, .channel7,
                    .channel8, .channel9, .channel10, .channel11]
                section.rows = row(sources: sources, type: type)
            } else if i == 1 {
                section.title = "特色音乐榜"
                let sources: [Source] = [.channel12, .channel13, .channel14, .channel15, .channel16, .channel17,
                    .channel18, .channel19, .channel20, .channel21, .channel22]
                section.rows = row(sources: sources, type: type)
            } else {
                section.title = "全球榜"
                let sources: [Source] = [.channel23, .channel24, .channel25, .channel26, .channel27, .channel28,
                    .channel29, .channel30, .channel31]
                section.rows = row(sources: sources, type: type)
            }
            datasource.append(section)
        }
        
        makeUI()
        
        var indexPath = IndexPath(row: 0, section: 0)
        for i in 0..<datasource.count {
            let section = datasource[i]
            for j in 0..<section.rows.count {
                let row = section.rows[j]
                if row.source == type {
                    indexPath = IndexPath(row: j, section: i)
                    break
                }
            }
        }
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    func row(sources: [Source], type: Source = .channel1) -> [Row] {
        var rows: [Row] = []
        for source in sources {
            let model = Row()
            model.title = source.rawValue
            model.source = source
            model.selected = source == type
            rows.append(model)
        }
        return rows
    }
    
    func makeUI() {
        addSubview(contentView)
        contentView.addSubview(topView)
        contentView.addSubview(tableView)
        
        contentView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(200)
        }
        
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(kSafeAreaInsets.top)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        contentView.zy_x = -200
        UIView.animate(withDuration: 0.25) {
            self.contentView.zy_x = 0
        } completion: { finish in
            super.willMove(toSuperview: newSuperview)
        }
    }
    
    override func removeFromSuperview() {
        contentView.zy_x = 0
        UIView.animate(withDuration: 0.25) {
            self.contentView.zy_x = -200
        } completion: { finish in
            super.removeFromSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeFromSuperview()
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view?.isDescendant(of: contentView) == true {
            return false
        }
        return true
    }
}

extension SourceView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = datasource[indexPath.section]
        let row = section.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = row.title
        cell.textLabel?.textColor = row.selected ? .red : .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = datasource[indexPath.section]
        section.rows.forEach { $0.selected = false }
        let row = section.rows[indexPath.row]
        row.selected = true
        tableView.reloadData()
        
        self.dismiss?(row.source)
        removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = datasource[section]
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! SourceHeaderView
        headerView.titleLabel.text = section.title
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}
