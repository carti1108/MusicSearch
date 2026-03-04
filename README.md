# MusicSearch 🎵

**MusicSearch**는 사용자가 음악을 검색하고, 차트를 확인하며, 현재 날씨에 어울리는 추천 음악을 받을 수 있는 iOS 애플리케이션입니다.

---

## 실행화면

<p align="leading">
  <img src="https://github.com/user-attachments/assets/e7e79ffb-1256-43b5-b753-4e288b4b5279" width="150" alt="Home" />
  <img src="https://github.com/user-attachments/assets/9a598c16-8af9-433a-9c75-9b4ccc9888a6" width="150" alt="Search" />
  <img src="https://github.com/user-attachments/assets/c0ccd027-376d-44a1-b435-94b136b0846b" width="150" alt="Chart" />
</p>

## 📂 폴더 구조 (Project Structure)
```
MusicSearch
├── App
│   ├── Resources       # Assets, Info.plist
│   └── Sources         # AppDelegate, SceneDelegate, Root RIB
├── Core
│   ├── Domain          # UseCases, Entities, Interfaces
│   ├── Data            # Repositories, DTOs, Network
│   └── Util            # Extensions, Constants
└── Features (RIBs)
    ├── Digging         # Search RIB, MusicDigging RIB
    ├── Home            # Home RIB
    └── Trend           # Trend RIB
```

---

## 🛠 기술 스택 (Tech Stack)

| Category | Stack |
| --- | --- |
| **Language** | Swift |
| **Framework** | UIKit (Code-based) |
| **Architecture** | RIBs, Repository Pattern |
| **Concurrency** | Swift Concurrency (async/await) |
| **Reactive** | Combine |
| **Networking** | URLSession |
| **UI** | Compositional Layout, DiffableDataSource, Auto Layout |
| **Open API** | Spotify, Last.fm, OpenWeatherMap |

---

## 🏗️ 아키텍처 (Architecture)

### 1. RIBs Architecture
Uber의 RIBs(Router-Interactor-Builder) 아키텍처를 사용하여 비즈니스 로직과 UI를 완전히 분리함.

<details>
<summary><b>RIBs 구성요소</b></summary>

* **Builder**: RIB 생성 및 의존성 주입을 담당
* **Interactor**: 비즈니스 로직 처리, UseCase 호출
* **Router**: 자식 RIB attach/detach 및 화면 전환 관리
* **Presenter (ViewController)**: 수동적 View, UI 렌더링만 담당

**TrackSearchBuilder.swift**
```swift
protocol TrackSearchBuildable: Buildable {
    func build(
        withListener listener: TrackSearchListener,
        navigationController: UINavigationController
    ) -> TrackSearchRouting
}

final class TrackSearchBuilder: Builder<DiggingDependency>, TrackSearchBuildable {
    func build(
        withListener listener: TrackSearchListener,
        navigationController: UINavigationController
    ) -> TrackSearchRouting {
        let component = DiggingComponent(dependency: self.dependency)
        let viewController = TrackSearchViewController()
        let interactor = TrackSearchInteractor(
            presenter: viewController,
            searchTracksUseCase: component.searchTracksUseCase
        )
        interactor.listener = listener
        
        let musicDiggingBuilder = MusicDiggingBuilder(dependency: component)
        return TrackSearchRouter(
            interactor: interactor,
            viewController: viewController,
            navigationController: navigationController,
            musicDiggingBuilder: musicDiggingBuilder
        )
    }
}
```
</details>

### 2. Router (화면 전환)
자식 RIB을 attach/detach하고 네비게이션 스택을 관리함.

<details>
<summary><b>코드 보기 (View Code)</b></summary>

**TrackSearchRouter.swift**
```swift
final class TrackSearchRouter: ViewableRouter<TrackSearchInteractable, TrackSearchViewControllable>, TrackSearchRouting {
    private let navigationController: UINavigationController
    private let musicDiggingBuilder: MusicDiggingBuildable
    private var childRoutersByViewControllerID: [ObjectIdentifier: Routing] = [:]
    
    func attachMusicDigging(seedTrack: Track) {
        let musicDiggingRouter = self.musicDiggingBuilder.build(
            withListener: self.interactor,
            seedTrack: seedTrack
        )
        self.attachChild(musicDiggingRouter)
        
        let viewController = musicDiggingRouter.viewControllable.uiviewController
        self.childRoutersByViewControllerID[ObjectIdentifier(viewController)] = musicDiggingRouter
        self.navigationController.pushViewController(viewController, animated: true)
    }
}
```
</details>

