//
//  ArchiveFilterSheetView.swift
//  MusicSearch
//
//  Created by Kiseok on 7/16/26.
//

import SwiftUI
import ComposableArchitecture

public struct ArchiveFilterSheetView: View {
    @Bindable var store: StoreOf<ArchiveFeature>

    public init(store: StoreOf<ArchiveFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("곡 전개 평가 필터")) {
                    Toggle("인트로가 좋음", isOn: $store.filterIntroGood)
                    Toggle("중반부까지 좋음", isOn: $store.filterMiddleGood)
                    Toggle("끝까지 좋음", isOn: $store.filterEndGood)
                }

                Button(action: {
                    store.send(.resetFilter)
                }) {
                    Text("필터 초기화")
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("필터")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        store.showFilterSheet = false
                    }
                }
            }
        }
    }
}
