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
  @State private var dbmSpacing: CGFloat = 10

  let frequencyLegendHeight: CGFloat = 20
  let controlsViewHeight: CGFloat = 90
  
  var freqStart: CGFloat { center - bandWidth/2 }
  var freqEnd: CGFloat { center + bandWidth/2 }
  
  var freqOffset: CGFloat { -freqStart.truncatingRemainder(dividingBy: freqIncr) }

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
                   height: g.size.height - frequencyLegendHeight - controlsViewHeight,
                   dbmSpacing: dbmSpacing)

          // Dbm Legend
          DbmLegend(dbmHigh: $dbmHigh,
                    dbmLow: $dbmLow,
                    width: g.size.width,
                    height: g.size.height - frequencyLegendHeight - controlsViewHeight,
                    dbmSpacing: $dbmSpacing)
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
        
        // ----------------------------------------------------------------
        
        Divider().background(Color(.red))
        ControlsView(center: $center,
                     bandWidth: $bandWidth,
                     freqIncr: $freqIncr,
                     dbmHigh: $dbmHigh,
                     dbmLow: $dbmLow,
                     dbmSpacing: $dbmSpacing)
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
  let dbmSpacing: CGFloat

  var dbmRange: CGFloat { dbmHigh - dbmLow }
  var pixelPerDbm: CGFloat { height / dbmRange }

  var dbmTopOffset: CGFloat { dbmHigh.truncatingRemainder(dividingBy: dbmSpacing) }

  var body: some View {
    Path { path in
      var y: CGFloat = dbmTopOffset * pixelPerDbm
      repeat {
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: width, y: y))
        y += pixelPerDbm * dbmSpacing
      } while y < height
    }
    .stroke(.gray, lineWidth: 1)
  }
}

private struct DbmLegend: View {
  @Binding var dbmHigh: CGFloat
  @Binding var dbmLow: CGFloat
  let width: CGFloat
  let height: CGFloat
  @Binding var dbmSpacing: CGFloat

  var dbmRange: CGFloat { dbmHigh - dbmLow }
  var pixelPerDbm: CGFloat { height / dbmRange }

  var dbmTopOffset: CGFloat { dbmHigh.truncatingRemainder(dividingBy: dbmSpacing) }
  var yIncr: CGFloat { pixelPerDbm * dbmSpacing }
  
  @State var startHigh: CGFloat?
  @State var startLow: CGFloat?

  var legends: [CGFloat] {
    var array = [CGFloat]()
    
    var currentDbm = dbmHigh
    repeat {
      array.append( currentDbm )
      currentDbm -= dbmSpacing
    } while ( currentDbm >= dbmLow )
    return array
  }
  
  var body: some View {
    
    ZStack(alignment: .trailing) {
      ForEach(Array(legends.enumerated()), id: \.offset) { i, legend in
        if legend > dbmLow {
          Text(String(format: "%0.0f", legend - dbmTopOffset))
            .position(x: width - 20, y: (dbmTopOffset * pixelPerDbm) + (CGFloat(i) * yIncr))
            .foregroundColor(.green)
        }
      }
      
      Rectangle()
        .frame(width: 50).border(.red)
        .foregroundColor(.black).opacity(0.1)
        .contentShape(Rectangle())
        .gesture(
          DragGesture()
            .onChanged {value in
              switch value.startLocation.y {
              case 0..<height/3:
                if let high = startHigh {
                  dbmHigh = high - ((value.startLocation.y - value.location.y)/pixelPerDbm)
                } else {
                  startHigh = dbmHigh
                }
              case 2*(height/3)...height:
                if let low = startLow {
                  dbmLow = low - ((value.startLocation.y - value.location.y)/pixelPerDbm)
                } else {
                  startLow = dbmLow
                }
              default:
                if let high = startHigh, let low = startLow {
                  dbmHigh = high - ((value.startLocation.y - value.location.y)/pixelPerDbm)
                  dbmLow = low - ((value.startLocation.y - value.location.y)/pixelPerDbm)
                } else {
                  startLow = dbmLow
                  startHigh = dbmHigh
                }
              }
            }
            .onEnded { value in
              startHigh = nil
              startLow = nil
            }
        )
        .contextMenu {
          Button { dbmSpacing = 5 } label: {Text("5 dbm")}
          Button { dbmSpacing = 10 } label: {Text("10 dbm")}
          Button { dbmSpacing = 15 } label: {Text("15 dbm")}
          Button { dbmSpacing = 20 } label: {Text("20 dbm")}
        }
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
          .contentShape(Rectangle())
          .gesture(
            DragGesture()
              .onChanged { newValue in
                print(".onChanged Freq")
              }
              .onEnded { _ in
                print(".onEnded Freq")
              }
          )
          .offset(x: -legendWidth/2 )
          .foregroundColor(.green)
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
  @Binding var dbmSpacing: CGFloat

  var body: some View {
    VStack {
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
          Text("Freq Incr")
          Text("\(Int(freqIncr))")
          Image(systemName: "minus.square")
            .font(.title2)
            .onTapGesture{ freqIncr -= 1_000 }
          Slider(value: $freqIncr, in: 5_000...40_000, step: 1_000).frame(width: 150)
          Image(systemName: "plus.square")
            .font(.title2)
            .onTapGesture{ freqIncr += 1_000 }
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
