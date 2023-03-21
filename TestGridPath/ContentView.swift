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
  @State private var freqIncr: CGFloat = 20_000
  @State private var dbmHigh: CGFloat = 10
  @State private var dbmLow: CGFloat = -100
  @State private var dbmIncr: CGFloat = 10
  
  let frequencyLegendHeight: CGFloat = 20
  let controlsViewHeight: CGFloat = 90
  
  var freqStart: CGFloat { center - bandWidth/2 }
  var freqEnd: CGFloat { center + bandWidth/2 }
  
  var freqOffset: CGFloat { -freqStart.truncatingRemainder(dividingBy: freqIncr) }
  var dbmOffset: CGFloat { -dbmHigh.truncatingRemainder(dividingBy: dbmIncr) }

  var body: some View {
    GeometryReader { g in
      VStack(alignment: .leading, spacing: 0) {
        
        ZStack {
          // Vertical lines
          FrequencyLines(width: g.size.width,
                         height: g.size.height - frequencyLegendHeight - controlsViewHeight,
                         freqIncr: freqIncr,
                         freqOffset: freqOffset,
                         pixelPerHz: g.size.width/bandWidth)
          
          // Horizontal lines
          DbmLines(dbmHigh: dbmHigh,
                   dbmLow: dbmLow,
                   width: g.size.width,
                   height: g.size.height - frequencyLegendHeight - controlsViewHeight)
          
          // Dbm Legend
          DbmLegend(dbmHigh: dbmHigh,
                    dbmLow: dbmLow,
                    width: g.size.width,
                    height: g.size.height - frequencyLegendHeight - controlsViewHeight)
        }
        
        // Frequency Legend
        Divider().background(Color.green)
        FrequencyLegend(freqStart: freqStart,
                        freqEnd: freqEnd,
                        width: g.size.width,
                        freqIncr: freqIncr,
                        freqOffset: freqOffset,
                        pixelPerHz: g.size.width/bandWidth,
                        format: "%0.6f")
        .frame(height: frequencyLegendHeight)
        .foregroundColor(.green)
        
        // ----------------------------------------------------------------
        
        Divider().background(Color(.red))
        ControlsView(center: $center,
                     bandWidth: $bandWidth,
                     freqIncr: $freqIncr,
                     dbmHigh: $dbmHigh,
                     dbmLow: $dbmLow)
          .frame(height: controlsViewHeight)
      }
    }
  }
}

private struct DbmLines: View {
  let dbmHigh: CGFloat
  let dbmLow: CGFloat
  let width: CGFloat
  let height: CGFloat
  
  var dbmRange: CGFloat { dbmHigh - dbmLow }
  var pixelPerDbm: CGFloat { height / dbmRange }

  let dbmIncr: CGFloat = 10
  var dbmTopOffset: CGFloat { dbmHigh.truncatingRemainder(dividingBy: dbmIncr) }

  var body: some View {
    Path { path in
      var y: CGFloat = dbmTopOffset * pixelPerDbm
      repeat {
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: width, y: y))
        y += pixelPerDbm * dbmIncr
      } while y < height
    }
    .stroke(.gray, lineWidth: 1)
  }
}

private struct DbmLegend: View {
  let dbmHigh: CGFloat
  let dbmLow: CGFloat
  let width: CGFloat
  let height: CGFloat

  var dbmRange: CGFloat { dbmHigh - dbmLow }
  var pixelPerDbm: CGFloat { height / dbmRange }

  let dbmSpacing: CGFloat = 10
  var dbmTopOffset: CGFloat { dbmHigh.truncatingRemainder(dividingBy: dbmSpacing) }

  var legends: [CGFloat] {
    var array = [CGFloat]()
    
    var currentDbm = dbmHigh
    repeat {
      array.append( currentDbm )
      currentDbm -= dbmSpacing
    } while ( currentDbm >= dbmLow )
    return array
  }
  
  var yIncr: CGFloat { pixelPerDbm * dbmSpacing }
  