### 3. Presentable / PresentableListener (View ↔ Interactor)
View와 Interactor는 프로토콜을 통해서만 통신함.

<details>
<summary><b>코드 보기 (View Code)</b></summary>

**TrackSearchInteractor.swift**
```swift
@MainActor
protocol TrackSearchPresentableListener: AnyObject {
    func didUpdateSearchText(_ keyword: String)
    func didTapRetry()
    func didSelectTrack(_ track: Track)
    func didReachListBottom()
}

@MainActor
protocol TrackSearchPresentable: Presentable {
    var listener: TrackSearchPresentableListener? { get set }
    func updateTracks(_ tracks: [Track])
    func showLoading(_ isShow: Bool)
    func showError(_ message: String?)
}

final class TrackSearchInteractor: PresentableInteractor<TrackSearchPresentable>, TrackSearchPresentableListener {
    weak var router: TrackSearchRouting?
    weak var listener: TrackSearchListener?
    private let searchTracksUseCase: SearchTracksUseCase
    
    func didSelectTrack(_ track: Track) {
        self.router?.attachMusicDigging(seedTrack: track)
    }
}
```
</details>

---

## 🚀 주요 기능 및 구현 (Implementation)

### Debounce (검색 최적화)
Combine의 `debounce`로 과도한 API 호출을 방지함.

<details>
<summary><b>코드 보기</b></summary>

**TrackSearchInteractor.swift**
```swift
private func bindSearchInput() {
    self.searchSubject
        .removeDuplicates()
        .debounce(for: .seconds(self.debounceSeconds), scheduler: DispatchQueue.main)
        .sink { [weak self] keyword in
            self?.performSearch(keyword: keyword)
        }
        .store(in: &self.cancellables)
}
```
</details>

### Task 취소 (Stale Response 방지)
이전 검색/로딩 Task를 취소하여 순서 보장 및 리소스 절약함.

<details>
<summary><b>코드 보기</b></summary>

**TrackSearchInteractor.swift**
```swift
private var searchTask: Task<Void, Never>?
private var loadMoreTask: Task<Void, Never>?

private func performSearch(keyword: String) {
    self.searchTask?.cancel()  // 이전 검색 취소
    self.loadMoreTask?.cancel()
    
    self.searchTask = Task { [weak self] in
        guard let self else { return }
        do {
            let result = try await self.searchTracksUseCase.execute(...)
            guard !Task.isCancelled else { return }  // 취소 확인
            
            self.presenter.updateTracks(result.tracks)
        } catch is CancellationError {
            return
        }
    }
}
```
</details>

### Actor (Thread-Safety)
SpotifyAppRepository를 Actor로 구현하여 토큰 관리의 race condition을 방지함.

<details>
<summary><b>코드 보기</b></summary>

**SpotifyAppRepository.swift**
```swift
actor SpotifyAppRepository: MusicAppRepository {
    private var accessToken: String?
    private var accessTokenExpiry: Date?
    
    private func getAccessToken(forceRefresh: Bool = false) async throws -> String {
        // 토큰이 유효하면 재사용
        if !forceRefresh, self.isTokenValid, let token = self.accessToken {
            return token
        }
        
        // Actor 내부에서 토큰 요청 (thread-safe)
        let tokenResponse = try await URLSession.shared.data(for: request)
        self.accessToken = tokenResponse.access_token
        self.accessTokenExpiry = Date().addingTimeInterval(...)
        return tokenResponse.access_token
    }
}
```
</details>

### Router를 통한 딥링크
Router에서 딥링크를 처리하여 외부 앱을 열거나 웹으로 폴백함.

<details>
<summary><b>코드 보기</b></summary>

**HomeRouter.swift**
```swift
func openMusicApp(for track: Track) {
    Task {
        guard let url = await self.fetchDeepLink(for: track) else { return }
        await MainActor.run {
            UIApplication.shared.open(url)
        }
    }
}

private func fetchDeepLink(for track: Track) async -> URL? {
    await self.appComponent.musicAppRepository.fetchDeepLink(for: track)
}
```
</details>
