# MusicSearch 🎵

음악 검색, 실시간 차트, 현재 날씨 기반 추천을 한 앱에서 제공하는 UIKit 기반 iOS 애플리케이션.

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

<p align="leading">
  <img src="https://github.com/user-attachments/assets/e7e79ffb-1256-43b5-b753-4e288b4b5279" width="150" alt="Home" />
  <img src="https://github.com/user-attachments/assets/9a598c16-8af9-433a-9c75-9b4ccc9888a6" width="150" alt="Search" />
  <img src="https://github.com/user-attachments/assets/c0ccd027-376d-44a1-b435-94b136b0846b" width="150" alt="Chart" />
</p>

---

## ✨ 주요 기능

| 구분 | 기능 |
| --- | --- |
| **날씨 추천** | 현재 위치의 날씨를 음악 태그로 변환해 추천 트랙 제공 |
| **음악 검색** | Last.fm 기반 트랙 검색, 페이지네이션, 상세 정보 보강 |
| **음악 디깅** | 선택한 트랙과 유사한 곡을 탐색하고 외부 음악 앱으로 연결 |
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

## 🔐 실행 준비

`Config.xcconfig`에 아래 key를 설정하면 `Info.plist`를 통해 앱에서 읽어 사용한다.

```text
OPENWEATHERMAP_API_KEY = <OpenWeatherMap API Key>
LASTFM_API_KEY = <Last.fm API Key>
SPOTIFY_CLIENT_ID = <Spotify Client ID>
SPOTIFY_CLIENT_SECRET = <Spotify Client Secret>
```

Xcode에서 `MusicSearch.xcodeproj`를 열고 `MusicSearch` scheme으로 실행한다.

---

## 🧭 아키텍처

Clean Architecture를 기반으로 Domain, Data, Feature 계층을 분리하고, 화면 흐름은 MVVM-C로 구성.

- `Core/Domain`은 `Entity`, `UseCase`, `Repository Interface`를 소유하고 UIKit이나 네트워크 구현을 알지 않는다.
- `Core/Data`는 외부 API 응답을 DTO로 받은 뒤 Domain Entity로 변환한다.
- `Features`는 ViewController, ViewModel, Coordinator, DI Component를 feature 단위로 묶는다.
- ViewModel은 API나 DTO에 직접 의존하지 않고 UseCase만 호출한다.
- Coordinator는 화면 전환과 외부 앱 연결 흐름을 담당한다.

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

현재 위치의 날씨를 음악 태그로 매핑하고, 해당 태그에 맞는 트랙 목록을 추천.

#### 🔧 구현

`FetchMusicForWeatherUseCase`에서 현재 날씨 조회와 태그 기반 트랙 조회를 조합한다.
날씨 조건을 음악 태그로 변환하는 책임은 `WeatherTagMapper`로 분리해 테스트 가능하도록 구성했다.

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

Home feature는 위치, 날씨 API, Last.fm API의 세부 구현을 몰라도 `WeatherMusicCuration`만 받아 화면 상태를 갱신한다.

---

### 2. 🧭 MVVM-C 화면 흐름 분리

#### 🎯 목적

ViewController, ViewModel, Coordinator의 책임을 분리해 화면 상태와 화면 전환을 독립적으로 테스트하고 수정할 수 있도록 구성.

#### 🔧 구현

ViewController는 사용자 입력을 `Listener`로 전달하고, ViewModel은 `Viewable` 인터페이스를 통해 화면을 갱신한다.
화면 전환은 ViewModel이 직접 수행하지 않고 `CoordinatorAction`으로 Coordinator에 위임한다.

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

검색, 디깅, 차트, 홈 화면이 동일한 흐름으로 읽히며 ViewModel 테스트에서 화면 전환 요청까지 검증할 수 있다.

---

### 3. 🔎 검색 입력과 페이지네이션

#### 🎯 목적

검색어 입력마다 API를 즉시 호출하지 않고, 입력이 안정된 뒤 요청하며 리스트 하단 도달 시 다음 페이지를 이어붙인다.

#### 🔧 구현

Combine의 `debounce`와 `removeDuplicates`로 검색 입력을 제어하고, 페이지 로딩 상태는 `isLoading`, `isLoadingMore`, `loadingPage`로 나누어 중복 요청을 막는다.

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

검색 입력, 재시도, 더 불러오기 흐름을 ViewModel 안에서 명확히 분리하고 테스트할 수 있다.

