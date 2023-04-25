//
//  Home.swift
//  ScratchFunctional
//
//  Created by Dan on 3/5/23.
//

import SwiftUI
import Foundation

//Physical Layout
struct Home: View {
    @State var onFinish: Bool = false
    @State var scratchMat: Color = Color(red: 0.1, green: 0.1, blue: 0.1)
    //@State var onFinishTable = [[Bool]]() //For advanced thingamabobs
    @State var iconList = ["xmark.square.fill",
                           "curlybraces.square.fill",
                           "",
                           "",
                           ""
    ].shuffled()
    
    var body: some View {
        
        VStack {
            
            //Scratch Card View
            /*
             1. Create N*M grid of scratchable cells with unique content
             2. Implement per cell scratch functionality
                a. Via 2d array
             3. Implement reset button to all cells
             
             */
            
            //Instace of Scratch Card Cell
                VStack {
                    ScratchCardView(cursorSize: 50, onFinish: $onFinish) {
                        // Body
                        VStack {
                            
                            HStack {
                                ForEach(0...3, id: \.self) {xRow in
                                    VStack {
                                        ForEach(0...3, id: \.self) {yRow in
                                            Image(systemName: "\(Int.random(in: 1..<51)).square.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .padding(10)
                                                .foregroundColor(.indigo)
                                            
                                        }
                                    }
                                    
                                }
                            }
                            /*
                            Image(systemName: "curlybraces.square.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(10)
                                .foregroundColor(.indigo)
                             */
                            
                            /*
                            Text("Woah, a surprise")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.indigo)
                             */
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                        .cornerRadius(20)
                        
                    } overlayView: {
                        //overlay image or view
                        //Can just have background color fade out.
                        
                        Image(systemName: "")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(.green)
                            .background(scratchMat)
                         
                    }
                    
                }
            
            
            
        }
        .frame(maxWidth: .infinity, maxHeight:.infinity)
        .background(Color.gray.ignoresSafeArea())
        .overlay(
            //Exterior info and pieces
            HStack(spacing: 15) {
                Button(action: {}, label: {
                    //Color.black
                        //.frame(maxWidth: 150, maxHeight: 150)
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                })
                
                Text("Scratch Card")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer(minLength: 0)
                
                //Reset button logic
                Button(action: {
                    //globalize on finishes for the 2d array
                    onFinish = false
                }, label: {
                    Color.black
                        .frame(maxWidth: 50, maxHeight: 50)
                })
            }
            .padding()
            ,alignment: .top
        )
    }
}


//PREVIEW
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}


//Stuff
struct ScratchCardView<Content: View, OverlayView: View>: View {
    
    var content: Content
    var overlayView: OverlayView
    
    init(cursorSize: CGFloat, onFinish: Binding<Bool>, @ViewBuilder content: @escaping ()->Content, @ViewBuilder overlayView: @escaping ()->OverlayView) {
        self.content = content()
        self.overlayView = overlayView()
        self.cursorSize = cursorSize
        self._onFinish = onFinish
    }
    
    //Scratch Effect (FOR THE LOVE OF GOD THIS GUY TOOK SO LONG TO GET HERE)
    @State var sP: CGPoint = .zero
    @State var points: [CGPoint] = []
    
    //for gesture update. Path tracing
    @GestureState var gestLoc: CGPoint = .zero
    
    //Customization and on finish
    var cursorSize: CGFloat
    @Binding var onFinish: Bool
    
    var body: some View {
        
        ZStack{
            
            overlayView
                .opacity(onFinish ? 0 : 1)
            
            content
                .mask(
                    ZStack{
                        if !onFinish{
                            ScratchMask(points: points, sP: sP)
                            .stroke(style: StrokeStyle(lineWidth: cursorSize, lineCap: .round, lineJoin: .round))
                        } else {
                            //just show it at this point
                            Rectangle()
                        }
                    }
                 )
                .animation(.easeInOut)
                .gesture(
                    DragGesture()
                        .updating($gestLoc, body: { value, out, _ in
                            out = value.location
                            
                            DispatchQueue.main.async {
                                //updates start point and adds user drag locs
                                if sP == .zero {
                                    sP = value.location
                                }
                                
                                points.append(value.location)
                                //print(points)
                            }
                        })
                        .onEnded({ value in
                            withAnimation{
                                onFinish = true
                            }
                        })
                )
                
                            
        }
        .frame(width: 300, height: 300)
        //.cornerRadius(20)
        .onChange(of: onFinish, perform: { value in
            // Check and reset yo scribbles
            if !onFinish && !points.isEmpty{
                withAnimation(.easeInOut){
                    reScratch()
                }
            }
        })
    }
    
    func reScratch() {
        points.removeAll()
        sP = .zero
    }
}


//Scratch Mask Shape
struct ScratchMask: Shape {
    
    var points: [CGPoint]
    var sP: CGPoint
    
    func path(in rect: CGRect) -> Path {
        
        return Path{path in
            path.move(to: sP)
            path.addLines(points)
        }
    }
}

