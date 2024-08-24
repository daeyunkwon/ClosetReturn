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
    
    
    
    //MARK: - UI Components
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 25
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.secondaryBoldFont
        label.textAlignment = .left
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.bodyFont
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    
    
    //MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubviews(
            profileImageView,
            nameLabel,
            commentLabel
        )
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(10)
            make.size.equalTo(50)
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
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
    
    func cellConfig() {
        
    }
}
