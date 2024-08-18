//
//  SignUpCompleteViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/18/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class SignUpCompleteViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    //MARK: - UI Components
    
    private let backView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = Constant.Color.View.viewBackgroundColor
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "sheild-dynamic-color")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "회원가입 완료"
        label.textColor = Constant.Color.Text.titleColor
        label.font = Constant.Font.titleFont
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "환영합니다!🎉\n로그인 후에 서비스 이용을 시작해보세요."
        label.textAlignment = .center
        label.font = Constant.Font.bodyBoldFont
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let goToLoginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("로그인하러 가기", for: .normal)
        btn.titleLabel?.font = Constant.Font.buttonTitleFont
        btn.tintColor = Constant.Color.Button.titleColor
        btn.backgroundColor = Constant.Color.brandColor
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        goToLoginButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = UINavigationController(rootViewController: LoginViewController())
                owner.setRootViewController(vc)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(backView)
        backView.addSubviews(
            iconImageView,
            titleLabel,
            descriptionLabel,
            goToLoginButton
        )
    }
    
    override func configureLayout() {
        backView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(380)
            make.horizontalEdges.equalToSuperview().inset(30)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(20)
            make.size.equalTo(150)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        goToLoginButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(50)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
    }
    
    override func configureUI() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
    }
}
