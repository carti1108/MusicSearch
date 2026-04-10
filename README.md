# MusicSearch 🎵

**MusicSearch**는 사용자가 음악을 검색하고, 차트를 확인하며, 현재 날씨에 어울리는 추천 음악을 받을 수 있는 iOS 애플리케이션.

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
├── Docs
│   ├── Execution       # 실행 화면 및 문서 리소스
│   └── RIBs-Guide.md   # RIBs 구조 가이드
├── MusicSearch
│   ├── App
│   │   ├── Resources   # Assets, Info.plist
│   │   └── Sources     # SceneDelegate, Root RIB
│   ├── Core
│   │   ├── Domain      # UseCases, Entities, Interfaces
│   │   ├── Data        # Repositories, DTOs, Network
│   │   └── Util        # Extensions, Constants
│   └── Features
│       ├── Digging     # Search RIB, MusicDigging RIB
│       ├── Home        # Home RIB
│       └── Trend       # Trend RIB
├── MusicSearchTests
├── MusicSearchUITests
└── MusicSearch.xcodeproj
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

## 🧭 Architecture Guide

- [RIBs 가이드](./Docs/RIBs-Guide.md)

---

## 🚀 주요 구현 및 트러블 슈팅

### 주요 구현

### 1. Debounce로 검색 API 호출 최적화

#### 목적
사용자가 검색창에 입력하는 동안 모든 중간 문자열에 대해 API를 호출하지 않고, 입력이 잠시 멈췄을 때만 검색이 실행되도록 구성.

#### 구현
Combine의 `removeDuplicates`와 `debounce`를 사용해 일정 시간 동안 입력이 멈췄을 때만 실제 검색 로직이 실행되도록 구성.

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

### 2. Task 취소로 Stale Response 방지

#### 목적
이전 검색이나 페이지네이션 요청이 늦게 끝나더라도, 가장 최근 요청의 결과만 화면에 반영되도록 구성.

#### 구현
새로운 검색이 시작될 때 이전 `Task`를 취소하고, 응답 반영 전에 `Task.isCancelled`를 확인하도록 구성.

**TrackSearchInteractor.swift**
```swift
private var searchTask: Task<Void, Never>?
private var loadMoreTask: Task<Void, Never>?

private func performSearch(keyword: String) {
    self.searchTask?.cancel()
    self.loadMoreTask?.cancel()

    self.searchTask = Task { [weak self] in
        guard let self else { return }
        do {
            let result = try await self.searchTracksUseCase.execute(...)
            guard !Task.isCancelled else { return }

            self.presenter.updateTracks(result.tracks)
        } catch is CancellationError {
            return
        }
    }
}
```

### 3. 딥링크로 외부 음악 앱 연결

#### 목적
추천 곡이나 차트 곡을 눌렀을 때 Spotify로 바로 이어지는 딥링크 동작 구현.

#### 구현
딥링크 URL 조회를 비동기로 수행한 뒤, URL이 준비되면 메인 스레드에서 `UIApplication.shared.open`을 호출하도록 구성.

**HomeInteractor.swift**
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

### 4. 포디움 → 리스트 전환을 Crossfade로 구현

#### 목적
차트 화면에서 처음에는 포디움만 강조되어 보이고, 스크롤 시 포디움은 서서히 사라지며 리스트가 아래에서 자연스럽게 올라오는 전환 구현.

#### 구현
스크롤 진행률(`progress`)을 계산한 뒤, 포디움과 리스트 섹션에 서로 다른 `alpha`와 `transform`을 적용해 crossfade와 parallax를 함께 구성.

**ChartViewController.swift**
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

### 트러블 슈팅

### 1. Spacer View로 셀 내부 여백 안정화

#### 문제
`TrackCarouselCell`에서 곡 제목이 1줄일 때, 이미지와 텍스트 사이 간격이 과하게 벌어져 카드 내부 균형이 무너지는 문제 발생.

#### 원인
`UIStackView`를 `distribution = .equalSpacing`으로 두면 남는 높이가 요소들 사이에 균등하게 분배되어, 콘텐츠 길이에 따라 spacing이 달라졌기 때문.

#### 구현
스택뷰를 `distribution = .fill`로 바꾸고, 마지막 arranged subview로 `spacerView`를 추가해 남는 공간을 맨 아래에서만 흡수하도록 구성함.

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
텍스트가 1줄이든 2줄이든 이미지-제목-아티스트 간 spacing은 일정하게 유지되고, 남는 공간은 `spacerView`가 흡수하도록 정리됨.

### 2. 첫 스크롤 시 셀 깜빡임 방지

#### 문제
Crossfade를 적용한 뒤 첫 스크롤이나 bounce 순간에 리스트 셀이 잠깐 번쩍이며 나타나는 현상이 있었고, 이후 스크롤은 비교적 자연스럽게 동작.

#### 원인
첫 스크롤 시점에는 셀 재사용, 레이아웃 갱신, 초기 상태 적용이 겹치기 쉬웠고, `UICollectionViewCell` 자체 속성을 직접 조작하면 레이아웃 엔진의 기본 속성 초기화와 충돌할 가능성이 있음.

#### 구현
`willDisplay`에서 새로 나타나는 셀에도 현재 progress 상태를 즉시 적용하고, 초기 진입 전에 한 번 `layoutIfNeeded()` 후 crossfade 상태를 미리 고정함.  
또한 애니메이션 타겟을 `cell`이 아니라 `cell.contentView`로 옮겨 레이아웃 속성 초기화와의 충돌을 줄임.

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

#### 결과
첫 스크롤에서 셀이 갑자기 번쩍이거나 기본 상태로 돌아가는 현상이 줄어들었고, 초기 전환의 일관성을 더 높일 수 있었음.
