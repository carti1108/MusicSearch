# MusicSearch 🎵

음악 검색, 실시간 차트, 현재 날씨 기반 추천을 한 앱에서 제공하는 UIKit 기반 iOS 앱.

---

## 🧾 목차

- [📱 실행 화면](#-실행-화면)
- [✨ 주요 기능](#-주요-기능)
- [📂 폴더 구조](#-폴더-구조)
- [🛠 기술 스택](#-기술-스택)
- [🔐 실행 준비](#-실행-준비)
- [🧭 아키텍처](#-아키텍처)
- [🚀 주요 구현](#-주요-구현)
- [🧪 테스트](#-테스트)
- [🐛 트러블슈팅](#-트러블슈팅)

---

## 📱 실행 화면

| Weather | Search | Chart |
| :---: | :---: |:---: |
| <img src="https://github.com/user-attachments/assets/72dc3c6c-7321-427a-88e1-de0bd4669aa3" width="150" alt="Home" /> | <img src="https://github.com/user-attachments/assets/03e122f6-c892-4715-9211-b5bb99b70559" width="150" alt="Search" /> | <img src="https://github.com/user-attachments/assets/71496392-0bd3-443c-98e3-8d227843b7b6" width="150" alt="Chart" /> |

---

## ✨ 주요 기능

| 구분 | 기능 |
| --- | --- |
| **날씨 추천** | 현재 위치 날씨를 음악 태그로 변환 후 추천 트랙 제공 |
| **음악 검색** | Last.fm 기반 트랙 검색, 페이지네이션, 상세 정보 보강 |
| **음악 디깅** | 선택한 트랙과 유사한 곡 탐색, 외부 음악 앱 연결 |
| **차트** | 인기 트랙과 아티스트 차트를 podium/list 형태로 표시 |
| **오류 대응** | 네트워크, 위치 권한, API 설정 오류를 사용자 메시지로 변환 |

---

## 📂 폴더 구조

```text
MusicSearch
├── MusicSearch
│   ├── App
│   │   ├── Resources                 # Assets, Info.plist, LaunchScreen
│   │   └── Sources                   # AppDelegate, SceneDelegate, AppComponent, AppRoot
│   ├── Core
│   │   ├── Data
│   │   │   ├── DTOs                  # Last.fm, Spotify, Weather 응답 DTO
│   │   │   ├── Network               # API request 정의
│   │   │   └── Repositories          # Repository 구현체
│   │   ├── DependencyInjection       # Component / Dependency 프로토콜
│   │   ├── Domain
│   │   │   ├── Entities              # Track, Artist, Weather 등 도메인 모델
│   │   │   ├── Interfaces            # Repository interface
│   │   │   └── UseCases              # Feature에서 사용하는 비즈니스 유스케이스
│   │   ├── Presentation              # 공용 presentation contract
│   │   └── Util                      # Extension, reusable UI helper
│   └── Features
│       ├── Digging                   # 검색 / 유사 트랙 탐색
│       ├── Home                      # 날씨 기반 추천
│       └── Trend                     # 차트
├── MusicSearchTests                  # Repository / UseCase / ViewModel 단위 테스트
├── MusicSearchUITests
├── Config.xcconfig                   # API key 설정
└── README.md
```

---

## 🛠 기술 스택

| Category | Stack |
| --- | --- |
| **Language** | Swift |
| **Framework** | UIKit, Auto Layout |
| **Architecture** | Clean Architecture, MVVM-C, Repository Pattern |
| **Concurrency** | Swift Concurrency (`async`/`await`) |
| **Reactive** | Combine |
| **Networking** | URLSession 기반 `NetworkLayer` SPM 모듈 |
| **Image Loading** | Kingfisher |
| **UI** | UICollectionView Compositional Layout, Diffable Data Source |
| **Open API** | Last.fm, Spotify, OpenWeatherMap |
| **Testing** | XCTest |

---

## 🧭 아키텍처

Clean Architecture 기반 Domain, Data, Feature 계층 분리. 화면 흐름은 MVVM-C로 구성.

- `Core/Domain` — `Entity`, `UseCase`, `Repository Interface` 소유. UIKit·네트워크 구현 의존 없음
- `Core/Data` — 외부 API 응답 DTO 수신 후 Domain Entity 변환
- `Features` — ViewController, ViewModel, Coordinator, DI Component를 feature 단위로 구성
- ViewModel — API나 DTO 직접 의존 없이 UseCase만 호출
- Coordinator — 화면 전환과 외부 앱 연결 흐름 담당

```text
ViewController
  -> ViewModel
  -> UseCase
  -> Repository Interface
  -> Repository Implementation
  -> API / DTO
  -> Domain Entity
```

---

## 🚀 주요 구현

### 1. 🌦 날씨 기반 음악 추천

#### 🎯 목적

현재 위치 날씨를 음악 태그로 매핑. 태그 기반 트랙 목록 추천.

#### 🔧 구현

`FetchMusicForWeatherUseCase`에서 현재 날씨 조회와 태그 기반 트랙 조회 조합.
날씨 조건을 음악 태그로 변환하는 책임은 `WeatherTagMapper`로 분리. 테스트 가능 구조.

<details>
<summary>💻 코드 예시</summary>

```swift
struct FetchMusicForWeatherUseCaseImpl: FetchMusicForWeatherUseCase {
    private let fetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase
    private let fetchTracksByTagUseCase: FetchTracksByTagUseCase
    private let tagMapper: WeatherTagMapper

    init(
        fetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase,
        fetchTracksByTagUseCase: FetchTracksByTagUseCase,
        tagMapper: WeatherTagMapper = WeatherTagMapper()
    ) {
        self.fetchCurrentWeatherUseCase = fetchCurrentWeatherUseCase
        self.fetchTracksByTagUseCase = fetchTracksByTagUseCase
        self.tagMapper = tagMapper
    }

    func execute() async throws -> WeatherMusicCuration {
        let weather = try await self.fetchCurrentWeatherUseCase.execute()
        let tag = self.tagMapper.map(condition: weather.condition)
        let tracks = try await self.fetchTracksByTagUseCase.execute(tag: tag)

        return .init(
            weather: weather,
            moodTag: tag,
            tracks: tracks
        )
    }
}
```

</details>

#### ✅ 결과

Home feature는 위치, 날씨 API, Last.fm API 세부 구현 의존 없이 `WeatherMusicCuration`만 받아 화면 상태 갱신.

---

### 2. 🧭 MVVM-C 화면 흐름 분리

#### 🎯 목적

ViewController, ViewModel, Coordinator 책임 분리. 화면 상태와 화면 전환 독립 테스트·수정 구조.

#### 🔧 구현

ViewController는 사용자 입력을 `Listener`로 전달. ViewModel은 `Viewable` 인터페이스로 화면 갱신.
화면 전환은 ViewModel 직접 수행 대신 `CoordinatorAction`으로 Coordinator에 위임.

<details>
<summary>💻 코드 예시</summary>

```swift
@MainActor
protocol TrackSearchViewableListener: AnyObject {
    func didUpdateSearchText(_ keyword: String)
    func didTapRetry()
    func didSelectTrack(_ track: Track)
    func didReachListBottom()
}

@MainActor
protocol TrackSearchViewable: AnyObject {
    var listener: TrackSearchViewableListener? { get set }
    func updateTracks(_ tracks: [Track])
    func showLoading(_ isShow: Bool)
    func showError(_ message: String?)
}
```

```swift
final class TrackSearchViewCoordinator<T: DiggingDependency>: Coordinator, TrackSearchViewCoordinatorAction {
    override func start() {
        let vc = TrackSearchViewController()
        let viewModel = self.component.makeTrackSearchViewModel(view: vc)
        viewModel.coordinator = self
        self.navigationController.setViewControllers([vc], animated: false)
    }

    func didSelect(_ track: Track) {
        let diggingCoordinator = MusicDiggingViewCoordinator(
            navigationController: self.navigationController,
            component: self.component,
            seedTrack: track
        )
        self.addChild(diggingCoordinator)
        diggingCoordinator.start()
    }
}
```

</details>

#### ✅ 결과

검색, 디깅, 차트, 홈 화면 흐름 통일. ViewModel 테스트에서 화면 전환 요청까지 검증.

---

### 3. 🔎 검색 입력과 페이지네이션

#### 🎯 목적

검색어 입력마다 즉시 API 호출 방지. 입력 안정 후 요청, 리스트 하단 도달 시 다음 페이지 append.

#### 🔧 구현

Combine의 `debounce`, `removeDuplicates`로 검색 입력 제어. `isLoading`, `isLoadingMore`, `loadingPage`로 중복 요청 방지.

<details>
<summary>💻 코드 예시</summary>

```swift
private func bindSearchInput() {
    self.searchSubject
        .debounce(for: .seconds(self.debounceSeconds), scheduler: RunLoop.main)
        .removeDuplicates()
        .sink { [weak self] keyword in
            self?.performSearch(keyword: keyword)
        }
        .store(in: &self.cancellables)
}
```

```swift
private var canLoadMore: Bool {
    !self.isLoading && !self.isLoadingMore && self.currentTracks.count < self.totalResults
}
```

</details>

#### ✅ 결과

검색 입력, 재시도, 더 불러오기 흐름을 ViewModel 안에서 분리. 테스트 가능.

---

### 4. ⚡ 트랙 상세 정보 병렬 보강

#### 🎯 목적

차트와 추천 목록에서 부족한 앨범 이미지, 상세 메타데이터 보강.

#### 🔧 구현

`Array where Element == Track` 확장으로 병렬 보강 로직 캡슐화.
개별 트랙 상세 요청 실패 시 전체 목록 실패 없이 원본 트랙 유지.

<details>
<summary>💻 코드 예시</summary>

```swift
extension Array where Element == Track {
    func enrichingTrackInfo(
        maxConcurrentRequests: Int = 8,
        using fetchTrackInfo: @escaping @Sendable (Track) async throws -> Track
    ) async -> [Track] {
        guard !self.isEmpty else { return [] }

        var enrichedTracks = self
        await withTaskGroup(of: (Int, Track?).self) { group in
            // maxConcurrentRequests만큼 요청을 흘려보내고, 실패한 트랙은 nil로 반환
        }

        return enrichedTracks
    }
}
```

```swift
func execute() async throws -> [Track] {
    let tracks = try await self.chartRepository.fetchTopTracks()
    return await tracks.enrichingTrackInfo(using: self.chartRepository.fetchTrackInfo(for:))
}
```

</details>

#### ✅ 결과

목록 단위 요청 속도 유지. 상세 정보 실패가 전체 UI 실패로 번지지 않도록 fallback 보장.

---

### 5. 🧩 자체 DI Component 구성

#### 🎯 목적

외부 DI 프레임워크 없이 feature별 의존성 명시 조립. 테스트 더블 주입 용이.

#### 🔧 구현

`AppComponent`가 앱 공통 repository와 use case 소유. 각 feature의 `Dependency` 프로토콜 채택.
Feature Component는 필요한 의존성만 받아 ViewModel과 Coordinator 생성.

<details>
<summary>💻 코드 예시</summary>

```swift
protocol DiggingDependency: Dependency {
    var searchTracksUseCase: SearchTracksUseCase { get }
    var fetchTracksByTagUseCase: FetchTracksByTagUseCase { get }
    var fetchSimilarTrackUseCase: FetchSimilarTracksUseCase { get }
    var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase { get }
}
```

```swift
final class DiggingComponent<T: DiggingDependency>: Component {
    typealias DependencyType = T

    private let dependency: T

    init(dependency: T) {
        self.dependency = dependency
    }

    @MainActor
    func makeTrackSearchViewModel(view: TrackSearchViewable) -> TrackSearchViewModel {
        TrackSearchViewModel(
            view: view,
            searchTracksUseCase: self.dependency.searchTracksUseCase
        )
    }
}
```

</details>

#### ✅ 결과

Feature별 의존성 범위가 코드에 명시. 테스트에서는 mock repository나 mock use case로 교체 용이.

---

### 6. 🎧 외부 음악 앱 연결 추상화

#### 🎯 목적

Spotify 검색과 deep link 생성 세부 구현을 화면 계층에서 분리.

#### 🔧 구현

`MusicAppRouting`은 `FetchMusicAppDeepLinkUseCase`만 참조. 실제 Spotify token/search API 호출은 `SpotifyAppRepository`로 분리.

<details>
<summary>💻 코드 예시</summary>

```swift
protocol MusicAppRouting: AnyObject {
    var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase { get }
}

extension MusicAppRouting {
    func openMusicApp(for track: Track) {
        Task {
            guard let url = await self.fetchMusicAppDeepLinkUseCase.execute(track: track) else { return }
            await MainActor.run {
                UIApplication.shared.open(url)
            }
        }
    }
}
```

</details>

#### ✅ 결과

Coordinator와 ViewModel의 Spotify API 응답 구조·URL 생성 규칙 의존 제거. 외부 음악 앱 연결 수행.

---

## 🧪 테스트

단위 테스트는 `Repository`, `UseCase`, `ViewModel` 중심 구성.

- `MusicSearchTests/TestSupport` — `MockRepositories`, `MockUseCases`, `ViewSpies`, `AsyncTestHelper`, `TestDataFactory`로 테스트 더블 재사용
- UseCase 테스트 — 성공/실패 전파, fallback, tag mapping 같은 도메인 흐름 검증
- ViewModel 테스트 — loading, error, pagination, retry, selection 등 화면 상태 전이 검증
- Repository 테스트 — DTO 변환과 API 실패 전파 중심 확인

```text
MusicSearchTests
├── Features
│   ├── Home
│   ├── Music
│   ├── Trend
│   └── Weather
└── TestSupport
```

---

## 🐛 트러블슈팅

### 1. 📐 셀 내부 여백이 콘텐츠 길이에 따라 흔들리는 문제

#### 🧨 문제

`TrackCarouselCell`에서 곡 제목이 1줄일 때 이미지와 텍스트 사이 간격 과다. 카드 내부 균형 깨짐.

#### 🔍 원인

`UIStackView.distribution = .equalSpacing` 사용 시 남는 높이가 arranged subview 사이에 균등 분배. 텍스트 줄 수에 따라 spacing 변화.

#### 🔧 해결

스택뷰는 `distribution = .fill`로 변경. 마지막 arranged subview에 `spacerView` 추가.
잉여 공간은 하단 spacer가 흡수. 이미지-제목-아티스트 간격은 고정 spacing 유지.

<details>
<summary>💻 코드 예시</summary>

```swift
private let mainStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 10
    stack.alignment = .fill
    stack.distribution = .fill
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
}()

private let spacerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.setContentHuggingPriority(.defaultLow, for: .vertical)
    view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    return view
}()
```

</details>

#### ✅ 결과

제목 1줄·2줄 모두 카드 내부 spacing 일정 유지.

---

### 2. ✨ 첫 스크롤 시 차트 셀 깜빡임

#### 🧨 문제

차트 화면에서 podium/list crossfade 적용 후 첫 스크롤·bounce 순간 셀 깜빡임.

#### 🔍 원인

첫 스크롤 시점에 셀 재사용, 레이아웃 갱신, 초기 alpha/transform 적용 중첩.
`UICollectionViewCell` 자체 속성 직접 조작 시 collection view 레이아웃 속성 초기화와 충돌 가능.

#### 🔧 해결

`willDisplay`에서 신규 셀에도 현재 scroll progress 즉시 적용. 초기 진입 전 `layoutIfNeeded()` 후 crossfade 상태 고정.
애니메이션 대상은 `cell` 대신 `cell.contentView`로 한정.

<details>
<summary>💻 코드 예시</summary>

```swift
func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath
) {
    let progress = self.calculateScrollProgress()
    self.applyEffect(to: cell, at: indexPath, progress: progress)
}

private func primeInitialCrossfadeIfNeeded(force: Bool = false) {
    guard force || !self.hasPrimedInitialCrossfade else { return }
    guard self.collectionView.bounds.width > 0, self.collectionView.bounds.height > 0 else { return }

    self.collectionView.layoutIfNeeded()
    self.applyCrossfadeEffects()
    self.hasPrimedInitialCrossfade = true
}
```

</details>

#### ✅ 결과

첫 스크롤 시 기본 상태 복귀감 감소. Podium/list 전환 안정성 개선.
