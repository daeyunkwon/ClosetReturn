//
//  ProductDetailCollectionViewCell.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/21/24.
//

import UIKit

import SnapKit

final class ProductDetailCollectionViewCell: BaseCollectionViewCell {
    
    //MARK: - UI Components
    
    let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "star.fill")
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubview(productImageView)
    }
    
    override func configureLayout() {
        productImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
