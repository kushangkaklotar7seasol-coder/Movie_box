//
//  MasonryVGrid.swift
//  A reusable, generic Pinterest-style (masonry / waterfall) grid for SwiftUI.
//
//  WHY THIS EXISTS
//  LazyVGrid forces every item in a row to the same height — it can't do
//  variable-height columns. True masonry needs to:
//    1. Measure each card's real rendered height.
//    2. Place each card into whichever column is *currently shortest*.
//  This view does both, using a PreferenceKey to report heights back up
//  and a shortest-column-first packing algorithm to assign items.
//
//  HONEST LIMITATION (read this)
//  On first appearance, real heights aren't known yet, so items are placed
//  using an estimate (200pt by default, or your own `estimatedHeight`
//  closure). Once the real heights come back from the GeometryReader,
//  columns are recalculated — this can cause a brief reflow where an item
//  shifts from one column to another. This is a known, unavoidable
//  trade-off of *any* SwiftUI masonry implementation that doesn't rely on
//  fixed/known heights up front. Passing a good `estimatedHeight` closure
//  (e.g. based on text length) minimizes visible reflow.
//
//  USAGE
//     MasonryVGrid(data: viewModel.allNotes, columns: 2, spacing: 16) { note in
//         NoteCard(note: note)
//     }
//

import SwiftUI

// MARK: - Preference key used to report each item's measured height upward.

private struct MasonryHeightPreferenceKey: PreferenceKey {
    static var defaultValue: [AnyHashable: CGFloat] = [:]
    static func reduce(value: inout [AnyHashable: CGFloat], nextValue: () -> [AnyHashable: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - MasonryVGrid

struct MasonryVGrid<Data: RandomAccessCollection, Content: View>: View
where Data.Element: Identifiable {

    private let data: Data
    private let columns: Int
    private let spacing: CGFloat
    private let estimatedHeight: (Data.Element) -> CGFloat
    private let content: (Data.Element) -> Content

    /// Real measured heights, keyed by item id. Populated after first render.
    @State private var measuredHeights: [AnyHashable: CGFloat] = [:]

    /// - Parameters:
    ///   - data: Any RandomAccessCollection of Identifiable items (arrays work fine).
    ///   - columns: Number of masonry columns. Default 2.
    ///   - spacing: Spacing between items, both horizontally and vertically. Default 16.
    ///   - estimatedHeight: Optional height guess used ONLY before the real height is
    ///     measured, to reduce initial-layout reflow. Default: a flat 200pt for every item.
    ///   - content: Your cell view builder.
    init(
        data: Data,
        columns: Int = 2,
        spacing: CGFloat = 16,
        estimatedHeight: @escaping (Data.Element) -> CGFloat = { _ in 200 },
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.columns = max(1, columns)
        self.spacing = spacing
        self.estimatedHeight = estimatedHeight
        self.content = content
    }

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            ForEach(0..<columns, id: \.self) { columnIndex in
                LazyVStack(spacing: spacing) {
                    ForEach(columnAssignments[columnIndex]) { item in
                        content(item)
                            .background(heightReader(for: item))
                    }
                }
            }
        }
        .onPreferenceChange(MasonryHeightPreferenceKey.self) { heights in
            // Merge rather than overwrite, so already-measured heights from
            // items that scrolled off-screen (and got recycled by LazyVStack)
            // aren't lost.
            measuredHeights.merge(heights) { _, new in new }
        }
        .animation(.easeInOut(duration: 0.2), value: measuredHeights.count)
    }

    /// Invisible GeometryReader placed behind each cell to report its real height
    /// back up via the preference key, without affecting layout itself.
    private func heightReader(for item: Data.Element) -> some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: MasonryHeightPreferenceKey.self,
                    value: [AnyHashable(item.id): proxy.size.height]
                )
        }
    }

    /// Shortest-column-first packing: walk items in order, always dropping the
    /// next item into whichever column currently has the smallest total height.
    private var columnAssignments: [[Data.Element]] {
        var runningHeights = Array(repeating: CGFloat(0), count: columns)
        var result: [[Data.Element]] = Array(repeating: [], count: columns)

        for item in data {
            let height = measuredHeights[AnyHashable(item.id)] ?? estimatedHeight(item)

            // Find index of the shortest column so far.
            var shortestIndex = 0
            for i in 1..<columns where runningHeights[i] < runningHeights[shortestIndex] {
                shortestIndex = i
            }

            result[shortestIndex].append(item)
            runningHeights[shortestIndex] += height + spacing
        }

        return result
    }
}
