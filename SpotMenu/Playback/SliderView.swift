import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let foregroundColor: Color
    let trackColor: Color

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
                    .animation(.easeInOut(duration: 0.15), value: value)
            }
            .frame(height: thumbSize)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let location = drag.location.x - thumbSize / 2
                        let clampedX = min(
                            max(0, location),
                            availableWidth
                        )
                        let relative = clampedX / availableWidth
                        let newValue =
                            range.lowerBound
                            + (range.upperBound - range.lowerBound)
                            * Double(relative)
                        withAnimation(.easeInOut(duration: 0.15)) {
                            value = newValue
                        }
                    }
            )
        }
        .frame(height: thumbSize)
    }

    private func progressWidth(in availableWidth: CGFloat) -> CGFloat {
        let clampedValue = max(range.lowerBound, min(range.upperBound, value))
        let percent =
            (clampedValue - range.lowerBound)
            / (range.upperBound - range.lowerBound)
        return CGFloat(percent) * availableWidth + thumbSize / 2
    }

    private func thumbOffset(in availableWidth: CGFloat) -> CGFloat {
        progressWidth(in: availableWidth) - thumbSize / 2
    }
}
