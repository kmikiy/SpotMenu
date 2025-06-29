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
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: height)
                    .frame(maxHeight: .infinity, alignment: .center)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(trackColor)
                    .frame(
                        width: progressWidth(in: geometry.size.width),
                        height: height
                    )
                    .frame(maxHeight: .infinity, alignment: .center)

                Circle()
                    .fill(foregroundColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(
                        x: thumbOffset(in: geometry.size.width) - thumbSize / 2
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
                        let clampedX = min(
                            max(0, drag.location.x),
                            geometry.size.width
                        )
                        let relative = clampedX / geometry.size.width
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

    private func progressWidth(in totalWidth: CGFloat) -> CGFloat {
        let clampedValue = max(range.lowerBound, min(range.upperBound, value))
        let percent =
            (clampedValue - range.lowerBound)
            / (range.upperBound - range.lowerBound)
        return CGFloat(percent) * totalWidth
    }

    private func thumbOffset(in totalWidth: CGFloat) -> CGFloat {
        progressWidth(in: totalWidth)
    }
}
