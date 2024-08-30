//
//  ProductBuyTableViewCell.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/28/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class ProductBuyTableViewCell: BaseTableViewCell {
    
    //MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    //MARK: - UI Components
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "구매확정"
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .gray
        return label
    }()
    
    private let buyDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .gray
        return label
    }()
    
    let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.cornerRadius = 10
        iv.layer.shadowColor = UIColor.lightGray.cgColor
        iv.layer.shadowOpacity = 1
        iv.layer.shadowOffset = .init(width: 0, height: 1)
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
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
        label.font = Constant.Font.secondaryFont
        label.textColor = Constant.Color.Text.secondaryColor
        label.textAlignment = .left
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = Constant.Color.Text.bodyColor
        label.textAlignment = .left
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        return view
    }()
    
    //MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        contentView.addSubviews(
            infoLabel,
            productImageView,
            titleLabel,
            brandLabel,
            categoryLabel,
            priceLabel,
            buyDateLabel,
            separatorView
        )
    }
    
    override func configureLayout() {
        infoLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(15)
        }
        
        productImageView.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().inset(15)
            make.size.equalTo(100)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(productImageView.snp.top)
            make.leading.equalTo(productImageView.snp.trailing).offset(3)
            make.trailing.equalToSuperview().inset(10)
        }
        
        brandLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2.5)
            make.leading.equalTo(productImageView.snp.trailing).offset(3)
            make.trailing.equalToSuperview().inset(10)
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(brandLabel.snp.bottom).offset(2)
            make.leading.equalTo(productImageView.snp.trailing).offset(3)
            make.trailing.equalToSuperview().inset(10)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(2)
            make.leading.equalTo(productImageView.snp.trailing).offset(3)
            make.trailing.equalToSuperview().inset(10)
        }
        
        buyDateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(productImageView).offset(-5)
            make.leading.equalTo(productImageView.snp.trailing).offset(3)
            make.trailing.equalToSuperview().inset(10)
        }
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(5)
            make.height.equalTo(0.2)
            make.horizontalEdges.equalToSuperview().inset(15)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
    
    //MARK: - Methods
    
    func cellConfig(data: ProductPost) {
        self.buyDateLabel.text = "구매일시 \(data.createPaidAtDateString)"
        self.titleLabel.text = data.title
        self.brandLabel.text = data.content3
        self.categoryLabel.text = data.content2
        self.priceLabel.text = (data.price?.formatted() ?? "") + "원"
    }
}
