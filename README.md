# MusicSearch 🎵

**MusicSearch**는 사용자가 음악을 검색하고, 차트를 확인하며, 현재 날씨에 어울리는 추천 음악을 받을 수 있는 iOS 애플리케이션입니다.

---

## 📂 폴더 구조 (Project Structure)
```
MusicSearch
├── App
│   ├── Resources       # Assets, Info.plist
│   └── Sources         # AppDelegate, SceneDelegate
├── Core
│   ├── Domain          # UseCases, Entities, Interfaces
│   ├── Data            # Repositories, DTOs, Network
│   ├── Presentation    # Common UI Components
│   └── Util            # Extensions, Constants
└── Features
    ├── Digging         # Music Digging Feature
    ├── Home            # Home Screen Feature
    └── Trend           # Chart & Trend Feature
```

---

## 🛠 기술 스택 (Tech Stack)

| Category | Stack |
| --- | --- |
| **Language** | Swift |
| **Framework** | UIKit (Code-based) |
| **Architecture** | MVVM-C, Repository Pattern |
| **Concurrency** | Swift Concurrency (async/await) |
| **Reactive** | Combine |
| **Networking** | URLSession |
| **UI** | Compositional Layout, DiffableDataSource, Auto Layout |
| **Open API** | Spotify, Last.fm, OpenWeatherMap |

---

## 🏗️ 아키텍처 (Architecture)

### 1. Dependency Injection (DI)
`Component`와 `Dependency` 프로토콜을 기반으로 외부 라이브러리 없이 의존성을 관리합니다.

<details>
<summary><b>상세 내용 보기 (View Details)</b></summary>

* **Component (Factory)**: 객체 생성을 담당하며, 필요한 의존성을 주입하여 인스턴스(VC, ViewModel, Coordinator)를 생성합니다.
* **Dependency (Protocol)**: 각 기능(Feature)이 필요로 하는 의존성(UseCase, Repository 등)을 추상화하여 정의합니다.
* **AppComponent**: 앱의 최상위 컨테이너로, 모든 Feature Dependency를 구현하여 구체적인 의존성을 제공합니다.

**DiggingDependency.swift (Protocol)**
```swift
protocol DiggingDependency: Dependency {
    var searchTracksUseCase: SearchTracksUseCase { get }
    var fetchSimilarTrackUseCase: FetchSimilarTracksUseCase { get }
}
```

**DiggingComponent.swift (Factory)**
```swift
final class DiggingComponent<T: DiggingDependency>: Component {
    // ...
    func makeMusicDiggingViewController(seedTrack: Track) -> MusicDiggingViewController {
        // ViewModel 생성 시 UseCase 주입
        let viewModel = self.makeMusicDiggingViewModel(
            seedTrack: seedTrack, 
            fetchSimilarTracksUseCase: self.dependency.fetchSimilarTrackUseCase
        )
        return MusicDiggingViewController(viewModel: viewModel)
    }
}
```
</details>

### 2. Coordinator Pattern
화면 전환 로직을 `ViewController`로부터 완전히 분리하였습니다.

<details>
<summary><b>코드 보기 (View Code)</b></summary>

**Coordinator.swift (Protocol)**
```swift
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    func start()
}
```

**TrackSearchViewCoordinator.swift (Implementation)**
```swift
final class TrackSearchViewCoordinator: Coordinator {
    var navigationController: UINavigationController
    // ...

    func start() {
        let vc = self.component.makeTrackSearchViewController(coordinator: self)
        self.navigationController.setViewControllers([vc], animated: false)
    }

    // 화면 전환 요청 처리
    func didSelect(_ track: Track) {
        let diggingCoordinator = MusicDiggingViewCoordinator(
            navigationController: self.navigationController,
            component: self.component,
            seedTrack: track
        )
        diggingCoordinator.start()
    }
}
```
</details>

### 3. MVVM (Unidirectional Data Flow)
**Input(Action)**과 **Output(State)**을 명확히 정의하여 데이터 흐름을 단방향으로 관리합니다.

<details>
<summary><b>코드 보기 (View Code)</b></summary>

**TrackSearchViewModel.swift**
```swift
// Action: 사용자의 입력 또는 이벤트
enum TrackSearchAction {
    case search(keyword: String)
    case loadMore
    // ...
}

// State: 화면의 현재 상태
struct TrackSearchState {
    var isLoading: Bool = false
    var tracks: [Track] = []
    // ...
}

final class TrackSearchViewModel {
    @Published private(set) var state: TrackSearchState = .init()
    
    func process(action: TrackSearchAction) {
        switch action {
        case .search(let keyword):
            self.search(keyword: keyword)
        case .loadMore:
            self.loadMore()
        }
    }
}
```
</details>

---

## 🚀 주요 기능 및 구현 (Implementation)

### 검색 방식(Debounce)
**Combine**의 `debounce` 연산자를 사용하여 사용자 입력에 반응하면서도 과도한 API 호출을 방지합니다.

<details>
<summary><b>코드 보기 (View Code)</b></summary>

**TrackSearchViewModel.swift**
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
</details>

### 무한 스크롤 (Pagination)

<details>
<summary><b>코드 보기 (View Code)</b></summary>

**TrackSearchViewModel.swift**
```swift
private func loadMore() {
    // 중복 로딩 방지 및 마지막 페이지 체크
    guard self.state.canLoadMore, let keyword = self.lastKeyword else { return }
    
    let nextPage = self.state.currentPage + 1
    
    Task {
        self.state.isLoadingMore = true
        // 다음 페이지 요청
        let result = try await self.searchTracksUseCase.execute(query: keyword, limit: self.limit, page: nextPage)
        // 결과 추가
        self.state.tracks.append(contentsOf: result.tracks)
        self.state.currentPage = nextPage
        self.state.isLoadingMore = false
    }
}
```
</details>

### 딥링크 (Deep Linking)
음악 앱 연동을 추상화했습니다. Spotify API를 통해 딥링크를 가져오고, 앱이 없으면 웹 플레이어로 폴백합니다.

<details>
<summary><b>코드 보기 (View Code)</b></summary>

**MusicAppRouting.swift**
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

**SpotifyAppRepository.swift**
```swift
func fetchDeepLink(for track: Track) async -> URL? {
    do {
        let token = try await self.getAccessToken()
        let query = "\(track.title) \(track.artist)"
        let urlString = try await self.search(query: query, type: "track", token: token)
        return URL(string: urlString)
    } catch {
        // 에러 시 검색 페이지로 폴백
        return self.fallbackWebURL(query: query)
    }
}
```
</details>
