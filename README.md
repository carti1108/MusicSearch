# MusicSearch 🎵

음악 검색, 실시간 차트, 현재 날씨 기반 추천을 RIBs 구조로 구성한 UIKit 기반 iOS 앱.

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
  <img src="https://github.com/user-attachments/assets/e7e79ffb-1256-43b5-b753-4e288b4b5279" width="150" alt="Weather Recommendation" />
  <img src="https://github.com/user-attachments/assets/9a598c16-8af9-433a-9c75-9b4ccc9888a6" width="150" alt="Search" />
  <img src="https://github.com/user-attachments/assets/c0ccd027-376d-44a1-b435-94b136b0846b" width="150" alt="Chart" />
</p>

---

## ✨ 주요 기능

| 구분 | 기능 |
| --- | --- |
| **날씨 추천** | 현재 위치 날씨를 음악 태그로 변환 후 추천 트랙 제공 |
| **음악 검색** | Last.fm 기반 트랙 검색, debounce, 페이지네이션 |
| **음악 디깅** | 선택한 트랙과 유사한 곡을 child RIB로 탐색 |
| **차트** | 인기 트랙과 아티스트 차트를 podium/list 형태로 표시 |
| **외부 앱 연결** | Spotify deep link 조회 후 음악 앱 연결 |
| **RIB 테스트** | Builder, Interactor, Router wiring과 상태 흐름 검증 |

---

## 📂 폴더 구조

```text
MusicSearch
├── MusicSearch
│   ├── App
│   │   ├── Resources                 # Assets, Info.plist, LaunchScreen
│   │   └── Sources
│   │       └── Root                  # Root RIB, 탭 구성
│   ├── Core
│   │   ├── Data
│   │   │   ├── DTOs                  # Last.fm, Spotify, Weather 응답 DTO
│   │   │   ├── Network               # API request 정의
│   │   │   └── Repositories          # Repository 구현체
│   │   ├── Domain
│   │   │   ├── Entities              # Track, Artist, Weather 등 도메인 모델
│   │   │   ├── Interfaces            # Repository interface
│   │   │   ├── Services              # TrackEnrichmentService
│   │   │   └── UseCases              # Feature에서 사용하는 비즈니스 유스케이스
│   │   └── Util                      # Extension, reusable UI helper
│   └── Features
│       ├── Chart                     # Chart RIB
│       ├── Digging
│       │   ├── MusicDigging          # 유사 트랙 탐색 child RIB
│       │   └── Search                # TrackSearch RIB
│       └── WeatherRecommendation     # 날씨 추천 RIB
├── MusicSearchTests
│   ├── App
│   ├── Core
│   └── Features                      # RIB 단위 테스트
├── MusicSearchUITests
├── Docs
│   └── RIBs-Guide.md
├── Config.xcconfig                   # API key 설정
└── README.md
```

---

## 🛠 기술 스택

| Category | Stack |
| --- | --- |
| **Language** | Swift |
| **Framework** | UIKit, Auto Layout |
| **Architecture** | RIBs, Repository Pattern |
| **Concurrency** | Swift Concurrency (`async`/`await`) |
| **Reactive** | Combine |
| **Networking** | URLSession 기반 `NetworkLayer` SPM 모듈 |
| **Image Loading** | Kingfisher |
| **UI** | UICollectionView Compositional Layout, Diffable Data Source |
| **Open API** | Last.fm, Spotify, OpenWeatherMap |
| **Testing** | Swift Testing, XCTest |

---

## 🔐 실행 준비

`Config.xcconfig`에 아래 key 설정. `Info.plist`를 통해 앱에서 사용.

```text
OPENWEATHERMAP_API_KEY = <OpenWeatherMap API Key>
LASTFM_API_KEY = <Last.fm API Key>
SPOTIFY_CLIENT_ID = <Spotify Client ID>
SPOTIFY_CLIENT_SECRET = <Spotify Client Secret>
```

Xcode에서 `MusicSearch.xcodeproj`를 열고 `MusicSearch` scheme 실행.

---

## 🧭 아키텍처

RIBs 기반 feature를 `Builder / Interactor / Router / View` 단위로 분리.
Root RIB에서 날씨 추천, 검색, 차트 RIB를 탭 단위로 attach. Feature별 독립 조립·테스트 구조.

- `Builder` — View, Interactor, Router 생성 및 dependency 주입
- `Interactor` — 사용자 입력, 비즈니스 로직, 비동기 요청, 화면 상태 갱신
- `Router` — child RIB attach/detach, navigation stack 반영
- `ViewController` — listener로 입력 전달, presenter 메서드로 화면 갱신
- `Dependency / Component` — 부모-자식 RIB 사이 의존성 계약과 전달 범위 명시

- [RIBs 가이드](./Docs/RIBs-Guide.md)

```text
Root RIB
├── WeatherRecommendation RIB
├── TrackSearch RIB
│   └── MusicDigging RIB
└── Chart RIB
```

---

## 🚀 주요 구현

