//
//  ContentView.swift
//  TestGridPath
//
//  Created by Douglas Adams on 3/15/23.
//

import SwiftUI

struct ContentView: View {
  @State private var center: CGFloat = 14_100_000
  @State private var bandWidth: CGFloat = 200_000
  @State private var freqSpacing: CGFloat = 20_000
  @State private var dbmHigh: CGFloat = 10
  @State private var dbmLow: CGFloat = -100
  @State private var dbmSpacing: CGFloat = 10

  @State var showControls = true
  
  let legendColor: Color = .green
  let linesColor: Color = .gray
  let frequencyLegendHeight: CGFloat = 30
  let controlsViewHeight: CGFloat = 90
  
  var bottomHeight: CGFloat { showControls ? frequencyLegendHeight + controlsViewHeight : frequencyLegendHeight }
  
  var body: some View {
    GeometryReader { g in
      VStack(alignment: .leading, spacing: 0) {
        
        ZStack {
          // Vertical lines
          FrequencyLinesView(center: center,
                             bandWidth: bandWidth,
                             spacing: freqSpacing,
                             width: g.size.width,
                             height: g.size.height - bottomHeight,
                             color: linesColor)
          
          // Horizontal lines
          DbmLinesView(high: dbmHigh,
                       low: dbmLow,
                       spacing: dbmSpacing,
                       width: g.size.width,
                       height: g.size.height - bottomHeight,
                       color: linesColor)
          
          // Dbm Legend
          DbmLegendView(high: $dbmHigh,
                        low: $dbmLow,
                        spacing: $dbmSpacing,
                        width: g.size.width,
                        height: g.size.height - bottomHeight,
                        color: legendColor)
        }
        
        // Frequency Legend
        Divider().background(legendColor)
        FrequencyLegendView(center: $center,
                            bandWidth: $bandWidth,
                            spacing: $freqSpacing,
                            width: g.size.width,
                            format: "%0.6f",
                            color: legendColor)
        .frame(height: frequencyLegendHeight)
        
        // ----------------------------------------------------------------
        if showControls {
          Divider().background(Color(.red))
          ControlsView(center: $center,
                       bandWidth: $bandWidth,
                       freqSpacing: $freqSpacing,
                       dbmHigh: $dbmHigh,
                       dbmLow: $dbmLow,
                       dbmSpacing: $dbmSpacing)
          .frame(height: controlsViewHeight)
        }
      }
    }
    .toolbar {
      Spacer()
      Button("Controls") { showControls.toggle()}
    }
  }
}

private struct ControlsView: View {
  @Binding var center: CGFloat
  @Binding var bandWidth: CGFloat
  @Binding var freqSpacing: CGFloat
  @Binding var dbmHigh: CGFloat
  @Binding var dbmLow: CGFloat
  @Binding var dbmSpacing: CGFloat

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        HStack(spacing: 5) {
          Text("Center")
          Text("\(Int(center))")
          Image(systemName: "minus.square")
            .font(.title2)
            .onTapGesture{ center -= 100 }
          Slider(value: $center, in: 14_000_000...14_200_000, step: 1_000).frame(width: 130)
          Image(systemName: "plus.square")
            .font(.title2)
            .onTapGesture{ center += 100 }
        }
        Spacer()
        HStack(spacing: 5) {
          Text("Bandwidth")
          Text("\(Int(bandWidth))")
          Image(systemName: "minus.square")
            .font(.title2)
            .onTapGesture{ bandWidth -= 100 }
          Slider(value: $bandWidth, in: 100_000...300_000, step: 1_000).frame(width: 130)
          Image(systemName: "plus.square")
            .font(.title2)
            .onTapGesture{ bandWidth += 100 }
        }
        Spacer()
        HStack(spacing: 5) {
          Text("Spacing")
          Text("\(Int(freqSpacing))")
          Image(systemName: "minus.square")
            .font(.title2)
            .onTapGesture{ freqSpacing -= 1_000 }
          Slider(value: $freqSpacing, in: 5_000...40_000, step: 1_000).frame(width: 150)
          Image(systemName: "plus.square")
            .font(.title2)
            .onTapGesture{ freqSpacing += 1_000 }
        }
      }
      
      HStack(spacing: 60) {
        Text("Start = \(Int(center - bandWidth/2))")
        Text("End = \(Int(center + bandWidth/2))")
      }
      
      Divider().background(Color.blue)
      HStack {
        HStack(spacing: 5) {
          Text("Dbm High")
          Text("\(Int(dbmHigh))")
          Image(systemName: "minus.square")
            .font(.title2)
            .onTapGesture{ dbmHigh -= 1 }
          Slider(value: $dbmHigh, in: -50...10, step: 10).frame(width: 130)
          Image(systemName: "plus.square")
            .font(.title2)
            .onTapGesture{ dbmHigh += 1 }
        }
        Spacer()
        HStack(spacing: 5) {
          Text("Dbm Low")
          Text("\(Int(dbmLow))")
          Image(systemName: "minus.square")
            .font(.title2)
            .onTapGesture{ dbmLow -= 1 }
          Slider(value: $dbmLow, in: -130...0, step: 10).frame(width: 130)
          Image(systemName: "plus.square")
            .font(.title2)
            .onTapGesture{ dbmLow += 1 }
        }
        Spacer()
        HStack(spacing: 5) {
          Text("Dbm Spacing")
          Text("\(Int(dbmSpacing))")
          Image(systemName: "minus.square")
            .font(.title2)
            .onTapGesture{ dbmSpacing -= 5 }
          Slider(value: $dbmSpacing, in: 5...40, step: 5).frame(width: 130)
          Image(systemName: "plus.square")
            .font(.title2)
            .onTapGesture{ dbmSpacing += 5 }
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .frame(width: 1000)
  }
}
