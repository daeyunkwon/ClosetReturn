//
//  SelectedPhotoCell.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/23/24.
//

import UIKit

import SnapKit

final class SelectedPhotoCell: BaseCollectionViewCell {
    
    
    //MARK: - Properties
    
    
    
    //MARK: - UI Components
    
    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        return iv
    }()
    
    private let xmarkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = Constant.Color.Button.cancelColor
        return btn
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubviews(
            photoImageView,
            xmarkButton
        )
    }
    
    override func configureLayout() {
        photoImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(5)
            make.trailing.equalToSuperview().offset(-35)
        }
        
        xmarkButton.snp.makeConstraints { make in
            make.leading.equalTo(photoImageView.snp.trailing).offset(3)
            make.top.trailing.equalToSuperview().inset(5)
            make.size.equalTo(30)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
