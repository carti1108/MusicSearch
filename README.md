# MusicSearch 🎵

**MusicSearch** — 음악 검색·차트·날씨 기반 추천 iOS 앱.

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
│   ├── Resources                   # Assets, Info.plist
│   └── Sources                     # AppDelegate, SceneDelegate, AppComponent, AppRoot
├── Core
│   ├── Domain                      # UseCases, Entities, Interfaces
│   ├── Data                        # Repositories, DTOs, Network
│   ├── DependencyInjection         # Component, Dependency 프로토콜
│   ├── Presentation                # Common UI Protocols (MusicAppRouting)
│   └── Util                        # Extensions, ReuseIdentifiable, ErrorPresentable
└── Features
    ├── Digging                     # 트랙 검색 및 유사 트랙 탐색 Feature
    ├── Home                        # 날씨 기반 음악 추천 Feature
    └── Trend                       # 차트 Feature
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
| **Networking** | 자체 SPM 모듈 NetworkLayer(URLSession 기반) |
| **UI** | Compositional Layout, DiffableDataSource, Auto Layout |
| **Open API** | Spotify, Last.fm, OpenWeatherMap |

---

## 🚀 기술 구현 (Implementation)

### 1. 아키텍처

#### Clean Architecture
- **Core/Domain** — `UseCase`, `Entity`, `Repository Interface`. 비즈니스 규칙이 UIKit·네트워크 구현에 직접 의존하지 않도록 분리.
- **Core/Data** — 외부 API 응답을 DTO로 수신 후 Domain Entity로 변환. 저장/조회는 Repository 구현체가 담당.
- **Features** — 데이터 요청은 UseCase 경로만 사용. ViewModel은 API 스펙·DTO 구조를 몰라도 됨.

```swift
// FetchMusicForWeatherUseCaseImpl.swift
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

```swift
// TrackRepositoryImpl.swift
func searchTracks(
    query: String,
    limit: Int,
    page: Int
) async throws -> (tracks: [Track], totalResults: Int) {
    self.makeSearchResult(from: try await self.networkManager.perform(
        with: LastFMAPI.searchTracks(keyword: query, limit: limit, page: page),
        as: TrackSearchResponseDTO.self
    ))
}

private func makeSearchResult(
    from response: TrackSearchResponseDTO
) -> (tracks: [Track], totalResults: Int) {
    (
        tracks: response.results.trackmatches.track.map { $0.toDomain() },
        totalResults: Int(response.results.totalResults) ?? 0
    )
}
```

#### MVVM-C
- ViewController → 사용자 입력은 `Listener`로 전달. ViewModel → 화면 상태 갱신은 `Viewable`.
- ViewModel은 네비게이션 직수행 없음. `CoordinatorAction`에만 의존.
- View / ViewModel / Coordinator 책임 분리 → 테스트 용이·화면 전환 유연.

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

@MainActor
protocol TrackSearchViewCoordinatorAction: AnyObject {
    func didSelect(_ track: Track)
}
```

### 2. 화면 전환 구현

- **AppRoot** — 탭바 구성. 탭마다 독립 Coordinator 시작.
- **TrackSearchViewCoordinator** — 검색 화면을 루트로 세팅. 트랙 선택 시 `MusicDiggingViewCoordinator` push.
- 외부 음악 앱 연결 — `MusicAppRouting`으로 추상화. Coordinator·ViewModel은 URL 구성 세부를 몰라도 됨.

```swift
final class TrackSearchViewCoordinator<T: DiggingDependency>: Coordinator, TrackSearchViewCoordinatorAction {
    private let component: DiggingComponent<T>

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

### 3. 데이터 흐름 및 비동기 처리

- 데이터 경로 — `ViewModel → UseCase → Repository → API/DTO → Domain Entity`.
- 비동기 기본 — `Swift Concurrency(async/await)`. 네트워크·UseCase·Repository 조회·병렬·취소는 `Task`, `TaskGroup`, `actor` 중심.
- **Combine** — 검색어 입력 등 시간에 따라 이어지는 이벤트 스트림만. `debounce`, `removeDuplicates` 등 입력 제어는 UI 계층에만. Domain/Data로는 전파하지 않음.
- 기준 — 단발 요청·단발 응답은 Swift Concurrency, 시간에 따라 흘러오는 값의 가공은 Combine.
- 검색 페이지네이션 — `isLoading`, `isLoadingMore`, `loadingPage`로 중복 요청 방지.
- 트랙 상세 보강 — `withTaskGroup` 병렬. 개별 실패 시에도 전체 실패 없이 원본 유지.

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

```swift
// Array+TrackInfo.swift
extension Array where Element == Track {
    func enrichingTrackInfo(
        maxConcurrentRequests: Int = 8,
        using fetchTrackInfo: @escaping @Sendable (Track) async throws -> Track
    ) async -> [Track] {
        // ... withTaskGroup 병렬 처리 코드 캡슐화 ...
    }
}

