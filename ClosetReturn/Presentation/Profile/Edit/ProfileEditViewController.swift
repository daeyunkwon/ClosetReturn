//
//  ProfileEditViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/31/24.
//

import UIKit
import PhotosUI

import RxSwift
import RxCocoa
import SnapKit

final class ProfileEditViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel: ProfileEditViewModel
    
    private let selectedImage = PublishRelay<Data>()
    
    
    //MARK: - Init
    
    init(viewModel: ProfileEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    
    private let profileImageViewTapGesture = UITapGestureRecognizer()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.layer.borderColor = UIColor.systemGray5.cgColor
        iv.layer.borderWidth = 3
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(self.profileImageViewTapGesture)
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
    
    override func bind() {
        let cancelAlertButtonTapped = PublishRelay<Void>()

        let input = ProfileEditViewModel.Input(
            cancelButtonTapped: cancelButton.rx.tap,
            cancelAlertButtonTapped: cancelAlertButtonTapped,
            selectedImageData: selectedImage,
            inputNickname: nicknameInputView.inputTextField.rx.text.orEmpty,
            inputPhoneNumber: phoneNumberInputView.inputTextField.rx.text.orEmpty,
            inputBirthday: birthdayPicker.rx.date,
            doneButtonTapped: doneButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.cancelButtonTapped
            .bind(with: self) { owner, _ in
                owner.showAlert(title: "프로필 수정", message: "프로필 수정을 취소하시겠습니까?", buttonTitle: "확인", buttonStyle: .default) { okAction in
                    cancelAlertButtonTapped.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        output.executeCancel
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        profileImageViewTapGesture.rx.event
            .bind(with: self) { owner, _ in
                owner.openPHPicker()
            }
            .disposed(by: disposeBag)
        
        output.selectedImageData
            .map { UIImage(data: $0) }
            .bind(to: profileImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.nicknameValue
            .bind(to: nicknameInputView.inputTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.phoneNumberValue
            .bind(to: phoneNumberInputView.inputTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.birthdayValue
            .bind(to: birthdayInputView.inputTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.failedEdit
            .bind(with: self) { owner, value in
                switch value {
                case .invalidProfile:
                    owner.showToast(message: "프로필 사진을 선택해 주세요", position: .center)
                case .invalidNickname:
                    owner.showToast(message: "닉네임을 공백없이 입력해 주세요", position: .center)
                case .invalidPhoneNumber:
                    owner.showToast(message: "숫자만 포함해서 전화번호를 입력해 주세요", position: .center)
                case .invalidBirthday:
                    owner.showToast(message: "생일을 입력해 주세요", position: .center)
                }
            }
            .disposed(by: disposeBag)
        
        output.succeedEdit
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
            
        output.networkError
            .bind(with: self) { owner, value in
                owner.showNetworkRequestFailAlert(errorType: value.0, routerType: value.1)
            }
            .disposed(by: disposeBag)
    }
    
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
            make.size.equalTo(120)
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
        }
        
        phoneNumberInputView.snp.makeConstraints { make in
            make.top.equalTo(nicknameInputView.snp.bottom).offset(35)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        birthdayInputView.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberInputView.snp.bottom).offset(35)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    override func configureUI() {
        super.configureUI()
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ProfileEditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        for (index, result) in results.enumerated() {
            guard index < 1 else { break }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                if let image = object as? UIImage {
                    if let data = image.jpegData(compressionQuality: 0.6) {
                        self?.selectedImage.accept(data)
                    }
                }
            }
        }
    }
    
    func openPHPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}
