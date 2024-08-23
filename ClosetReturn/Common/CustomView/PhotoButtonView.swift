//
//  PhotoButtonView.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/23/24.
//

import UIKit

import SnapKit

final class PhotoButtonView: BaseView {

    //MARK: - UI Components
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "camera.fill")
        iv.contentMode = .scaleAspectFit
        iv.tintColor = Constant.Color.brandColor
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "0/5"
        label.textColor = Constant.Color.brandColor
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        addSubview(iconImageView)
        addSubview(titleLabel)
    }
    
    override func configureLayout() {
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    override func configureUI() {
        layer.borderColor = UIColor.systemGray6.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 15
        clipsToBounds = true
        isUserInteractionEnabled = false
    }
}