// FetchChartTopTracksUseCaseImpl.swift
func execute() async throws -> [Track] {
    let tracks = try await self.chartRepository.fetchTopTracks()
    return await tracks.enrichingTrackInfo(using: self.chartRepository.fetchTrackInfo(for:))
}
```

### 4. 에러 핸들링 및 비동기 규칙

- 동기 작업 중 발생하는 에러는 `throws`를 사용.
- 비동기 작업 중 발생하는 에러는 `async throws`를 사용.
- `Result`는 성공/실패 상태를 저장하거나 전달해야 할 때만 사용.
- UI 계층에서는 화면 복잡도에 따라 `Result`, `Optional`, 상태 프로퍼티 중 가장 단순한 형태를 선택.

### 5. 의존성 주입

- 외부 DI 프레임워크 없음. `Component` / `Dependency` 프로토콜 조합으로 조립.
- **AppComponent** — 앱 공통 의존성 소유. Feature Component는 필요한 UseCase만 받아 ViewModel·Coordinator 생성.
- 테스트 — mock use case / repository 주입 용이.

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

### 6. 테스팅

- 단위 테스트 — `Repository`, `UseCase`, `ViewModel` 중심. 비즈니스 로직·상태 전이 우선.
- **MusicSearchTests/TestSupport** — `MockRepositories`, `MockUseCases`, `ViewSpies`, `AsyncTestHelper`, `TestDataFactory`로 테스트 더블 공용화.
- ViewModel 테스트 — loading, error, update, pagination, retry, selection 등 상태 전이. UseCase 테스트 — 성공/실패 전파·fallback.

```swift
@MainActor
final class SpyTrackSearchView: TrackSearchViewable {
    var listener: TrackSearchViewableListener?
    var updatedTracksHistory: [[Track]] = []
    var loadingStates: [Bool] = []
    var errorMessages: [String?] = []

    func updateTracks(_ tracks: [Track]) {
        self.updatedTracksHistory.append(tracks)
    }

    func showLoading(_ isShow: Bool) {
        self.loadingStates.append(isShow)
    }

    func showError(_ message: String?) {
        self.errorMessages.append(message)
    }
}
```

```swift
@MainActor
struct TrackSearchViewModelTests {
    @Test("트랙 검색 뷰모델이 더 불러오기가 가능할 때 다음 페이지를 이어붙이는지 확인")
    func given_다음페이지가존재할때_didReachListBottom하면_다음페이지결과를이어붙이는지() async throws {
        // given
        // when
        // then
    }
}
```

---

## 🔧 트러블 슈팅 (Troubleshooting)

### 1. Spacer View로 셀 내부 여백 안정화

#### 문제
`TrackCarouselCell`에서 곡 제목이 1줄일 때, 이미지와 텍스트 사이 간격이 과하게 벌어져 카드 내부 균형이 무너지는 문제 발생.

#### 원인
`UIStackView`를 `distribution = .equalSpacing`으로 두면 남는 높이가 요소들 사이에 균등하게 분배되어, 콘텐츠 길이에 따라 spacing이 달라졌기 때문.

#### 구현
스택뷰 `distribution = .fill`. 마지막 arranged subview로 `spacerView` 추가 — 잉여 공간은 하단에서만 흡수.

**TrackCarouselCell.swift**
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

private func setupUI() {
    self.contentView.addSubview(self.cardView)
    self.cardView.addSubview(self.mainStackView)

    self.mainStackView.addArrangedSubview(self.albumImageView)
    self.mainStackView.addArrangedSubview(self.titleLabel)
    self.mainStackView.addArrangedSubview(self.artistLabel)
    self.mainStackView.addArrangedSubview(self.spacerView)
}
```

#### 결과
1줄·2줄 모두 이미지–제목–아티스트 spacing 일정. 잉여는 `spacerView`가 흡수.

### 2. 첫 스크롤 시 셀 깜빡임 방지

#### 문제
Crossfade 적용 후 첫 스크롤·bounce 순간 리스트 셀 번쩍임. 이후 스크롤은 상대적으로 자연스러움.

#### 원인
첫 스크롤 시점에는 셀 재사용, 레이아웃 갱신, 초기 상태 적용이 겹치기 쉬웠고, `UICollectionViewCell` 자체 속성을 직접 조작하면 레이아웃 엔진의 기본 속성 초기화와 충돌할 가능성이 있음.

#### 구현
`willDisplay` — 신규 셀에도 현재 progress 즉시 적용. 초기 진입 전 `layoutIfNeeded()` 한 번 후 crossfade 상태 고정.  
애니메이션 타겟 — `cell`이 아닌 `cell.contentView`로 이동. 레이아웃 속성 초기화와의 충돌 완화.

**ChartViewController.swift**
```swift
func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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

func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.primeInitialCrossfadeIfNeeded(force: true)
}
```

```swift
private func applyEffect(to cell: UICollectionViewCell, at indexPath: IndexPath, progress: CGFloat) {
    let offsetY = max(0, self.collectionView.contentOffset.y)

    if indexPath.section == Section.podium.rawValue {
        let alpha = 1.0 - progress
        let transformY = offsetY > 0 ? offsetY * 0.45 : 0
        cell.contentView.alpha = alpha
        cell.contentView.transform = CGAffineTransform(translationX: 0, y: transformY)
    } else if indexPath.section == Section.list.rawValue {
        let alpha = progress
        let transformY = 36 * (1.0 - progress)
        cell.contentView.alpha = alpha
        cell.contentView.transform = CGAffineTransform(translationX: 0, y: transformY)
    }
}
```

#### 결과
첫 스크롤 시 번쩍임·기본 상태 복귀 감소. 초기 전환 일관성 개선.
