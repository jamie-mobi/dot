//
//  DesignTokenTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import OpalDesign
import Testing

@Suite("Design tokens")
struct DesignTokenTests {
    @Test("spacing grows with every step")
    func spacingScale() {
        let steps = [AppSpacing.tiny, AppSpacing.xsmall, AppSpacing.compact, AppSpacing.small, AppSpacing.medium, AppSpacing.comfortable, AppSpacing.regular, AppSpacing.spacious, AppSpacing.large, AppSpacing.wide, AppSpacing.editorMargin]
        #expect(steps == steps.sorted())
        #expect(Set(steps).count == steps.count)
    }

    @Test("radii are on the scale")
    func radii() {
        let steps = [AppRadius.row, AppRadius.panel, AppRadius.field, AppRadius.inner, AppRadius.card, AppRadius.sidebar, AppRadius.popover, AppRadius.window, AppRadius.pill]
        #expect(steps == steps.sorted())
        #expect(AppRadius.control == AppRadius.panel)
    }

    @Test("opacities stay between 0 and 1 and keep their order")
    func opacities() {
        let values = [AppOpacity.cardShadow, AppOpacity.callout, AppOpacity.accentSoft, AppOpacity.tag, AppOpacity.searchMatch, AppOpacity.highlight, AppOpacity.disabled, AppOpacity.unresolved, AppOpacity.subdued, AppOpacity.emphasized]
        #expect(values == values.sorted())
        #expect(values.allSatisfy { $0 > 0 && $0 < 1 })
    }

    @Test("motion durations are short and ordered")
    func motion() {
        #expect(AppMotion.quick < AppMotion.standard)
        #expect(AppMotion.dismissDelay < AppMotion.standard)
    }

    @Test("the pane minimum fits two panes in the default window")
    func paneMinimum() {
        #expect(EditorMetrics.paneMinWidth * 2 < EditorMetrics.windowDefaultWidth)
    }

    @Test("two panes fit at the minimum, with room to drag, beside the sidebar and Inspector at their ideal widths in the default window")
    func splitFitsDefaultWindow() {
        let column = EditorMetrics.windowDefaultWidth - EditorMetrics.sidebarIdealWidth - EditorMetrics.inspectorIdealWidth
        let room = column - EditorMetrics.dividerThickness - EditorMetrics.paneMinWidth * 2
        #expect(room >= EditorMetrics.dividerStep * column)
    }

    @Test("headings shrink with their level and clamp outside 1 to 6")
    func headingScale() {
        let scales = (1 ... 6).map { EditorMetrics.headingScale(level: $0) }
        #expect(scales == scales.sorted(by: >))
        #expect(EditorMetrics.headingScale(level: 0) == scales[0])
        #expect(EditorMetrics.headingScale(level: 9) == scales[5])
        #expect(scales[5] == 1)
        let reading = (1 ... 6).map { EditorMetrics.readingHeadingScale(level: $0) }
        #expect(reading == reading.sorted(by: >))
        #expect(reading[5] == 1)
    }

    @Test("the type scale gives the redesign's sizes at the default size")
    func typeScale() {
        let size = EditorMetrics.fontSize
        #expect(size == 16)
        #expect((size * EditorMetrics.headingScale(level: 1)).rounded() == 30)
        #expect((size * EditorMetrics.headingScale(level: 2)).rounded() == 20)
        #expect((size * EditorMetrics.readingScale).rounded() == 17)
        #expect((size * EditorMetrics.readingScale * EditorMetrics.readingHeadingScale(level: 1)).rounded() == 36)
        #expect((size * EditorMetrics.readingScale * EditorMetrics.readingHeadingScale(level: 2)).rounded() == 22)
        #expect((size * EditorMetrics.readingScale * EditorMetrics.readingLineHeightRatio).rounded() == 29)
    }
}
