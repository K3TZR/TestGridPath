//
//  FrequencyLegendView.swift
//  TestGridPath
//
//  Created by Douglas Adams on 3/22/23.
//

import SwiftUI

struct FrequencyLegendView: View {
  @Binding var center: CGFloat
  @Binding var bandWidth: CGFloat
  @Binding var spacing: CGFloat
  let width: CGFloat
  let format: String
  let color: Color
  
  var offset: CGFloat { -(center - bandWidth/2).truncatingRemainder(dividingBy: spacing) }

  var low: CGFloat { center - bandWidth/2 }
  var high: CGFloat { center + bandWidth/2 }
  var pixelPerHz: CGFloat { width / (high - low)}
  var legendWidth: CGFloat { pixelPerHz * spacing }
  var legendsOffset: CGFloat { offset * pixelPerHz }

  @State var startBandWidth: CGFloat?
  
  var legends: [CGFloat] {
    var array = [CGFloat]()
    
    var currentFrequency = low + offset
    repeat {
      array.append( currentFrequency )
      currentFrequency += spacing
    } while ( currentFrequency <= high )
    return array
  }
  
  var body: some View {
    HStack(spacing: 0) {
      ForEach(legends, id:\.self) { dbmValue in
        Text(String(format: format, dbmValue/1_000_000)).frame(width: legendWidth)
          .background(Color.white.opacity(0.1))
          .contentShape(Rectangle())
          .gesture(
            DragGesture()
              .onChanged { drag in
                if let start = startBandWidth {
                  DispatchQueue.main.async { bandWidth = start + ((drag.startLocation.x - drag.location.x)/pixelPerHz) }
                } else {
                  startBandWidth = bandWidth
                }
              }
              .onEnded { _ in
                startBandWidth = nil
              }
          )
          .offset(x: -legendWidth/2 )
          .foregroundColor(color)
      }
      .offset(x: legendsOffset)
    }
  }
}

struct FrequencyLegendView_Previews: PreviewProvider {
    static var previews: some View {
      FrequencyLegendView(center: .constant(14_100_000),
                          bandWidth: .constant(200_000),
                          spacing: .constant(20_000),
                          width: 800,
                          format: "%.4f",
                          color: .blue)
    }
}

// ----------------------------------------------------------------
// MARK: Supporting

func freqDrag(_ value: DragGesture.Value, _ width: CGFloat, _ bandWidth: inout CGFloat, _ startBandWidth: inout CGFloat?) {
  
  var pixelPerHz: CGFloat { width / bandWidth }
  
  if let start = startBandWidth {
    bandWidth = start + ((value.startLocation.x - value.location.x)/pixelPerHz)
  } else {
    startBandWidth = bandWidth
  }
//  print("bandWidth = \(bandWidth)")
}
