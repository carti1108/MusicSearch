//
//  ArchiveFilterSheetView.swift
//  MusicSearch
//
//  Created by Kiseok on 7/16/26.
//

import SwiftUI

public struct ArchiveFilterSheetView: View {
    @Binding var filterIntroGood: Bool
    @Binding var filterMiddleGood: Bool
    @Binding var filterEndGood: Bool
    @Binding var showFilterSheet: Bool

    public init(
        filterIntroGood: Binding<Bool>,
        filterMiddleGood: Binding<Bool>,
        filterEndGood: Binding<Bool>,
        showFilterSheet: Binding<Bool>
    ) {
        self._filterIntroGood = filterIntroGood
        self._filterMiddleGood = filterMiddleGood
        self._filterEndGood = filterEndGood
        self._showFilterSheet = showFilterSheet
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("곡 전개 평가 필터")) {
                    Toggle("인트로가 좋음", isOn: $filterIntroGood)
                    Toggle("중반부까지 좋음", isOn: $filterMiddleGood)
                    Toggle("끝까지 좋음", isOn: $filterEndGood)
                }

                Button(action: {
                    filterIntroGood = false
                    filterMiddleGood = false
                    filterEndGood = false
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
                        showFilterSheet = false
                    }
                }
            }
        }
    }
}
