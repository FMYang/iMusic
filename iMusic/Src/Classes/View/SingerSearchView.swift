//
//  SearchView.swift
//  iMusic
//
//  Created by yfm on 2023/11/28.
//

import UIKit
import NotificationCenter

class SingerSearchView: UIView {
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var searchView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(valueRGB: 0xe1e2e3).withAlphaComponent(0.8)
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var searchIconView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "fx_list_icon_search")
        return view
    }()
    
    lazy var searchTextfiled: UITextField = {
        let view = UITextField()
        view.returnKeyType = .search
        view.clearButtonMode = .whileEditing
        view.delegate = self
        view.placeholder = "输入歌名或作者名搜索"
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var resultTableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.register(SingerCell.self, forCellReuseIdentifier: "cell")
        return view
    }()
    
    lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = "无相关内容"
        label.textColor = .black
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    lazy var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .medium)
        activityView.tintColor = .gray
        return activityView
    }()

    var listData: [Singer] = []
    var datasource: [Singer] = [] {
        didSet {
            resultTableView.reloadData()
            noDataLabel.isHidden = datasource.count > 0
        }
    }
    
    var selectClosure: ((Int) -> Void)?

    init(data: [Singer]) {
        super.init(frame: .zero)
        backgroundColor = .white
        frame = UIScreen.main.bounds
        makeUI()
        listData = data
        searchTextfiled.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(didChanged(noti: )), name: UITextField.textDidChangeNotification, object: searchTextfiled)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - action
    @objc func cancelAction() {
        searchTextfiled.resignFirstResponder()
        removeFromSuperview()
    }
        
    override func willMove(toSuperview newSuperview: UIView?) {
        self.alpha = 0.0
        contentView.zy_y = kScreenHeight
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1.0
            self.contentView.zy_y = 0
        } completion: { finish in
            super.willMove(toSuperview: newSuperview)
        }
    }
    
    override func removeFromSuperview() {
        self.alpha = 1.0
        self.contentView.zy_y = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0.0
            self.contentView.zy_y = kScreenHeight
        } completion: { finish in
            super.removeFromSuperview()
        }
    }
    
    func search(text: String) {
        if !text.isEmpty {
            activityView.startAnimating()
            DispatchQueue.global().async { [weak self] in
                let result = self?.listData.filter {
                    $0.singername.range(of: text, options: .caseInsensitive) != nil ||
                    "\($0.singerid)".range(of: text) != nil
                }
                DispatchQueue.main.async { [weak self] in
                    self?.activityView.stopAnimating()
                    self?.datasource = result ?? []
                }
            }
        } else {
            datasource = []
        }
    }
    
    // MARK: - UI
    func makeUI() {
        addSubview(contentView)
        contentView.addSubview(searchView)
        searchView.addSubview(searchIconView)
        searchView.addSubview(searchTextfiled)
        contentView.addSubview(cancelButton)
        contentView.addSubview(resultTableView)
        contentView.addSubview(noDataLabel)
        contentView.addSubview(activityView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        searchView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(cancelButton.snp.left).offset(0)
            make.top.equalToSuperview().offset(kSafeAreaInsets.top+10)
            make.height.equalTo(36)
        }
        
        searchIconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(14)
            make.centerY.equalToSuperview()
        }
        
        searchTextfiled.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(searchIconView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(36)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(searchView)
        }
        
        resultTableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(searchView.snp.bottom).offset(10)
        }
        
        noDataLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(searchView.snp.bottom).offset(20)
        }
        
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

}

extension SingerSearchView: UITableViewDelegate, UITableViewDataSource {
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
        let index = index(singer: singer)
        selectClosure?(index)
        cancelAction()
    }
    
    func index(singer: Singer) -> Int {
        return listData.firstIndex(where: { $0.singerid == singer.singerid }) ?? 0
    }
}

extension SingerSearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            search(text: text)
            textField.resignFirstResponder()
        }
        return true
    }
}

extension SingerSearchView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchTextfiled.resignFirstResponder()
    }
    
    @objc func didChanged(noti: Notification) {
//        if let textfield = noti.object as? UITextField {
//            if let text = textfield.text {
//                search(text: text)
//            }
//        }
    }
}


