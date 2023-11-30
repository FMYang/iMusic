//
//  SongListCell.swift
//  iMusic
//
//  Created by yfm on 2023/11/30.
//

import UIKit

class SongListCell: UITableViewCell {
    
    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .red.withAlphaComponent(0.8)
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.text = ""
        return label
    }()
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black.withAlphaComponent(0.8)
        label.text = ""
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(filename: String, index: Int) {
        numberLabel.text = "NO.\(index+1)"
        let arr = filename.components(separatedBy: " - ")
        if arr.count > 1 {
            nameLabel.text = arr[1]
            authorLabel.text = arr[0]
        } else {
            nameLabel.text = filename
        }
    }
    
    func makeUI() {
        contentView.addSubview(numberLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(authorLabel)
        
        numberLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(numberLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.right.equalTo(nameLabel)
            make.bottom.equalToSuperview().offset(-5)
        }
    }

}
