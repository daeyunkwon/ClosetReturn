//
//  FeedEditViewController.swift
//  ClosetReturn
//
//  Created by 권대윤 on 8/25/24.
//

import UIKit
import PhotosUI

import RxSwift
import RxCocoa
import SnapKit

final class FeedEditViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel: FeedEditViewModel
    
    private let selectedImages = PublishRelay<[Data]>()
    
    //MARK: - Init
    
    init(viewModel: FeedEditViewModel) {
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
    
    private let photoBackView = RoundedBackTitleContainerView(title: "피드 사진")
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
    
    private let contentBackView = RoundedBackTitleContainerView(title: "내용")
    private let contentTextView = PlaceholderTextView(placeholder: """
    오늘의 스타일을 자랑해보세요!
    
    룩에 담긴 감정이나 메시지 또는 하고싶은 이야기를 적어주세요.
    
    #해시태그1 #해시태그2 와 같은 방법으로 해시태그를 설정 가능합니다:)
    """)
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Configurations
    
    override func bind() {
        
        let viewDidLoad = PublishRelay<Void>()
        let cellXmarkButtonTapped = PublishRelay<Int>()
        
        let input = FeedEditViewModel.Input(
            photoSelectButtonTapped: photoSelectButton.rx.tap,
            viewDidLoad: viewDidLoad,
            selectedImages: selectedImages,
            cellXmarkButtonTapped: cellXmarkButtonTapped,
            cancelButtonTapped: cancelButton.rx.tap,
            content: contentTextView.rx.text.orEmpty,
            doneButtonTapped: doneButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.navigationTitle
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        output.photoSelectButtonTapped
            .bind(with: self) { owner, _ in
                owner.performHapticFeedback()
                owner.photoSelectButton.bounce()
                owner.openPHPicker()
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
        
        output.cancelButtonTapped
            .bind(with: self) { owner, _ in
                owner.showEditCancelCheckAlert(type: .feed)
            }
            .disposed(by: disposeBag)
        
        output.hidePlaceholder
            .bind(to: contentTextView.placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.invalidInfo
            .bind(with: self) { owner, type in
                owner.showToast(message: type.rawValue, position: .center)
            }
            .disposed(by: disposeBag)
        
        output.content
            .bind(to: contentTextView.rx.text)
            .disposed(by: disposeBag)
        
        output.doneButtonTapped
            .bind(with: self) { owner, _ in
                owner.performHapticFeedback()
            }
            .disposed(by: disposeBag)
        
        output.succeedUpload
            .bind(with: self) { owner, _ in
                owner.viewModel.postUploadSucceed()
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.networkError
            .bind(with: self) { owner, value in
                owner.showNetworkRequestFailAlert(errorType: value.0, routerType: value.1)
            }
            .disposed(by: disposeBag)
        
        viewDidLoad.accept(())
    }
    
    override func setupNavi() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
    }
    
    override func configureHierarchy() {
        view.addSubview(scrollView)
        view.addSubview(doneButton)
        view.addSubview(cancelButton)
        scrollView.addSubview(containerView)
        
        photoBackView.addSubviews(photoSelectButton, collectionView)
        contentBackView.addSubview(contentTextView)
        
        containerView.addSubviews(
            photoBackView,
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
            make.width.equalTo(100)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(photoBackView.titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(photoSelectButton.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
        
        contentBackView.snp.makeConstraints { make in
            make.top.equalTo(photoBackView.snp.bottom).offset(20)
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
}

// MARK: - PHPickerViewControllerDelegate

extension FeedEditViewController: PHPickerViewControllerDelegate {
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