  var body: some View {
    
    ForEach(Array(legends.enumerated()), id: \.offset) { i, element in
      Text(String(format: "%0.0f", element - dbmTopOffset))
        .position(x: width - 20, y: (dbmTopOffset * pixelPerDbm) + (CGFloat(i) * yIncr))
    }
  }
}

private struct FrequencyLines: View {
  let width: CGFloat
  let height: CGFloat
  let freqIncr: CGFloat
  let freqOffset: CGFloat
  let pixelPerHz: CGFloat
  
  var body: some View {
    Path { path in
      var x: CGFloat = freqOffset * pixelPerHz
      repeat {
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: height))
        x += pixelPerHz * freqIncr
      } while x < width
    }
    .stroke(.gray, lineWidth: 1)
  }
}

private struct FrequencyLegend: View {
  let freqStart: CGFloat
  let freqEnd: CGFloat
  let width: CGFloat
  let freqIncr: CGFloat
  let freqOffset: CGFloat
  let pixelPerHz: CGFloat
  let format: String
  
  var legendWidth: CGFloat { pixelPerHz * freqIncr }
  var legendsOffset: CGFloat { freqOffset * pixelPerHz }
  
  var legends: [CGFloat] {
    var array = [CGFloat]()
    
    var currentFrequency = freqStart + freqOffset
    repeat {
      array.append( currentFrequency )
      currentFrequency += freqIncr
    } while ( currentFrequency <= freqEnd )
    return array
  }
  
  var body: some View {
    HStack(spacing: 0) {
      ForEach(legends, id:\.self) { legend in
        Text(String(format: format, legend/1_000_000)).frame(width: legendWidth)
          .offset(x: -legendWidth/2 )
      }
      .offset(x: legendsOffset)
    }
  }
}

private struct ControlsView: View {
  @Binding var center: CGFloat
  @Binding var bandWidth: CGFloat
  @Binding var freqIncr: CGFloat
  @Binding var dbmHigh: CGFloat
  @Binding var dbmLow: CGFloat

  var body: some View {
    VStack {
      HStack {
        HStack(spacing: 5) {
          Text("Center")
          Image(systemName: "minus.square")
            .onTapGesture{ center -= 100 }
          Slider(value: $center, in: 14_000_000...14_200_000, step: 1_000).frame(width: 130)
          Image(systemName: "plus.square")
            .onTapGesture{ center += 100 }
          Text("\(Int(center))")
        }
        Spacer()
        HStack(spacing: 5) {
          Text("Bandwidth")
          Image(systemName: "minus.square")
            .onTapGesture{ bandWidth -= 100 }
          Slider(value: $bandWidth, in: 100_000...300_000, step: 1_000).frame(width: 130)
          Image(systemName: "plus.square")
            .onTapGesture{ bandWidth += 100 }
          Text("\(Int(bandWidth))")
        }
        Spacer()
        HStack(spacing: 5) {
          Text("Freq Incr")
          Image(systemName: "minus.square")
            .onTapGesture{ freqIncr -= 1_000 }
          Slider(value: $freqIncr, in: 5_000...40_000, step: 1_000).frame(width: 150)
          Image(systemName: "plus.square")
            .onTapGesture{ freqIncr += 1_000 }
          Text("\(Int(freqIncr))")
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
          Image(systemName: "minus.square")
            .onTapGesture{ dbmHigh -= 1 }
          Slider(value: $dbmHigh, in: -50...10, step: 10).frame(width: 130)
          Image(systemName: "plus.square")
            .onTapGesture{ dbmHigh += 1 }
          Text("\(Int(dbmHigh))")
        }
        Spacer()
        HStack(spacing: 5) {
          Text("Dbm Low")
          Image(systemName: "minus.square")
            .onTapGesture{ dbmLow -= 1 }
          Slider(value: $dbmLow, in: -130...0, step: 10).frame(width: 130)
          Image(systemName: "plus.square")
            .onTapGesture{ dbmLow += 1 }
          Text("\(Int(dbmLow))")
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

extension String {
  func height(withConstrainedWidth width: CGFloat, font: Font) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    
    return ceil(boundingBox.height)
  }
  
  func width(withConstrainedHeight height: CGFloat, font: Font) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    
    return ceil(boundingBox.width)
  }
}
