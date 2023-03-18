//
//  ContentView.swift
//  TestGridPath
//
//  Created by Douglas Adams on 3/15/23.
//

import SwiftUI

struct ContentView: View {
  @State private var center: CGFloat = 14_100_000
  @State private var bandwidth: CGFloat = 200_100
  @State private var freqIncr: CGFloat = 20_000
  
  var start: CGFloat { center - bandwidth/2 }
  var end: CGFloat { center + bandwidth/2 }
  
  var freqOffset: CGFloat { -start.truncatingRemainder(dividingBy: freqIncr) }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      GeometryReader { g in
        
        ZStack {
          // Vertical lines
          Path { path in
            var x: CGFloat = freqOffset * ( g.size.width/bandwidth )
            repeat {
              path.move(to: CGPoint(x: x, y: 0))
              path.addLine(to: CGPoint(x: x, y: g.size.height))
              x += (g.size.width/bandwidth) * freqIncr
            } while x < g.size.width
          }
          .stroke(.gray, lineWidth: 1)
          
          // Horizontal lines
//          Path { path in
//            for i in 0...Int(ticks) {
//              path.move(to: CGPoint(x: 0, y: CGFloat(i) * yIncr))
//              path.addLine(to: CGPoint(x: g.size.width, y: CGFloat(i) * yIncr))
//            }
//          }
//          .stroke(.gray, lineWidth: 1)
//          .offset(y: 0 * yIncr)
//
//          Text("Dbm")
//            .frame(width: g.size.width, alignment: .trailing)
//            .foregroundColor(.green)
//            .offset(y: 0 * yIncr)
        }
      }
      
      // Frequency Legend
      Divider().background(Color.green)
      FrequencyLegend(center: center, bandwidth: bandwidth, freqIncr: freqIncr, format: "%0.6f")
        .frame(height: 20)
        .foregroundColor(.green)

      // ----------------------------------------------------------------

      Divider().background(Color(.red))
      ControlsView(center: $center, bandwidth: $bandwidth, freqIncr: $freqIncr)
    }
  }
}

private struct FrequencyLegend: View {
  var center: CGFloat
  var bandwidth: CGFloat
  var freqIncr: CGFloat
  var format: String

  var start: CGFloat { center - bandwidth/2 }
  var end: CGFloat { center + bandwidth/2 }
  var freqOffset: CGFloat { start.truncatingRemainder(dividingBy: freqIncr) }
  
  var legends: [CGFloat] {
    var array = [CGFloat]()
    
    var currentFrequency = start - start.truncatingRemainder(dividingBy: freqIncr)
    repeat {
      array.append( currentFrequency )
      currentFrequency += freqIncr
    } while ( currentFrequency <= center + bandwidth/2 )
    
    print("-----> \(array)")
    
    return array
  }
  
  var body: some View {
    GeometryReader { g in
            
      HStack(spacing: 0) {
        ForEach(legends, id:\.self) { legend in
            Text(String(format: format, legend/1_000_000)).frame(width: ( g.size.width/bandwidth ) * freqIncr)
              .offset(x: -(( g.size.width/bandwidth ) * freqIncr)/2 )
          }
        .offset(x: -freqOffset * (g.size.width/bandwidth))
      }
    }
  }
}

private struct ControlsView: View {
  @Binding var center: CGFloat
  @Binding var bandwidth: CGFloat
  @Binding var freqIncr: CGFloat

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
            .onTapGesture{ bandwidth -= 100 }
          Slider(value: $bandwidth, in: 100_000...300_000, step: 1_000).frame(width: 130)
          Image(systemName: "plus.square")
            .onTapGesture{ bandwidth += 100 }
          Text("\(Int(bandwidth))")
        }
//        .onChange(of: bandwidth) { newValue in
//          start = center - newValue/2
//          end = center + newValue/2
//        }
        Spacer()
        HStack(spacing: 5) {
          Text("Freq Incr")
          Slider(value: $freqIncr, in: (bandwidth/40)...(bandwidth/5), step: 1_000).frame(width: 150)
          Text("\(Int(freqIncr))")
        }
      }.frame(height: 40)
      
      HStack(spacing: 60) {
        Text("Start = \(Int(center - bandwidth/2))")
        Text("End = \(Int(center + bandwidth/2))")
      }.frame(height: 40)

    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .frame(width: 1000)
  }
}
