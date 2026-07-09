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

| Weather | Search | Chart |
| :---: | :---: |:---: |
| <img src="https://github.com/user-attachments/assets/72dc3c6c-7321-427a-88e1-de0bd4669aa3" width="150" alt="Home" /> | <img src="https://github.com/user-attachments/assets/03e122f6-c892-4715-9211-b5bb99b70559" width="150" alt="Search" /> | <img src="https://github.com/user-attachments/assets/71496392-0bd3-443c-98e3-8d227843b7b6" width="150" alt="Chart" /> |

---

## ✨ 주요 기능

| 구분 | 기능 |
| --- | --- |
| **보관함 (Archive)** | 관심 있는 트랙을 커스텀 폴더에 묶어 저장 및 관리 (SwiftData 오프라인 로컬 DB 연동) |
| **Spotify 내보내기** | 보관함에 저장된 트랙들을 실제 Spotify 플레이리스트로 일괄 내보내기 (OAuth 연동) |
| **날씨 추천** | 사용자의 현재 위치 날씨 데이터를 기반으로 어울리는 음악 태그를 추출하여 트랙 추천 |
| **음악 검색** | Last.fm API 기반 트랙 검색, Debounce 최적화 및 무한 스크롤 페이지네이션 |
| **음악 디깅** | 선택한 트랙과 유사한 곡들을 Child RIB을 통해 꼬리를 무는 방식(Digging)으로 연속 탐색 |
| **차트** | 인기 트랙과 아티스트 차트를 시각적인 Podium 및 List UI 형태로 제공 |
| **외부 앱 연결** | Spotify Deep Link 조회를 통해 실제 음악 앱으로 다이렉트 연결 및 재생 지원 |

---

## 📂 폴더 구조

```text
MusicSearch
├── Project.swift                     # Tuist 프로젝트 설정 파일
├── Tuist                             # Tuist 관련 설정 및 의존성
├── MusicSearch
│   ├── App
│   │   ├── Resources                 # Assets, Info.plist, LaunchScreen
│   │   └── Sources
│   │       └── Root                  # Root RIB, 탭 구성
│   ├── Core
│   │   ├── Data                      # DTOs, Network, Repositories
│   │   ├── Domain                    # Entities, Interfaces, Services, UseCases
│   │   └── Util                      # Extension, Reusable Helper
│   │   └── DesignSystem              # LiquidGlassModifier 등 UI 시스템
│   └── Features
│       ├── Archive                   # (TCA) 보관함, SwiftData, Spotify 내보내기
│       ├── Chart                     # (RIBs) 인기 트랙/아티스트 차트
│       ├── TrackSearch               # (RIBs) 음악 검색 기능
│       ├── MusicDigging              # (RIBs) 유사 트랙 탐색 (Child RIB)
│       └── WeatherRecommendation     # (RIBs) 날씨 기반 음악 추천
├── MusicSearchTests                  # 단위 테스트 (TCA TestStore, RIBs 유닛 테스트 등)
├── Docs                              # 가이드 문서
└── README.md
```

---

## 🛠 기술 스택

| Category | Stack |
| --- | --- |
| **Language** | Swift |
| **Framework** | SwiftUI, UIKit, Auto Layout |
| **Architecture** | TCA (The Composable Architecture), RIBs, Repository Pattern |
| **Build System** | Tuist |
| **Local DB** | SwiftData |
| **Concurrency** | Swift Concurrency (`async`/`await`) |
| **Reactive** | Combine |
| **Networking** | URLSession 기반 `NetworkLayer` 모듈 |
| **UI Design** | Compositional Layout |
| **Error Handling**| OSLog |
| **Open API** | Last.fm, Spotify, OpenWeatherMap |
| **Testing** | Swift Testing, XCTest, TCA TestStore |

---

## 🧭 아키텍처

```text
Root RIB
├── WeatherRecommendation RIB
├── TrackSearch RIB
│   └── MusicDigging RIB
├── Chart RIB
└── Archive Feature (TCA)
```

---

## 🚀 주요 구현

---

## 🐛 트러블슈팅
