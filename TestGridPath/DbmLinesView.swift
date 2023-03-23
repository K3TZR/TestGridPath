//
//  DbmLinesView.swift
//  TestGridPath
//
//  Created by Douglas Adams on 3/22/23.
//

import SwiftUI

struct DbmLinesView: View {
  let high: CGFloat
  let low: CGFloat
  let spacing: CGFloat
  let width: CGFloat
  let height: CGFloat
  let color: Color

  var pixelPerDbm: CGFloat { height / (high - low) }
  var offset: CGFloat { high.truncatingRemainder(dividingBy: spacing) }

  var body: some View {
    Path { path in
      var y: CGFloat = offset * pixelPerDbm
      repeat {
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: width, y: y))
        y += pixelPerDbm * spacing
      } while y < height
    }
    .stroke(color, lineWidth: 1)
  }
}

struct DbmLinesView_Previews: PreviewProvider {
    static var previews: some View {
      DbmLinesView(high: 10,
                   low: -100,
                   spacing: 10,
                   width: 800,
                   height: 600,
                   color: .gray)
    }
}
