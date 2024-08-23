//
//  RoundedBackTitleContainerView.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/23/24.
//

import UIKit

import SnapKit

final class RoundedBackTitleContainerView: BaseView {
    
    //MARK: - Properties
    
    private let title: String
    
    //MARK: - Init
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
    }
    
    //MARK: - UI Components
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Font.titleFont
        label.textColor = Constant.Color.Text.titleColor
        return label
    }()
    
    //MARK: - Configurations
    
    override func configureHierarchy() {
        self.addSubviews(titleLabel)
    }
    
    override func configureLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(15)
        }
    }
    
    override func configureUI() {
        super.configureUI()
        self.titleLabel.text = self.title
        self.layer.cornerRadius = 20
    }
}
