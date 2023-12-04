//
//  SingerCell.swift
//  iMusic
//
//  Created by yfm on 2023/11/30.
//

import UIKit
import Kingfisher

class SingerCell: UITableViewCell {

    lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 27
        view.layer.masksToBounds = true
        view.image = UIImage(named: "singer_placeholder.jpg")
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.text = ""
        return label
    }()
    
    lazy var descriptLabel: UILabel = {
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
    
    func config(singer: Singer) {
        nameLabel.text = "\(singer.singername) - \(singer.singerid)"
        descriptLabel.text = "歌曲数量\(singer.songcount)首"
        if singer.imgurl.isEmpty == false {
            if let url = URL(string: singer.imgurl.replacingOccurrences(of: "{size}", with: "100")) {
                iconImageView.kf.setImage(with: url, placeholder: UIImage(named: "singer_placeholder.jpg"))
            }
        }
    }
    
    func makeUI() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(descriptLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(54)
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(iconImageView).offset(5)
        }
        
        descriptLabel.snp.makeConstraints { make in
            make.left.right.equalTo(nameLabel)
            make.bottom.equalTo(iconImageView.snp.bottom).offset(-5)
        }
    }

}
