//
//  PhotoButton.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/23/24.
//

import UIKit

import SnapKit

final class PhotoButton: UIButton {
    
    //MARK: - UI Components
    
    private let customView = PhotoButtonView()
    
    override var isHighlighted: Bool {
        didSet {
            customView.alpha = isHighlighted ? 0.6 : 1.0
        }
    }
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func configure() {
        addSubview(customView)
        customView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.setTitle("", for: .normal)
        
        self.setTitleColor(.white, for: .highlighted)
        self.backgroundColor = .clear
    }
    
    //MARK: - Methods
    
    func updateLabel(withCount count: Int) {
        self.customView.titleLabel.text = "\(count)/5"
    }
}


