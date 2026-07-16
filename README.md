# MusicSearch

음악 검색, 차트, 날씨 기반 추천 기능이 포함된 iOS 애플리케이션.

---

## 🧾 목차

- [📱 실행 화면](#-실행-화면)
- [✨ 주요 기능](#-주요-기능)
- [📂 아키텍처 및 폴더 구조](#-아키텍처-및-폴더-구조)
- [🛠 기술 스택](#-기술-스택)
- [🚀 주요 구현](#-주요-구현)

---

## 📱 실행 화면

| Weather | Search | Chart |
| :---: | :---: |:---: |
| <img src="https://github.com/user-attachments/assets/72dc3c6c-7321-427a-88e1-de0bd4669aa3" width="150" alt="Home" /> | <img src="https://github.com/user-attachments/assets/03e122f6-c892-4715-9211-b5bb99b70559" width="150" alt="Search" /> | <img src="https://github.com/user-attachments/assets/71496392-0bd3-443c-98e3-8d227843b7b6" width="150" alt="Chart" /> |
| [아카이브 GIF 삽입] | [데모 앱 시나리오 갤러리 GIF URL 삽입] | |

---

## ✨ 주요 기능

| 구분 | 기능 |
| --- | --- |
| **음악 검색** | Spotify API 연동 트랙 검색. 무한 스크롤, 디바운스 적용 |
| **보관함 (Archive)** | 트랙 폴더화 저장 (SwiftData). 저장 트랙 Spotify 플레이리스트 내보내기 지원 |
| **음악 디깅** | 선택 트랙과 유사한 곡을 Child RIB으로 연속 탐색 |
| **날씨 추천** | 현재 위치 날씨 데이터 기반 추천 음악 태그 추출 및 트랙 표시 |
| **차트** | 트랙 및 아티스트 차트 제공 |
| **데모 앱** | 11개 피처 모듈별 독립 Example 앱 탑재. Mock 기반 상태 검증(DemoListViewController) |

---

## 📂 아키텍처 및 폴더 구조

Tuist Workspace 기반 3계층(App, Core, Features) 분리 구조.

```text
MusicSearch.xcworkspace
├── MusicSearch/App                           # 진입점(Root RIB) 및 리소스
├── MusicSearch/Core                          # 공통 Data, Domain, DesignSystem
└── MusicSearch/Features                      # 비즈니스 로직 단위 피처 모듈
    ├── Archive (TCA)
    ├── Chart (RIBs)
    ├── MusicDigging (RIBs)
    ├── Settings (RIBs)
    ├── TrackSearch (RIBs)
    └── WeatherRecommendation (RIBs)
```

### Micro-Feature 분할
각 피처 모듈은 5개 타겟으로 분리.
- `Interface`: 프로토콜(Dependency) 정의
- `Implementation`: 로직 및 UI 구현체
- `Testing`: Mock 객체 모음
- `Tests`: 단위 테스트
- `Example`: 독립 데모 앱

---

## 🛠 기술 스택

| Category | Stack |
| --- | --- |
| **Language** | Swift |
| **Architecture** | TMA(Tuist Micro-Feature Architecture), MicroRIBs, TCA |
| **Build System** | Tuist |
| **Concurrency** | Swift Concurrency (`async`/`await`) |
| **Local DB** | SwiftData |
| **UI Design** | SwiftUI, UIKit |
| **Networking** | URLSession 기반 커스텀 NetworkLayer |
| **Testing/Demo** | XCTest, TCA TestStore, Mock 주입 Demo 앱 |
| **Open API** | Spotify API, OpenWeatherMap |

---

## 🚀 주요 구현

### 1. 피처 모듈화 및 증분 빌드
Tuist 도입. 각 피처의 통신 규격을 `Interface` 모듈로 분리. 타겟 간 결합도 축소 및 증분 빌드 속도 개선.

### 2. 아키텍처 혼용 (RIBs + TCA)
화면 라우팅 및 생명주기 관리는 `RIBs` 사용. 전역 상태 공유가 필요한 `Archive` 피처는 `TCA` 사용.

### 3. 고립 UI 테스트 환경 (Scenario Gallery)
각 피처의 `Example` 앱에 시나리오 갤러리 패턴 도입. `Testing` 모듈의 Mock 객체를 주입하여 네트워크 연결 없이 UI 상태(성공, 실패, 로딩) 검증.

### 4. 동시성 제어 및 NetworkLayer
비동기 처리에 `Swift Concurrency` 채택. Spotify OAuth 토큰 만료 시 재발급 플로우에서 동시 API 요청 큐잉(Queueing) 및 중복 갱신(Reentrancy) 방지 로직 구현.
