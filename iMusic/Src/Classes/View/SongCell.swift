//
//  SongCell.swift
//  iMusic
//
//  Created by yfm on 2023/11/17.
//

import UIKit
import Kingfisher

class SongCell: UITableViewCell {
    
    lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
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
    
    func config(song: Song) {
        nameLabel.text = song.song_name
        authorLabel.text = song.author_name
//        let roundProcessor = RoundCornerImageProcessor(cornerRadius: 8, targetSize: CGSize(width: 54, height: 54))
//        iconImageView.kf.setImage(with: URL(string: song.img)!, placeholder: UIColor.createImage(color: .lightGray), options: [.processor(roundProcessor)])
        iconImageView.kf.setImage(with: URL(string: song.img)!, placeholder: UIImage(named: "album_placeholder"))
        
        if song.selected {
            nameLabel.textColor = UIColor(valueRGB: 0x1aaef4)
            authorLabel.textColor = UIColor(valueRGB: 0x1aaef4)
            nameLabel.font = .boldSystemFont(ofSize: 16)
        } else {
            nameLabel.textColor = .black
            authorLabel.textColor = .black
            nameLabel.font = .systemFont(ofSize: 16)
        }
        
        contentView.backgroundColor = song.selected ? UIColor(valueRGB: 0xe1e2e3).withAlphaComponent(0.2) : .clear
    }
    
    func makeUI() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(authorLabel)
        
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
        
        authorLabel.snp.makeConstraints { make in
            make.left.right.equalTo(nameLabel)
            make.bottom.equalTo(iconImageView.snp.bottom).offset(-5)
        }
    }
}
