//
//  FrequencyLinesView.swift
//  TestGridPath
//
//  Created by Douglas Adams on 3/22/23.
//

import SwiftUI

struct FrequencyLinesView: View {
  let center: CGFloat
  let bandWidth: CGFloat
  let spacing: CGFloat
  let width: CGFloat
  let height: CGFloat
  let color: Color

  var offset: CGFloat { -(center - bandWidth/2).truncatingRemainder(dividingBy: spacing) }
  var low: CGFloat { center - bandWidth/2 }
  var high: CGFloat { center + bandWidth/2 }
  var pixelPerHz: CGFloat { width / (high - low) }

  var body: some View {
    Path { path in
      var x: CGFloat = offset * pixelPerHz
      repeat {
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: height))
        x += pixelPerHz * spacing
      } while x < width
    }
    .stroke(color, lineWidth: 1)
  }
}


struct FrequencyLinesView_Previews: PreviewProvider {
    static var previews: some View {
      FrequencyLinesView(center: 14_100_000,
                         bandWidth: 200_000,
                         spacing: 20_000,
                         width: 800,
                         height: 600,
                         color: .white)
    }
}