---

### 4. ⚡ 트랙 상세 정보 병렬 보강

#### 🎯 목적

차트와 추천 목록에서 기본 트랙 정보만으로 부족한 앨범 이미지, 상세 메타데이터를 빠르게 보강.

#### 🔧 구현

`Array where Element == Track` 확장으로 병렬 보강 로직을 캡슐화했다.
개별 트랙 상세 요청이 실패해도 전체 목록을 실패시키지 않고 원본 트랙을 유지한다.

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

목록 단위 요청은 빠르게 유지하면서, 상세 정보 실패가 전체 UI 실패로 번지지 않도록 fallback 흐름을 보장한다.

---

### 5. 🧩 자체 DI Component 구성

#### 🎯 목적

외부 DI 프레임워크 없이 feature별 의존성을 명시적으로 조립하고 테스트 더블을 주입하기 쉽게 구성.

#### 🔧 구현

`AppComponent`가 앱 공통 repository와 use case를 소유하고, 각 feature의 `Dependency` 프로토콜을 채택한다.
Feature Component는 필요한 의존성만 받아 ViewModel과 Coordinator를 생성한다.

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

Feature가 필요한 의존성의 범위가 코드에 드러나고, 테스트에서는 mock repository나 mock use case로 쉽게 교체할 수 있다.

---

### 6. 🎧 외부 음악 앱 연결 추상화

#### 🎯 목적

Spotify 검색과 deep link 생성 세부 구현을 화면 계층에서 분리.

#### 🔧 구현

`MusicAppRouting`이 `FetchMusicAppDeepLinkUseCase`만 알고, 실제 Spotify token/search API 호출은 `SpotifyAppRepository`에 둔다.

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

Coordinator와 ViewModel은 Spotify API 응답 구조나 URL 생성 규칙을 몰라도 외부 음악 앱 연결을 수행할 수 있다.

---

## 🧪 테스트

단위 테스트는 `Repository`, `UseCase`, `ViewModel` 중심으로 구성.

- `MusicSearchTests/TestSupport`에 `MockRepositories`, `MockUseCases`, `ViewSpies`, `AsyncTestHelper`, `TestDataFactory`를 모아 테스트 더블을 재사용한다.
- UseCase 테스트는 성공/실패 전파, fallback, tag mapping 같은 도메인 흐름을 검증한다.
- ViewModel 테스트는 loading, error, pagination, retry, selection 등 화면 상태 전이를 검증한다.
- Repository 테스트는 DTO 변환과 API 실패 전파를 중심으로 확인한다.

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

`TrackCarouselCell`에서 곡 제목이 1줄일 때 이미지와 텍스트 사이 간격이 과하게 벌어져 카드 내부 균형이 깨졌다.

#### 🔍 원인

`UIStackView.distribution = .equalSpacing`을 사용하면 남는 높이가 arranged subview 사이에 균등하게 분배되어, 텍스트 줄 수에 따라 spacing이 달라졌다.

#### 🔧 해결

스택뷰는 `distribution = .fill`로 두고 마지막 arranged subview에 `spacerView`를 추가했다.
잉여 공간은 하단 spacer가 흡수하고, 이미지-제목-아티스트 간격은 고정 spacing을 따른다.

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

제목이 1줄이든 2줄이든 카드 내부 spacing이 일정하게 유지된다.

---

### 2. ✨ 첫 스크롤 시 차트 셀 깜빡임

#### 🧨 문제

차트 화면에서 podium 영역과 list 영역 사이 crossfade를 적용한 뒤, 첫 스크롤이나 bounce 순간 셀이 번쩍이는 현상이 있었다.

#### 🔍 원인

첫 스크롤 시점에 셀 재사용, 레이아웃 갱신, 초기 alpha/transform 적용이 겹쳤다.
또한 `UICollectionViewCell` 자체 속성을 직접 조작하면 collection view의 레이아웃 속성 초기화와 충돌할 수 있었다.

#### 🔧 해결

`willDisplay`에서 새로 표시되는 셀에도 현재 scroll progress를 즉시 적용하고, 초기 진입 전에 `layoutIfNeeded()` 후 crossfade 상태를 한 번 고정했다.
애니메이션 대상은 `cell`이 아니라 `cell.contentView`로 좁혔다.

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

첫 스크롤 시 기본 상태로 되돌아가는 느낌이 줄고, podium/list 전환이 더 안정적으로 보인다.