### 1. 🧩 Root RIB 탭 구성

#### 🎯 목적

앱 시작 시 세 개의 feature RIB 독립 조립 및 탭바 연결.

#### 🔧 구현

`RootBuilder`에서 Root RIB와 child builder 조립. `RootRouter`에서 feature RIB attach 후 탭 배열 구성.
검색 탭은 `TrackSearch`에서 `MusicDigging`으로 push 이동이 필요해 별도 `UINavigationController` 공유.

<details>
<summary>💻 코드 예시</summary>

```swift
final class RootBuilder: Builder<RootDependency>, RootBuildable {
    func build() -> LaunchRouting {
        MainActor.assumeIsolated {
            let component = RootComponent(dependency: self.dependency)
            let viewController = RootViewController()
            let interactor = RootInteractor(presenter: viewController)

            return RootRouter(
                interactor: interactor,
                viewController: viewController,
                weatherRecommendationBuilder: component.weatherRecommendationBuilder,
                trackSearchBuilder: component.trackSearchBuilder,
                chartBuilder: component.chartBuilder
            )
        }
    }
}
```

```swift
override func didLoad() {
    super.didLoad()

    let weatherRecommendationRouter = self.weatherRecommendationBuilder.build(withListener: self.interactor)
    self.attachChild(weatherRecommendationRouter)

    let trackSearchNavigationController = UINavigationController()
    let trackSearchRouter = self.trackSearchBuilder.build(
        withListener: self.interactor,
        navigationController: trackSearchNavigationController
    )
    self.attachChild(trackSearchRouter)

    let chartRouter = self.chartBuilder.build(withListener: self.interactor)
    self.attachChild(chartRouter)

    self.viewController.setTabs([
        UINavigationController(rootViewController: weatherRecommendationRouter.viewControllable.uiViewController),
        trackSearchNavigationController,
        UINavigationController(rootViewController: chartRouter.viewControllable.uiViewController)
    ])
}
```

</details>

#### ✅ 결과

Feature RIB 조립 책임과 탭 구성 책임을 Root로 집중. Feature 간 구현 의존 없이 독립 확장.

---

### 2. 🧭 Builder / Interactor / Router 책임 분리

#### 🎯 목적

화면 입력, 비즈니스 로직, 화면 전환, 의존성 조립 분리. RIB 단위 테스트 가능 구조.

#### 🔧 구현

`TrackSearchBuilder`에서 검색 화면 객체 조립. `TrackSearchInteractor`에서 검색 입력과 선택 이벤트 처리.
트랙 선택 이후 push 전환은 Interactor 직접 수행 대신 Router에 요청.

<details>
<summary>💻 코드 예시</summary>

```swift
func didSelectTrack(_ track: Track) {
    self.router?.attachMusicDigging(seedTrack: track)
}
```

```swift
func attachMusicDigging(seedTrack: Track) {
    let musicDiggingRouter = self.musicDiggingBuilder.build(
        withListener: self.interactor,
        seedTrack: seedTrack
    )
    self.attachChild(musicDiggingRouter)

    let viewController = musicDiggingRouter.viewControllable.uiViewController
    self.childRoutersByViewControllerID[ObjectIdentifier(viewController)] = musicDiggingRouter
    self.navigationController.pushViewController(viewController, animated: true)
}
```

</details>

#### ✅ 결과

Interactor의 navigation API 의존 제거. Router는 child RIB lifecycle과 화면 stack 정합성만 책임.

---

### 3. 🔎 Debounce와 Task 취소로 검색 요청 제어

#### 🎯 목적

검색창 입력 중 불필요한 API 호출 감소. 이전 요청이 늦게 끝나도 최신 검색 결과만 화면 반영.

#### 🔧 구현

Combine의 `removeDuplicates`, `debounce`로 입력 스트림 제어. 새 검색 시작 시 기존 검색 Task와 페이지네이션 Task 취소.
Presenter 반영 전 `Task.isCancelled` 확인으로 stale response 차단.

<details>
<summary>💻 코드 예시</summary>

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

```swift
private func performSearch(keyword: String) {
    self.searchTask?.cancel()
    self.loadMoreTask?.cancel()

    self.searchTask = Task { [weak self] in
        guard let self else { return }
        do {
            let result = try await self.searchTracksUseCase.execute(
                query: keyword,
                limit: self.limit,
                page: 1
            )
            guard !Task.isCancelled else { return }
            self.presenter.updateTracks(result.tracks)
        } catch is CancellationError {
            return
        } catch {
            self.presenter.showError("검색 중 오류가 발생했습니다.")
        }
    }
}
```

</details>

#### ✅ 결과

입력 안정 후 검색 실행. 이전 요청의 늦은 응답이 현재 화면 상태를 덮어쓰지 않도록 차단.

---

### 4. ⚡ 트랙 상세 정보 병렬 보강

#### 🎯 목적

검색, 추천, 차트 목록에서 부족한 앨범 이미지와 상세 메타데이터 보강.

#### 🔧 구현

