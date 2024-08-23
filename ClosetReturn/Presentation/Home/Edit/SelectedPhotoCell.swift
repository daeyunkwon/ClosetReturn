//
//  SelectedPhotoCell.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/23/24.
//

import UIKit

import RxSwift
import SnapKit

final class SelectedPhotoCell: BaseCollectionViewCell {
    
    //MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    //MARK: - UI Components
    
    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        return iv
    }()
    
    let xmarkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = Constant.Color.Button.cancelColor
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
            xmarkButton,
            photoImageView
        )
    }
    
    override func configureLayout() {
        xmarkButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(5)
            make.size.equalTo(20)
        }
        
        photoImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(5)
            make.trailing.equalTo(xmarkButton.snp.leading).offset(-1)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
    
    func cellConfig(withImageData data: Data) {
        self.photoImageView.image = UIImage(data: data)
    }
}
