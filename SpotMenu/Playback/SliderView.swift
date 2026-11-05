import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let foregroundColor: Color
    let trackColor: Color
    var commitOnEnd = false
    @State private var previewValue: Double?

    private let height: CGFloat = 4
    private let thumbSize: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - thumbSize

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: height)
                    .frame(maxHeight: .infinity, alignment: .center)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(trackColor)
                    .frame(
                        width: progressWidth(in: availableWidth),
                        height: height
                    )
                    .frame(maxHeight: .infinity, alignment: .center)

                Circle()
                    .fill(foregroundColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(
                        x: thumbOffset(in: availableWidth)
                    )
                    .frame(maxHeight: .infinity, alignment: .center)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .animation(.easeInOut(duration: 0.15), value: previewValue ?? value)
            }
            .frame(height: thumbSize)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let newValue = position(at: drag.location.x, width: availableWidth)
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if commitOnEnd { previewValue = newValue } else { value = newValue }
                        }
                    }
                    .onEnded { drag in
                        if commitOnEnd {
                            value = position(at: drag.location.x, width: availableWidth)
                            previewValue = nil
                        }
                    }
            )
        }
        .frame(height: thumbSize)
    }

    private func progressWidth(in availableWidth: CGFloat) -> CGFloat {
        let clampedValue = max(range.lowerBound, min(range.upperBound, previewValue ?? value))
        let percent =
            (clampedValue - range.lowerBound)
            / (range.upperBound - range.lowerBound)
        return CGFloat(percent) * availableWidth + thumbSize / 2
    }

    private func thumbOffset(in availableWidth: CGFloat) -> CGFloat {
        progressWidth(in: availableWidth) - thumbSize / 2
    }

    private func position(at location: CGFloat, width: CGFloat) -> Double {
        guard width > 0 else { return range.lowerBound }
        let relative = min(max(0, location - thumbSize / 2), width) / width
        return range.lowerBound + (range.upperBound - range.lowerBound) * Double(relative)
    }
}