`TrackEnrichmentService`로 상세 정보 보강 책임 분리.
최대 동시 요청 수를 제한한 `TaskGroup`으로 트랙 정보 병렬 조회. 개별 실패는 원본 트랙 유지로 fallback.

<details>
<summary>💻 코드 예시</summary>

```swift
protocol TrackEnrichmentService {
    func enrich(_ tracks: [Track]) async -> [Track]
}

final class TrackEnrichmentServiceImpl: TrackEnrichmentService {
    func enrich(_ tracks: [Track]) async -> [Track] {
        guard !tracks.isEmpty else { return [] }

        var updatedTracks = tracks
        await withTaskGroup(of: (Int, Track?).self) { group in
            // maxConcurrentInfoRequests만큼 요청을 흘려보내고, 실패한 트랙은 nil로 반환
        }

        return updatedTracks
    }
}
```

</details>

#### ✅ 결과

목록 로딩 속도 유지. 상세 정보 실패가 전체 UI 실패로 번지지 않도록 보장.

---

### 5. 🎧 외부 음악 앱 연결

#### 🎯 목적

추천 곡, 유사 곡, 차트 곡 선택 시 Spotify 앱 또는 웹 연결.

#### 🔧 구현

Interactor에서 `FetchMusicAppDeepLinkUseCase`로 deep link URL 비동기 조회. URL 준비 후 메인 액터에서 `UIApplication.shared.open` 호출.

<details>
<summary>💻 코드 예시</summary>

```swift
private func openMusicApp(for track: Track) {
    Task {
        guard let url = await self.fetchMusicAppDeepLinkUseCase.execute(track: track) else { return }
        await MainActor.run {
            UIApplication.shared.open(url)
        }
    }
}
```

</details>

#### ✅ 결과

화면 계층의 Spotify API 응답 구조 의존 제거. 외부 앱 연결 흐름은 use case와 repository 뒤로 은닉.

---

### 6. ✨ 포디움과 리스트 Crossfade 전환

#### 🎯 목적

차트 화면 초반 포디움 강조. 스크롤 시 리스트가 자연스럽게 올라오는 전환 효과 구현.

#### 🔧 구현

스크롤 offset 기준 `progress` 계산. Podium section과 list section에 서로 다른 `alpha`, `transform` 적용.

<details>
<summary>💻 코드 예시</summary>

```swift
private func calculateScrollProgress() -> CGFloat {
    let fadeDistance = min(max(self.collectionView.bounds.height * 0.22, 120), 180)
    guard fadeDistance > 0 else { return 0 }
    let offsetY = max(0, self.collectionView.contentOffset.y)
    return max(0, min(1, offsetY / fadeDistance))
}

private func applyCrossfadeEffects() {
    let progress = self.calculateScrollProgress()

    for cell in self.collectionView.visibleCells {
        guard let indexPath = self.collectionView.indexPath(for: cell) else { continue }
        self.applyEffect(to: cell, at: indexPath, progress: progress)
    }
}
```

</details>

#### ✅ 결과

차트 첫 화면의 시각적 강조 유지. 스크롤 이후 리스트 탐색으로 자연스럽게 연결.

---

## 🧪 테스트

Repository, UseCase, RIB 단위 테스트 중심 구성.

- `Builder` 테스트 — `build()` 결과 타입, listener wiring, dependency 주입 검증
- `Interactor` 테스트 — presenter spy와 use case mock으로 loading, update, error, pagination 흐름 검증
- `Router` 테스트 — `interactor.router === router`, child attach/detach, navigation push 동작 검증
- Test helper — feature별 `TestDoubles`와 core mock 분리 후 재사용

<details>
<summary>💻 Builder 테스트 예시</summary>

```swift
let builder = TrackSearchBuilder(dependency: dependency)
let routing = builder.build(withListener: listener, navigationController: navigationController)

#expect(routing is TrackSearchRouter)
guard let router = routing as? TrackSearchRouter else { return }
guard let interactor = router.interactor as? TrackSearchInteractor else { return }
guard let viewController = router.viewControllable as? TrackSearchViewController else { return }

#expect(interactor.listener === listener)
#expect(viewController.listener === interactor)
```

</details>

<details>
<summary>💻 Interactor 테스트 예시</summary>

```swift
let interactor = TrackSearchInteractor(
    presenter: presenter,
    debounceSeconds: 0.01,
    searchTracksUseCase: mockUseCase
)

interactor.didUpdateSearchText("Muse")
await waitUntil {
    mockUseCase.executeCallCount == 1 &&
    presenter.loadingStates == [true, false] &&
    presenter.updatedTracksHistory.last?.count == 2
}
```

</details>

<details>
<summary>💻 Router 테스트 예시</summary>

```swift
router.load()
router.attachMusicDigging(seedTrack: seedTrack)

#expect(router.children.count == 1)
#expect(navigationController.viewControllers.count == 2)
#expect(navigationController.topViewController === childRouter.viewControllable.uiViewController)
```

</details>

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
