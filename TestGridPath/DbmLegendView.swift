//
//  DbmLegendView.swift
//  TestGridPath
//
//  Created by Douglas Adams on 3/22/23.
//

import SwiftUI

struct DbmLegendView: View {
  @Binding var high: CGFloat
  @Binding var low: CGFloat
  @Binding var spacing: CGFloat
  let width: CGFloat
  let height: CGFloat
  let color: Color
  
  var pixelPerDbm: CGFloat { height / (high - low) }
  var offset: CGFloat { high.truncatingRemainder(dividingBy: spacing) }
  
  @State var startHigh: CGFloat?
  @State var startLow: CGFloat?
  
  var legends: [CGFloat] {
    var array = [CGFloat]()
    
    var currentDbm = high
    repeat {
      array.append( currentDbm )
      currentDbm -= spacing
    } while ( currentDbm >= low )
    return array
  }
  
  var body: some View {
    
    ZStack(alignment: .trailing) {
      ForEach(Array(legends.enumerated()), id: \.offset) { i, value in
        if value > low {
          Text(String(format: "%0.0f", value - offset))
            .position(x: width - 20, y: (offset + CGFloat(i) * spacing) * pixelPerDbm)
            .foregroundColor(color)
        }
      }
      
      Rectangle()
        .frame(width: 40).border(.red)
        .foregroundColor(.white).opacity(0.1)
        .gesture(
          DragGesture()
            .onChanged {value in
              switch value.startLocation.y {
                // Top 1/3 of legend, drag Top value
              case 0..<height/3:
                if let startHigh {
                  DispatchQueue.main.async { high = startHigh - ((value.startLocation.y - value.location.y)/pixelPerDbm) }
                } else {
                  startHigh = high
                }
                // Bottom 1/3 of legend, drag Bottom value
              case 2*(height/3)...height:
                if let startLow {
                  DispatchQueue.main.async { low = startLow - ((value.startLocation.y - value.location.y)/pixelPerDbm) }
                } else {
                  startLow = low
                }
                // Center of legend, drag range of values (Top & Bottom)
              default:
                if let startHigh, let startLow {
                  DispatchQueue.main.async { [value] in
                    high = startHigh - ((value.startLocation.y - value.location.y)/pixelPerDbm)
                    low = startLow - ((value.startLocation.y - value.location.y)/pixelPerDbm)
                  }
                } else {
                  startLow = low
                  startHigh = high
                }
              }
            }
            .onEnded { _ in
              startHigh = nil
              startLow = nil
            }
        )
        .contextMenu {
          Button { spacing = 5 } label: {Text("5 dbm")}
          Button { spacing = 10 } label: {Text("10 dbm")}
          Button { spacing = 15 } label: {Text("15 dbm")}
          Button { spacing = 20 } label: {Text("20 dbm")}
        }
    }
  }
}

struct DbmLegendView_Previews: PreviewProvider {
  static var previews: some View {
    DbmLegendView(high: .constant(10),
                  low: .constant(-100),
                  spacing: .constant(10),
                  width: 800,
                  height: 600,
                  color: .white)
  }
}
