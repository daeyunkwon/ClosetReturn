//
//  ProfileEditViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/31/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class ProfileEditViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel: ProfileEditViewModel
    
    //MARK: - Init
    
    init(viewModel: ProfileEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.layer.borderColor = UIColor.systemGray5.cgColor
        iv.layer.borderWidth = 6
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let backViewForIcon: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: "camera.fill")
        iv.tintColor = .black
        iv.backgroundColor = .clear
        iv.isUserInteractionEnabled = false
        return iv
    }()
    
    private let nicknameInputView = InputTextFieldView(viewType: .notPassword, title: "닉네임", placeholder: "다른 유저들에게 보여질 닉네임을 입력해 주세요", showAsterisk: false)
    
    private let phoneNumberInputView = {
        let view = InputTextFieldView(viewType: .notPassword, title: "휴대전화", placeholder: "(-)없이 숫자만 입력해 주세요")
        view.inputTextField.keyboardType = .numberPad
        return view
    }()
    
    private let birthdayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    
    private lazy var birthdayInputView = {
        let view = InputTextFieldView(viewType: .notPassword, title: "생년월일", placeholder: "생년월일")
        view.inputTextField.inputView = birthdayPicker
        return view
    }()
    
    private let doneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("완료", for: .normal)
        btn.titleLabel?.font = Constant.Font.buttonLargeTitleFont
        btn.tintColor = Constant.Color.Button.cancelColor
        return btn
    }()
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("취소", for: .normal)
        btn.titleLabel?.font = Constant.Font.buttonLargeTitleFont
        btn.tintColor = Constant.Color.Button.cancelColor
        return btn
    }()
    
    
    
    
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        backViewForIcon.layer.cornerRadius = backViewForIcon.frame.size.height / 2
    }
    
    //MARK: - Configurations
    
    override func setupNavi() {
        navigationItem.title = "프로필 수정"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
    }
    
    override func configureHierarchy() {
        view.addSubviews(
            profileImageView,
            backViewForIcon,
            nicknameInputView,
            phoneNumberInputView,
            birthdayInputView
        )
        backViewForIcon.addSubview(iconImageView)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.centerX.equalToSuperview()
            make.size.equalTo(110)
        }
        
        backViewForIcon.snp.makeConstraints { make in
            make.trailing.equalTo(profileImageView.snp.trailing).offset(-10)
            make.bottom.equalTo(profileImageView.snp.bottom)
            make.size.equalTo(25)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
        
        nicknameInputView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(35)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        phoneNumberInputView.snp.makeConstraints { make in
            make.top.equalTo(nicknameInputView.snp.bottom).offset(35)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        birthdayInputView.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberInputView.snp.bottom).offset(35)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}
