//
//  ProductPostEditViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/22/24.
//

import UIKit
import PhotosUI

import RxSwift
import RxCocoa
import SnapKit

final class ProductPostEditViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    private let viewModel: any BaseViewModel
    
    private let selectedImages = PublishRelay<[Data]>()
    
    //MARK: - Init
    
    init(viewModel: any BaseViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Components
    
    private let doneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("완료", for: .normal)
        btn.titleLabel?.font = Constant.Font.buttonLargeTitleFont
        btn.tintColor = Constant.Color.Button.cancelColor
        return btn
    }()
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.titleLabel?.font = Constant.Font.buttonLargeTitleFont
        btn.tintColor = Constant.Color.Button.cancelColor
        return btn
    }()
    
    private let scrollView = UIScrollView()
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let photoBackView = RoundedBackTitleContainerView(title: "상품 사진")
    private let photoSelectButton = PhotoButton(type: .system)
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150, height: 140)
        layout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = false
        cv.register(SelectedPhotoCell.self, forCellWithReuseIdentifier: SelectedPhotoCell.identifier)
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private let titleBackView = RoundedBackTitleContainerView(title: "제목")
    private let titleTextField = RoundedBackTextField(placeholder: "제목을 입력해 주세요")
    
    private let priceBackView = RoundedBackTitleContainerView(title: "가격")
    private let priceTextField: RoundedBackTextField = {
        let tf = RoundedBackTextField(placeholder: "판매 가격을 숫자만 입력해 주세요")
        tf.keyboardType = .numberPad
        return tf
    }()
    
    private let brandBackView = RoundedBackTitleContainerView(title: "브랜드")
    private let brandTextField = RoundedBackTextField(placeholder: "브랜드명을 입력해 주세요")
    
    private let sizeBackView = RoundedBackTitleContainerView(title: "사이즈")
    private let sizeTextField = RoundedBackTextField(placeholder: "사이즈 정보를 입력해 주세요")
    
    private let categoryBackView = RoundedBackTitleContainerView(title: "카테고리")
    private let categoryTextField = RoundedBackTextField(placeholder: "상의, 남성 상의, 여성 상의 등")
    
    private let conditionBackView = RoundedBackTitleContainerView(title: "컨디션")
    private let conditionSOptionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("  새 상품", for: .normal)
        btn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = Constant.Font.buttonTitleFont
        btn.layer.borderWidth = 0
        btn.layer.borderColor = Constant.Color.brandColor.cgColor
        btn.layer.cornerRadius = 15
        btn.tintColor = .lightGray
        btn.backgroundColor = .systemGray6
        return btn
    }()
    
    private let conditionAOptionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("  새 상품에 가까운 깨끗한 상품", for: .normal)
        btn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = Constant.Font.buttonTitleFont
        btn.layer.borderWidth = 0
        btn.layer.borderColor = Constant.Color.brandColor.cgColor
        btn.layer.cornerRadius = 15
        btn.tintColor = .lightGray
        btn.backgroundColor = .systemGray6
        return btn
    }()
    
    private let conditionBOptionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("  사용감이 있는 깨끗한 상품", for: .normal)
        btn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = Constant.Font.buttonTitleFont
        btn.layer.borderWidth = 0
        btn.layer.borderColor = Constant.Color.brandColor.cgColor
        btn.layer.cornerRadius = 15
        btn.tintColor = .lightGray
        btn.backgroundColor = .systemGray6
        return btn
    }()
    
    private let conditionCOptionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("  사용감이 있고 손상이 있는 상품", for: .normal)
        btn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = Constant.Font.buttonTitleFont
        btn.layer.borderWidth = 0
        btn.layer.borderColor = Constant.Color.brandColor.cgColor
        btn.layer.cornerRadius = 15
        btn.tintColor = .lightGray
        btn.backgroundColor = .systemGray6
        return btn
    }()
    
    private let contentBackView = RoundedBackTitleContainerView(title: "내용")
    private let contentTextView = PlaceholderTextView(placeholder: """
    상품에 대한 설명과
    구매자가 알아야 할 정보를 입력해 주세요.
    
    고장, 파손, 오염, 물빠짐, 얼룩 등의 손상 정보는 꼭 기재해 주세요!!
    
    #해시태그1 #해시태그2 와 같은 방법으로 해시태그를 설정 가능합니다:)
    """)
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        if let viewModel = viewModel as? ProductPostEditViewModel {
            
            let cellXmarkButtonTapped = PublishRelay<Int>()
            
            let input = ProductPostEditViewModel.Input(
                viewDidLoad: Observable.just(()),
                cancelButtonTapped: cancelButton.rx.tap,
                selectedImages: selectedImages,
                photoSelectButton: photoSelectButton.rx.tap,
                cellXmarkButtonTapped: cellXmarkButtonTapped,
                doneButtonTapped: doneButton.rx.tap,
                title: titleTextField.rx.text.orEmpty,
                price: priceTextField.rx.text.orEmpty,
                brand: brandTextField.rx.text.orEmpty,
                size: sizeTextField.rx.text.orEmpty,
                category: categoryTextField.rx.text.orEmpty,
                conditionSButtonTapped: conditionSOptionButton.rx.tap,
                conditionAButtonTapped: conditionAOptionButton.rx.tap,
                conditionBButtonTapped: conditionBOptionButton.rx.tap,
                conditionCButtonTapped: conditionCOptionButton.rx.tap,
                content: contentTextView.rx.text.orEmpty
            )
            let output = viewModel.transform(input: input)
            
            output.navigationTitle
                .bind(to: navigationItem.rx.title)
                .disposed(by: disposeBag)
            
            output.title
                .bind(to: titleTextField.rx.text)
                .disposed(by: disposeBag)
            
            output.price
                .bind(to: priceTextField.rx.text)
                .disposed(by: disposeBag)
            
            output.brand
                .bind(to: brandTextField.rx.text)
                .disposed(by: disposeBag)
            
            output.size
                .bind(to: sizeTextField.rx.text)
                .disposed(by: disposeBag)
            
            output.category
                .bind(to: categoryTextField.rx.text)
                .disposed(by: disposeBag)
            
            output.condition
                .bind(with: self) { owner, value in
                    switch value {
                    case "S": owner.updateConditionOptionButtonAppearance(selected: owner.conditionSOptionButton)
                    case "A": owner.updateConditionOptionButtonAppearance(selected: owner.conditionAOptionButton)
                    case "B": owner.updateConditionOptionButtonAppearance(selected: owner.conditionBOptionButton)
                    case "C": owner.updateConditionOptionButtonAppearance(selected: owner.conditionCOptionButton)
                    default: owner.updateConditionOptionButtonAppearance(selected: UIButton())
                    }
                }
                .disposed(by: disposeBag)
            
            output.content
                .bind(to: contentTextView.rx.text)
                .disposed(by: disposeBag)
            
            output.doneButtonTapped
                .bind(with: self) { owner, _ in
                    owner.view.endEditing(true)
                }
                .disposed(by: disposeBag)
            
            output.cancelButtonTapped
                .bind(with: self) { owner, _ in
                    owner.showEditCancelCheckAlert(type: .product)
                }
                .disposed(by: disposeBag)
            
            output.photoSelectButtonTapped
                .bind(with: self) { owner, _ in
                    owner.photoSelectButton.bounce()
                    owner.openPHPicker()
                }
                .disposed(by: disposeBag)
            
            output.invalidInfo
                .bind(with: self) { owner, type in
                    owner.showToast(message: type.rawValue, position: .center)
                }
                .disposed(by: disposeBag)
            
            let images = output.selectedImageList
                .asDriver(onErrorJustReturn: [])
                .asObservable()
                
            images
                .map { $0.count }
                .bind(with: self) { owner, value in
                    owner.photoSelectButton.updateLabel(withCount: value)
                }
                .disposed(by: disposeBag)
                
            images
                .bind(to: collectionView.rx.items(cellIdentifier: SelectedPhotoCell.identifier, cellType: SelectedPhotoCell.self)) { row, element, cell in
                    cell.cellConfig(withImageData: element)
                    
                    cell.xmarkButton.rx.tap
                        .bind { _ in
                            cellXmarkButtonTapped.accept(row)
                        }
                        .disposed(by: cell.disposeBag)
                }
                .disposed(by: disposeBag)
            
            output.priceString
                .bind(to: priceTextField.rx.text)
                .disposed(by: disposeBag)

            output.selectedConditionButton
                .bind(with: self) { owner, value in
                    switch value {
                    case "S": owner.updateConditionOptionButtonAppearance(selected: owner.conditionSOptionButton)
                    case "A": owner.updateConditionOptionButtonAppearance(selected: owner.conditionAOptionButton)
                    case "B": owner.updateConditionOptionButtonAppearance(selected: owner.conditionBOptionButton)
                    case "C": owner.updateConditionOptionButtonAppearance(selected: owner.conditionCOptionButton)
                    default: owner.updateConditionOptionButtonAppearance(selected: UIButton())
                    }
                }
                .disposed(by: disposeBag)
            
            output.contentPlaceholder
                .bind(to: contentTextView.placeholderLabel.rx.isHidden)
                .disposed(by: disposeBag)
            
            output.networkError
                .bind(with: self) { owner, value in
                    owner.showNetworkRequestFailAlert(errorType: value.0, routerType: value.1)
                }
                .disposed(by: disposeBag)
            
            output.succeedUpload
                .bind(with: self) { owner, _ in
                    let viewModel = viewModel as ProductPostEditViewModel
                    viewModel.postUploadSucceed(true)
                    owner.dismiss(animated: true)
                }
                .disposed(by: disposeBag)
        }
    }
    
    override func setupNavi() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
    }
    
    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        photoBackView.addSubviews(photoSelectButton, collectionView)
        titleBackView.addSubview(titleTextField)
        priceBackView.addSubview(priceTextField)
        brandBackView.addSubview(brandTextField)
        sizeBackView.addSubview(sizeTextField)
        categoryBackView.addSubview(categoryTextField)
        conditionBackView.addSubviews(conditionSOptionButton, conditionAOptionButton, conditionBOptionButton, conditionCOptionButton)
        contentBackView.addSubview(contentTextView)
        
        containerView.addSubviews(
            photoBackView,
            titleBackView,
            priceBackView,
            brandBackView,
            sizeBackView,
            categoryBackView,
            conditionBackView,
            contentBackView
        )
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.width.equalTo(view.frame.size.width)
            make.verticalEdges.equalToSuperview()
        }
        
        photoBackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(200)
        }
        
        photoSelectButton.snp.makeConstraints { make in
            make.top.equalTo(photoBackView.titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(10)
            make.width.equalTo(77)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(photoBackView.titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(photoSelectButton.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
        
        titleBackView.snp.makeConstraints { make in
            make.top.equalTo(photoBackView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(titleBackView.titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(38)
            make.bottom.equalToSuperview().inset(10)
        }
        
        priceBackView.snp.makeConstraints { make in
            make.top.equalTo(titleBackView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        priceTextField.snp.makeConstraints { make in
            make.top.equalTo(priceBackView.titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(38)
            make.bottom.equalToSuperview().inset(10)
        }
        
        brandBackView.snp.makeConstraints { make in
            make.top.equalTo(priceBackView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        brandTextField.snp.makeConstraints { make in
            make.top.equalTo(brandBackView.titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(38)
            make.bottom.equalToSuperview().inset(10)
        }
        
        sizeBackView.snp.makeConstraints { make in
            make.top.equalTo(brandBackView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        sizeTextField.snp.makeConstraints { make in
            make.top.equalTo(sizeBackView.titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(38)
            make.bottom.equalToSuperview().inset(10)
        }
        
        categoryBackView.snp.makeConstraints { make in
            make.top.equalTo(sizeBackView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        categoryTextField.snp.makeConstraints { make in
            make.top.equalTo(categoryBackView.titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(38)
            make.bottom.equalToSuperview().inset(10)
        }
        
        conditionBackView.snp.makeConstraints { make in
            make.top.equalTo(categoryBackView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        conditionSOptionButton.snp.makeConstraints { make in
            make.top.equalTo(conditionBackView.titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(50)
        }
        
        conditionAOptionButton.snp.makeConstraints { make in
            make.top.equalTo(conditionSOptionButton.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(50)
        }
        
        conditionBOptionButton.snp.makeConstraints { make in
            make.top.equalTo(conditionAOptionButton.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(50)
        }
        
        conditionCOptionButton.snp.makeConstraints { make in
            make.top.equalTo(conditionBOptionButton.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(10)
        }
        
        contentBackView.snp.makeConstraints { make in
            make.top.equalTo(conditionBackView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(20)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(contentBackView.titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(500)
            make.bottom.equalToSuperview().inset(10)
        }
        
        contentTextView.placeholderLabel.snp.makeConstraints { make in
            make.width.equalTo(contentTextView).inset(15)
        }
    }
    
    override func configureUI() {
        view.backgroundColor = .systemGray6
    }
    
    //MARK: - Methods

    private func updateConditionOptionButtonAppearance(selected: UIButton) {
        [conditionSOptionButton, conditionAOptionButton, conditionBOptionButton, conditionCOptionButton].forEach { btn in
            if btn == selected {
                btn.backgroundColor = .white
                btn.layer.borderWidth = 2
                btn.tintColor = Constant.Color.brandColor
                btn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            } else {
                btn.backgroundColor = .systemGray6
                btn.layer.borderWidth = 0
                btn.tintColor = .lightGray
                btn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ProductPostEditViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        var selectedImageDataList: [Data] = []
        let dispatchGroup = DispatchGroup()
        
        for (index, result) in results.enumerated() {
            guard index < 5 else { break }
            
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    if let data = image.jpegData(compressionQuality: 0.6) {
                        selectedImageDataList.append(data)
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            if !selectedImageDataList.isEmpty {
                self?.selectedImages.accept(selectedImageDataList)
            }
        }
    }
    
    func openPHPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}
