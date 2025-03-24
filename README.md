![Swift](https://img.shields.io/badge/Swift-5.10-orange)
![Xcode](https://img.shields.io/badge/Xcode-15.3-blue)

# 옷장리턴  <img width="100" alt="image" src="https://github.com/user-attachments/assets/63a1a750-64c0-4154-937d-84c37416a771" align="left">
> 중고 의류를 구매하거나 판매하고, 패션 스타일을 공유할 수 있는 앱이에요 ✨

<br>

## 📖 프로젝트 정보
- 개발 기간: `2024.08.14 ~ 2024.08.31 (18일)`
- 최소 지원 버전: `iOS 16.0`
- 사용 언어 및 도구: `Swift 5.10` `Xcode 15.3`
- 팀 구성:
  - `iOS 개발(본인)`
  - `서버 개발(SeSAC memolease)`

<br>

## 🛠️ 사용 기술

- 언어: `Swift`
- 프레임워크: `UIKit`
- 아키텍처: `MVVM`
- 그 외 기술:
  - `RxSwift` `RxCocoa`
  - `CodeBaseUI` `SnapKit`
  - `Alamofire`
  - `UserDefaults`
  - `PhotosUI`
  - `iamport-ios`
  - `IQKeyboardManager`
  - `Toast-Swift`
  - `Firebase Messaging`
 
<br>

## 📱 주요 화면 및 기능

### 핵심 기능 소개
> - 중고 의류 상품을 조회, 생성, 수정, 삭제할 수 있는 기능을 제공합니다.
> - 피드 게시물을 조회, 생성, 수정, 삭제할 수 있는 기능을 제공합니다.
> - 중고 의류 상품과 피드 게시물에 좋아요 및 좋아요 취소 기능을 제공하며, 좋아요한 항목을 조회할 수 있습니다.
> - 중고 의류 상품 결제 기능을 제공합니다.

<br>

### 홈 화면
> - 화면을 아래로 스크롤 하여 판매 중인 상품 목록을 계속해서 조회할 수 있습니다.
> - 상품을 선택하면 상품 상세 화면으로 화면 전환됩니다.
> - `좋아요(♡)` 버튼을 선택하여 좋아요 및 좋아요 취소를 할 수 있습니다.
> - `상품 등록(+)` 버튼을 선택하면 상품 등록 작성 화면으로 화면 전환됩니다.
> - 화면을 아래로 당겨서 새로고침을 할 수 있습니다.

| 홈 화면 |
| :---: |
| <img src="https://github.com/user-attachments/assets/87a9298c-78bb-49fc-8119-cfae2f50bb55" width="200"> |

### 상품 등록 화면
> - `사진 첨부(카메라 아이콘)` 버튼을 선택하면 앨범에서 최대 5장의 사진을 선택할 수 있습니다.
> - 제목, 가격, 브랜드, 사이즈, 카테고리, 컨디션(옷 상태), 내용 등의 판매할 상품에 관한 정보를 입력할 수 있습니다.
> - `완료` 버튼을 선택하면 입력한 내용을 바탕으로 상품이 등록되며, 홈 화면에서 조회할 수 있습니다.
> - `취소(X)` 버튼을 선택하면 상품 등록을 취소할 것인지 재확인하는 Alert이 표시되며, `확인` 선택 시 상품 등록이 취소됩니다.

| 상품 등록 화면 |
| :---: |
| <img src="https://github.com/user-attachments/assets/1b952995-a48e-4cc8-b84f-3142ad796797" width="200"> |

### 상품 상세 화면
> - 우측 상단의 `메뉴(···)` 버튼을 선택하면 수정 및 삭제 옵션이 포함된 메뉴가 표시됩니다.
>   - `수정` 메뉴 선택 시 상품 수정 화면으로 화면 전환됩니다.
>   - `삭제` 메뉴 선택 시 상품 삭제할 것인지 재확인하는 Alert이 표시되며, `확인` 선택 시 상품이 삭제됩니다.
> - `메뉴(···)` 버튼은 로그인한 사용자 본인 게시물인 경우에만 표시됩니다.
> - 좌우로 스와이프하여 이전이나 다음 상품 사진을 볼 수 있습니다.
> - `좋아요(♡)` 버튼을 선택하여 좋아요 및 좋아요 취소를 할 수 있습니다.
> - `댓글(말풍선 아이콘)` 버튼을 선택하면 댓글 조회 화면으로 화면 전환됩니다.
> - `구매하기` 버튼을 선택하면 KG 이니시스 결제 화면으로 화면 전환됩니다.
> - 이미 결제된 상품은 `구매하기` 버튼이 비활성화됩니다.

| 상품 상세 화면 |
| :---: |
| <img src="https://github.com/user-attachments/assets/9d04ea48-4830-41c5-90c5-78182315aa4f" width="200"> | 

### 좋아요 화면
> - 상품 탭을 선택하면 좋아요한 상품 목록을 조회할 수 있습니다.
> - 피드 탭을 선택하면 좋아요한 피드 목록을 조회할 수 있습니다.
> - 조회된 목록에서 특정 항목을 선택하면 해당 상품 또는 피드의 상세 화면으로 화면 전환됩니다.

| 좋아요 화면 |
| :---: |
| <img src="https://github.com/user-attachments/assets/85555b5e-b4c3-4bc7-b503-4057ef611854" width="200"> | 

### 프로필 화면
> - 로그인한 사용자의 프로필 이미지, 닉네임, 등록한 피드 개수, 등록한 판매 상품 개수, 팔로워 수, 팔로잉 수에 대한 정보를 조회할 수 있습니다.
> - 우측 상단의 `설정` 버튼을 선택하면 로그아웃할 수 있습니다.
> - `프로필 편집` 버튼을 선택하면 프로필 수정 화면으로 화면 전환됩니다.
> - 피드 탭을 선택하면 사용자가 등록한 피드 목록을 조회할 수 있습니다.
> - 판매 중인 상품 탭을 선택하면 사용자가 등록한 상품 목록을 조회할 수 있습니다.
> - 구매 내역 탭을 선택하면 결제한 상품 목록을 조회할 수 있습니다.

| 프로필 화면 |
| :---: |
| <img src="https://github.com/user-attachments/assets/3678553c-b32a-4815-93f8-977e869e0e7e" width="200"> | 


<br>

## 📡 주요 기술
- MVVM Pattern을 도입하여 ViewController와 View는 화면을 그리는 역할에만 집중하게 하고, 데이터 관리와 로직 처리는 ViewModel에서 담당하도록 분리했습니다.
- ViewModel에 Input-Output Pattern을 적용하여 데이터 흐름을 명확하게 했습니다.
- RxSwift와 RxCocoa를 활용하여 비동기 이벤트 스트림을 관리하고, UI와 데이터 간의 반응형 바인딩을 구현했습니다.
- Router Pattern을 사용하여 모든 서버 API를 한 곳에서 관리하기 쉽게 했습니다.
- Access Token 만료 시 Refresh Token을 이용해 새로운 토큰을 발급받고, 이를 저장하는 기능을 구현했습니다.
- 카드 결제를 지원하기 위해 포트원(iamport-ios)을 연동하고, 결제 영수증을 검증하여 구매 완료 처리를 진행할 수 있도록 구현했습니다.
- Cursor-based Pagination 기능을 구현하여 상품 및 피드 데이터를 페이지 단위로 조회할 수 있도록 했습니다.
- PHPickerViewController를 사용하여 이미지 선택 화면을 제공하고, 사용자가 선택한 이미지는 JPEG 형식으로 압축한 후에 multipart/form-data 타입으로 서버에 전송하는 기능을 구현했습니다.
- Firebase Cloud Messaging을 이용해 Firebase Console에서 전송한 Push Notification을 수신할 수 있도록 했습니다.
- BaseViewController 클래스를 상속하여, 모든 뷰 컨트롤러에서 공통된 초기화 메서드의 일관성을 유지했습니다.
- REST API를 이용해 게시물 CRUD 기능을 구현했습니다. (GET, POST, PUT, DELETE 적용)

<br>

## 🚀 문제 및 해결 과정

### 1. 앨범에서 선택한 이미지가 추가되지 않는 문제

#### 문제 상황

상품 등록 화면에서 사진 첨부 기능을 구현했습니다. 사용자가 앨범에서 선택한 이미지들이 목록에 표시되어, 추가된 이미지를 확인할 수 있어야 했습니다. 그러나 선택한 이미지들이 추가되지 않아 목록에 표시되지 않는 문제가 발생했습니다.

<img width="250" alt="image" src="https://github.com/user-attachments/assets/7501ffae-b6c9-4987-9736-396d42255868">



#### 문제 원인

PHPickerViewController에서 선택한 자산들은 JPEG 이미지 데이터로 변환된 후 배열에 담겨 ViewModel로 전달됩니다. ViewModel은 받은 이미지 데이터를 바탕으로 CollectionView에 이미지 목록을 업데이트하는 흐름을 처리하고 있었습니다. 그러나 `loadObject(ofClass:)` 메서드가 비동기적으로 실행됨에 따라, 해당 메서드의 작업이 완료되기 전에 다음 줄인 배열을 전달하는 코드가 실행되었고, 이로 인해 ViewModel에는 항상 빈 배열이 전달됐기 때문에 해당 문제 현상이 발생했습니다.

<img width="800" alt="스크린샷 2024-09-03 오후 4 16 51" src="https://github.com/user-attachments/assets/a287df66-23f6-4fc2-aa87-4450e5bb9d77">


#### 해결 방법

해당 문제는 DispatchGroup을 통해 비동기 작업의 시작과 종료를 체크하고, 모든 작업이 완료되었을 때 실행되는 notify 클로저 내에서 이미지 데이터들을 담고 있는 배열을 전달하는 방법으로 해결했습니다.

<img width="800" alt="스크린샷 2024-09-03 오후 4 16 51" src="https://github.com/user-attachments/assets/9b35c86b-56ee-4cb3-835c-a9c7e5186c4d">

<br><br>

### 2. 이메일 유효성 검증을 어떻게 할 수 있을지에 대한 고민

#### 문제 상황

회원가입 화면에서 이메일 주소를 입력하는 텍스트 필드가 있었습니다. 해당 텍스트 필드에 유효한 이메일 정보를 기입하지 않고, 임의의 문자나 숫자 값을 입력해도 회원가입이 가능한 문제가 발생했습니다.

<img width="250" alt="image" src="https://github.com/user-attachments/assets/e62a9a3a-a84c-4e8a-886c-742dd64a3ca5">


#### 문제 원인
입력한 정보가 이메일 형식으로 유효한지 판단하는 조건이 누락되었습니다.

#### 해결 방법

처음에는 텍스트 필드에 입력한 문자열 값의 중간 부분에 `@` 기호가 포함되어 있으면 유효하지 않을까 생각했습니다. 하지만 `@` 기호뿐만 아니라 도메인 주소와 최상위 도메인 주소 영역도 유효한지 고려해야 한다는 것을 깨달았습니다. 어떻게 하면 모든 고려 사항을 충족하는 유효성 검증 기능을 구현해 낼 수 있을까 검색해 본 결과, 정규식을 사용하면 복잡한 검증 로직을 간결하게 구현해 낼 수 있다는 것을 알게 되었습니다. 그래서 NSPredicate와 정규식을 조합해 간결한 유효성 검증 로직을 구현하여 해결하였습니다.

<img width="800" alt="스크린샷 2024-09-03 오후 4 16 51" src="https://github.com/user-attachments/assets/2251c7cf-667b-46c0-ab5b-09b2b1542918">


<br><br>

### 3. bind(with:) 사용 시 순환 참조 발생 문제

#### 문제 상황

`.bind(with: self)`의 클로저 내부에 ViewModel을 생성하고, 그 내부에서 ViewModel의 클로저를 설정하는 다음과 같은 코드 구조에서 순환 참조로 인해 메모리 누수 문제가 발생했습니다.

<img width="607" alt="image" src="https://github.com/user-attachments/assets/6a9086c7-4b53-4060-8e6d-04186896b45a" />

#### 문제 원인

`.bind(with: self)` 메서드의 클로저 내부에 `vm.postUploadSucceed`의 클로저가 존재하는 중첩 클로저 상태입니다. 이 상황에서 외부 클로저가 `self (ViewController)`를 강하게 참조하고,
내부 클로저에서 `self`를 약한 참조로 캡처했지만,
외부 클로저의 강한 참조로 인해 내부 클로저에서도 `self`가 해제되지 못하는 문제가 발생했습니다.

#### 해결 방법

외부 클로저에서 `[weak self]`를 사용하여 `self(ViewController)`를 약한 참조로 캡처하여 순환 참조를 방지했습니다.

<img width="623" alt="image" src="https://github.com/user-attachments/assets/429b1879-2a6f-4c3f-8d47-847446c8f8ba" />


또 다른 방법으로는 `.bind(with: self)` 메서드가 제공하는 클로저 매개변수 `owner`를 활용하여, `self` 대신 `owner`를 사용함으로써 순환 참조를 방지해볼 수 있음을 확인했습니다.

<img width="616" alt="image" src="https://github.com/user-attachments/assets/d17f2121-efc5-43c4-bed8-542514dd7f5a" />







