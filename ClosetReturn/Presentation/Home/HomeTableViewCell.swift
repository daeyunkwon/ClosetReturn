//
//  HomeTableViewCell.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/19/24.
//

import UIKit

import RxSwift
import RxCocoa

final class HomeTableViewCell: BaseTableViewCell {
    
    //MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    //MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
        disposeBag = DisposeBag()
    }
    
    //MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = .init(width: 0, height: 1)
        view.backgroundColor = Constant.Color.View.viewBackgroundColor
        return view
    }()
    
    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 10
        iv.layer.borderColor = UIColor.systemGray.cgColor
        iv.layer.borderWidth = 0.2
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = Constant.Color.Text.titleColor
        label.textAlignment = .left
        return label
    }()
    
    private let brandLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.bodyFont
        label.textColor = Constant.Color.Text.brandTitleColor
        label.textAlignment = .left
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.bodyFont
        label.textColor = Constant.Color.Text.secondaryColor
        label.textAlignment = .left
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.priceFont
        label.textColor = Constant.Color.Text.bodyColor
        label.textAlignment = .left
        return label
    }()
    
    let likeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "suit.heart")?.applyingSymbolConfiguration(.init(weight: .semibold)), for: .normal)
        btn.tintColor = Constant.Color.Button.likeColor
        return btn
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubview(containerView)
        contentView.addSubview(productImageView)
        containerView.addSubviews(
            titleLabel,
            brandLabel,
            categoryLabel,
            likeButton,
            priceLabel
        )
    }
    
    override func configureLayout() {
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.bottom.trailing.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(35)
        }
        
        productImageView.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(-5)
            make.leading.equalTo(containerView).offset(-15)
            make.width.equalTo(contentView.frame.size.width / 2.9)
            make.bottom.equalToSuperview().inset(30)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.leading.equalTo(productImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
        }
        
        brandLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(brandLabel.snp.bottom).offset(3)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
        }
        
        likeButton.snp.makeConstraints { make in
            make.size.equalTo(30)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(25)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(5)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(likeButton.snp.leading).offset(-10)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
    
    //MARK: - Methods
    
    func cellConfig(data: ProductPost) {
        titleLabel.text = data.title
        brandLabel.text = data.content3
        priceLabel.text = (data.price?.formatted() ?? "") + "원"
        categoryLabel.text = data.content2
        
        if data.files.first != nil {
            NetworkManager.shared.fetchImageData(imagePath: data.files[0]) { [weak self] result in
                switch result {
                case .success(let value):
                    self?.productImageView.image = UIImage(data: value)
                    
                case .failure(let error):
                    print("Error: 이미지 조회 API 실패")
                    print(error)
                }
            }
        }
        
        if UserDefaultsManager.shared.likeProducts[data.post_id] != nil {
            updateAppearanceLikeButton(isLiked: true)
        } else {
            updateAppearanceLikeButton(isLiked: false)
        }
    }
    
    func updateAppearanceLikeButton(isLiked: Bool) {
        if isLiked {
            likeButton.setImage(UIImage(systemName: "suit.heart.fill")?.applyingSymbolConfiguration(.init(weight: .semibold)), for: .normal)
        } else {
            likeButton.setImage(UIImage(systemName: "suit.heart")?.applyingSymbolConfiguration(.init(weight: .semibold)), for: .normal)
        }
    }
    
    func cellConfig(withCommonPost data: CommonPost) {
        titleLabel.text = data.title
        brandLabel.text = data.content3
        priceLabel.text = (data.price?.formatted() ?? "") + "원"
        categoryLabel.text = data.content2
        
        if data.files.first != nil {
            NetworkManager.shared.fetchImageData(imagePath: data.files[0]) { [weak self] result in
                switch result {
                case .success(let value):
                    self?.productImageView.image = UIImage(data: value)
                    
                case .failure(let error):
                    print("Error: 이미지 조회 API 실패")
                    print(error)
                }
            }
        }
    }
}
