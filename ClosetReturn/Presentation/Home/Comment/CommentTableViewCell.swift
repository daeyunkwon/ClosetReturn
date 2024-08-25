//
//  CommentTableViewCell.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/25/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class CommentTableViewCell: BaseTableViewCell {

    //MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    //MARK: - UI Components
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 22
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.secondaryBoldFont
        label.textAlignment = .left
        return label
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.bodyFont
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = Constant.Color.Text.secondaryColor
        label.textAlignment = .left
        return label
    }()
    
    let editButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("수정", for: .normal)
        btn.setTitleColor(Constant.Color.Text.secondaryColor, for: .normal)
        return btn
    }()
    
    let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("삭제", for: .normal)
        btn.setTitleColor(Constant.Color.Text.secondaryColor, for: .normal)
        return btn
    }()
        
    //MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubviews(
            profileImageView,
            nameLabel,
            commentLabel,
            editButton,
            deleteButton,
            dateLabel
        )
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(10)
            make.size.equalTo(44)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(10)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.equalTo(profileImageView.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(10)
        }
        
        editButton.snp.makeConstraints { make in
            make.top.equalTo(commentLabel.snp.bottom).offset(5)
            make.leading.equalTo(commentLabel.snp.leading)
            make.height.equalTo(10)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(commentLabel.snp.bottom).offset(5)
            make.leading.equalTo(editButton.snp.trailing).offset(7)
            make.bottom.equalTo(editButton)
            make.height.equalTo(10)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(commentLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().inset(2)
            make.trailing.equalToSuperview().inset(10)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
    
    func cellConfig(data: Comment) {    
        nameLabel.text = data.creator.nick
        commentLabel.text = data.content
        dateLabel.text = data.createDateString
        
        if data.creator.user_id == UserDefaultsManager.shared.userID {
            [editButton, deleteButton].forEach { $0.isHidden = false }
        } else {
            [editButton, deleteButton].forEach { $0.isHidden = true }
        }
    }
    
    func configureProfileImage(data: Data) {
        self.profileImageView.image = UIImage(data: data)
    }
}
