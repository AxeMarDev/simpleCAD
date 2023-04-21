//
//  ContentView.swift
//  allang
//
//  Created by Axell Martinez on 4/18/23.
//

import SwiftUI

//
//  scrollView2d.swift
//  newApp
//
//  Created by Axell Martinez on 2/27/23.
//

struct Scrollview2d<Content>: View where Content: View {
    
    // vairables for x

//    @State  var contentwidth: CGFloat = CGFloat.zero
//    @State  var scrollOffsetx: CGFloat = CGFloat.zero
//    @State  var currentOffsetx: CGFloat = 2500
    @Binding  var contentwidth: CGFloat
    @Binding  var scrollOffsetx: CGFloat
    @Binding  var currentOffsetx: CGFloat

    
    // variables for Y
    @Binding  var contentHeight: CGFloat
    @Binding  var scrollOffsety: CGFloat
    @Binding  var currentOffsety: CGFloat

    
    
    @State var dragable:Bool = true
    @Binding var isDragging:Bool
    @State var scrollDrgain:Bool = true
    
    @Binding var scale:CGFloat
    
    var content: () -> Content
    
    //cal ofset y
    func offsety(outerheight: CGFloat, innerheight: CGFloat) -> CGFloat {
        
        let totalOffset = currentOffsety  + scrollOffsety - outerheight/2
        return -((innerheight/2 - outerheight/2 ) - totalOffset)
    }
    
    // Calculate content offset x
    func offsetx(outerwidth: CGFloat, innerwidth: CGFloat) -> CGFloat {
       
        let totalOffset = currentOffsetx  + scrollOffsetx - outerwidth/2
        return -((innerwidth/2 - outerwidth/2  ) - totalOffset)
    }
    
    var body: some View {
        
       
        
        GeometryReader{ outerGeometry in
            // Render the content
            //  ... and set its sizing inside the parent
            self.content()
            .modifier(ViewHeightKey2())
            .onPreferenceChange(ViewHeightKey2.self) { self.contentwidth = $0 }
            .frame(width: outerGeometry.size.width)
            .offset(x: self.offsetx(outerwidth: outerGeometry.size.width, innerwidth: self.contentwidth ))
           
            .modifier(ViewHeightKey1())
            .onPreferenceChange(ViewHeightKey1.self) { self.contentHeight = $0 }
            .frame(height: outerGeometry.size.height)
            .offset(y: self.offsety(outerheight: outerGeometry.size.height, innerheight: self.contentHeight  ))
           
            .clipped()
            //.animation(.easeOut)
            .contentShape(Rectangle())
            .gesture(
                 DragGesture()
                    .onChanged({
                        if self.dragable{
                            self.onDragChangedy($0)
                        }
                    })
                    .onChanged({
                        if self.dragable{
                            self.onDragChangedx($0)
                        }
                    })
                    .onEnded({
                        if self.dragable {
                            self.onDragEndedy($0, outerHeight: outerGeometry.size.height)
                        }
                        
                        
                    })
                    .onEnded({
                        
                        if self.dragable{
                            self.onDragEndedx($0, outerwidth: outerGeometry.size.width)
                        }
                      
                        
                    }))
        }

    }
    func onDragChangedy(_ value: DragGesture.Value) {
        // Update rendered offset
        
        self.scrollOffsety = (value.location.y - value.startLocation.y)
        self.isDragging =  true
        self.scrollDrgain = true
    }
    
    func onDragEndedy(_ value: DragGesture.Value, outerHeight: CGFloat) {
        // Update view to target position based on drag position
        let scrollOffset = value.location.y - value.startLocation.y
 
        let topLimit = self.contentHeight - outerHeight/2
        
        
        // Negative topLimit => Content is smaller than screen size. We reset the scroll position on drag end:
        if topLimit < 0 {
             self.currentOffsety = 0
        } else {
            // We cannot pass bottom limit (negative scroll)
            if self.currentOffsety + scrollOffset < outerHeight/2 {
                self.currentOffsety = outerHeight/2
            } else if self.currentOffsety + scrollOffset > topLimit {
                self.currentOffsety = topLimit
            } else {
                self.currentOffsety += scrollOffset
            }
        }
        self.scrollDrgain = false
        self.scrollOffsety = 0
        self.isDragging =  false
    }
    
    func onDragChangedx(_ value: DragGesture.Value) {
        // Update rendered offset
        
        self.scrollOffsetx = (value.location.x - value.startLocation.x)
        self.isDragging =  true
        self.scrollDrgain = true
    }
    
    func onDragEndedx(_ value: DragGesture.Value, outerwidth: CGFloat) {
        // Update view to target position based on drag position
        let scrollOffset = value.location.x - value.startLocation.x
       
        
        let topLimit = self.contentwidth - outerwidth/2
        
        // Negative topLimit => Content is smaller than screen size. We reset the scroll position on drag end:
        if topLimit < 0 {
             self.currentOffsetx = 0
        } else {
            // We cannot pass bottom limit (negative scroll)
            if self.currentOffsetx + scrollOffset <  outerwidth/2 {
                self.currentOffsetx =  outerwidth/2
            } else if self.currentOffsetx + scrollOffset > topLimit {
                self.currentOffsetx = topLimit
            } else {
                self.currentOffsetx += scrollOffsetx
            }
        }
    
        self.scrollOffsetx = 0
        self.isDragging =  false
        self.scrollDrgain = false


    }
}

struct ViewHeightKey1: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

extension ViewHeightKey1: ViewModifier {
    func body(content: Content) -> some View {
        return content.background(GeometryReader { proxy in
            Color.clear.preference(key: Self.self, value: proxy.size.height)
        })
    }
}

struct ViewHeightKey2: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

extension ViewHeightKey2: ViewModifier {
    func body(content: Content) -> some View {
        return content.background(GeometryReader { proxy in
            Color.clear.preference(key: Self.self, value: proxy.size.width)
        })
    }
}

struct PathMaker: View{
    
    var index:Int
    @Binding var rooms:[Room]
    let origin:Origin
    @Binding var currentIndex:Int
    @Binding var isDraggable:Bool
    
    @State var widthWall:CGFloat = 8

    
    var body: some View{
        
        ZStack{
            
            if !isDraggable && currentIndex == index{
                
                ZStack{
                    VStack{
                        Image(systemName: "moonphase.new.moon")
                    }.frame(width: 10, height: 10)
                    .background(Color.red)
                    .position(x: origin.x + rooms[index].localOffsetx , y: origin.y + ( -1.0 * rooms[index].getOffsetY() ))
                    
                    VStack{
                        Image(systemName: "moonphase.new.moon")
                    }.frame(width: 10, height: 10)
                    .background(Color.red)
                    .position(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength(), y: origin.y + (  -1.0 * rooms[index].getOffsetY()))
                    
                    VStack{
                        Image(systemName: "moonphase.new.moon")
                    }.frame(width: 10, height: 10)
                    .background(Color.red)
                    .position(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength(), y: origin.y + ( -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth())))
                    
                    VStack{
                        Image(systemName: "moonphase.new.moon")
                    }.frame(width: 10, height: 10)
                    .background(Color.red)
                    .position(x: origin.x + rooms[index].getOffsetX(), y: origin.y + (  -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth())))
                              
                }
                .zIndex(4)
                
                Path { path in
                    path.move(   to: CGPoint(x: origin.x + rooms[index].localOffsetx ,
                                             y: origin.y + ( -1.0 * rooms[index].getOffsetY() )))
                    path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength(),
                                             y: origin.y + (  -1.0 * rooms[index].getOffsetY())))
                    path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength(),
                                             y: origin.y + ( -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth()))))
                    path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX(),
                                             y: origin.y + (  -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth()))))
                    path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX(),
                                             y: origin.y +  (  -1.0 * rooms[index].getOffsetY())))
                    path.closeSubpath()
                }
                .stroke(Color.red, lineWidth: 1)
                .zIndex(3)
                
                        
            }
            
            Path{ path in
                path.move(   to: CGPoint(x: origin.x + rooms[index].localOffsetx ,
                                         y: origin.y + ( -1.0 * rooms[index].getOffsetY() )))
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength(),
                                         y: origin.y + (  -1.0 * rooms[index].getOffsetY())))
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength(),
                                         y: origin.y + ( -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth()))))
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX(),
                                         y: origin.y + (  -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth()))))
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX(),
                                         y: origin.y +  (  -1.0 * rooms[index].getOffsetY())))
                path.closeSubpath()
            }
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
            .zIndex(1.5)

            // wall pathing
            Path { path in
                
                // bottom right corner
                path.move(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + ( ( 0 - (widthWall/2)) * calcCorner("TL", "x")) ,
                                         y: origin.y +  (  -1.0 * rooms[index].getOffsetY()) + (( 0 - (widthWall/2)) * calcCorner("TL", "y") )))
                             
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength()  + (( 0 - (widthWall/2)) * calcCorner("TR", "x")) ,
                                         y: origin.y + (  -1.0 * rooms[index].getOffsetY()) + (( 0 - (widthWall/2)) * calcCorner("TR", "y"))) )
                             
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength()  + (( 0 - (widthWall/2)) * calcCorner("BR", "x")),
                                         y: origin.y + ( -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth())) + (( 0 - (widthWall/2)) * calcCorner("BR", "y"))))
                             
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + (( 0 - (widthWall/2)) * calcCorner("BL", "x")),
                                         y: origin.y + (  -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth()) + (( 0 - (widthWall/2)) * calcCorner("BL", "y")))))
                             
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX()  + (( 0 - (widthWall/2)) * calcCorner("TL", "x")) ,
                                         y: origin.y +  (  -1.0 * rooms[index].getOffsetY())  + (( 0 - (widthWall/2)) * calcCorner("TL", "y") )))
                

                
                
                // bottom right corner
                path.move(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + ( ( 0 + (widthWall/2)) * calcCorner("TL", "x")) ,
                                         y: origin.y +  (  -1.0 * rooms[index].getOffsetY()) + (( 0 + (widthWall/2)) * calcCorner("TL", "y") )))
                             
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength()  + (( 0 + (widthWall/2)) * calcCorner("TR", "x")) ,
                                         y: origin.y + (  -1.0 * rooms[index].getOffsetY()) + (( 0 + (widthWall/2)) * calcCorner("TR", "y"))) )
                             
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength()  + (( 0 + (widthWall/2)) * calcCorner("BR", "x")),
                                         y: origin.y + ( -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth())) + (( 0 + (widthWall/2)) * calcCorner("BR", "y"))))
                             
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + (( 0 + (widthWall/2)) * calcCorner("BL", "x")),
                                         y: origin.y + (  -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth()) + (( 0 + (widthWall/2)) * calcCorner("BL", "y")))))
                             
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX()  + (( 0 + (widthWall/2)) * calcCorner("TL", "x")) ,
                                         y: origin.y +  (  -1.0 * rooms[index].getOffsetY())  + (( 0 + (widthWall/2)) * calcCorner("TL", "y") )))
                
                path.closeSubpath()
             
                
            }
            //.fill(Color.red)
            .stroke(Color.white, lineWidth: 1)
            .zIndex(1)
            
            Path { path in
                path.move(   to: CGPoint(x: origin.x + rooms[index].localOffsetx , y: origin.y + ( -1.0 * rooms[index].getOffsetY() )))
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength(), y: origin.y + (  -1.0 * rooms[index].getOffsetY())))
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength(), y: origin.y + ( -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth()))))
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX(), y: origin.y + (  -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth()))))
                path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX(), y: origin.y +  (  -1.0 * rooms[index].getOffsetY())))
                path.closeSubpath()
            }
            .fill(Color.white.opacity(0.00001))
            .zIndex(0)
        }
        
    }
    
    func calcCorner(_ corner:String , _ axis:String ) -> CGFloat{
        
        // top right x + y +
        // top left x + y -
        // bottom right x - y +
        // bottom left x - y -
        
        
        if 0 < rooms[index].getLength() &&  0 < rooms[index].getWidth(){
            // top rigth
            if corner == "TL" {
                if axis == "x"{
                    return 1
                } else {
                    return -1
                }
            } else if corner == "TR" {
                if axis == "x"{
                    return -1
                } else {
                    return -1
                }
            } else if corner == "BR" {
                if axis == "x"{
                    return -1
                } else {
                    return 1
                }
            } else if corner == "BL" {
                if axis == "x"{
                    return 1
                } else {
                    return 1
                }
            } else {
                return 0
            }
           
        } else if  0 > rooms[index].getLength() &&  0 < rooms[index].getWidth() {
            // top left
            if corner == "TL" {
                if axis == "x"{
                    return -1
                } else {
                    return -1
                }
            } else if corner == "TR" {
                if axis == "x"{
                    return 1
                } else {
                    return -1
                }
            } else if corner == "BR" {
                if axis == "x"{
                    return 1
                } else {
                    return 1
                }
            } else if corner == "BL" {
                if axis == "x"{
                    return -1
                } else {
                    return 1
                }
            } else {
                return 0
            }
            
        } else if 0 < rooms[index].getLength() &&  0 > rooms[index].getWidth() {
            // bottom right
            if corner == "TL" {
                if axis == "x"{
                    return 1
                } else {
                    return 1
                }
            } else if corner == "TR" {
                if axis == "x"{
                    return -1
                } else {
                    return 1
                }
            } else if corner == "BR" {
                if axis == "x"{
                    return -1
                } else {
                    return -1
                }
            } else if corner == "BL" {
                if axis == "x"{
                    return 1
                } else {
                    return -1
                }
            } else {
                return 0
            }
        } else if  0 > rooms[index].getLength() &&  0 > rooms[index].getWidth() {
            // bottom left
            if corner == "TL" {
                if axis == "x"{
                    return -1
                } else {
                    return 1
                }
            } else if corner == "TR" {
                if axis == "x"{
                    return 1
                } else {
                    return 1
                }
            } else if corner == "BR" {
                if axis == "x"{
                    return 1
                } else {
                    return -1
                }
            } else if corner == "BL" {
                if axis == "x"{
                    return -1
                } else {
                    return -1
                }
            } else {
                return 0
            }
        }
        return 0
    }
    

}

// instead of zstack, use scrollview2d
struct canvasView: View{
    
    let origin:Origin
   
    @Binding var rooms:[Room]
    
    
    @State var location:CGPoint = CGPoint.zero
    @State var originalLocation:CGPoint = CGPoint.zero
    
    @State var lengthWidthDisplay:CGPoint = CGPoint.zero
    
    @State var started:Bool = false
    
    var simpleDrag: some Gesture {
        DragGesture()
        
        
            .onChanged { value in
                if started {
                    lengthWidthDisplay.x = ((value.location.x ) )
                    
                    lengthWidthDisplay.y = ((value.location.y ) )

                    rooms[rooms.count - 1].setLength( ((rooms[rooms.count - 1].getOffsetX()) - ((value.location.x - 2500) ))  * -1 )
                    rooms[rooms.count - 1].setWidth( ((rooms[rooms.count - 1].getOffsetY()) - ((value.location.y - 2500 ) * -1)) * -1)
                }
               
            }
            .onEnded { value in
                started = false;
                
                print(" length x: \(rooms[rooms.count - 1].getWidth() )")
                print(" length y: \( rooms[rooms.count - 1].getLength() )")
            }
          
    }
    
    @Binding var isDraggable:Bool
    
    var canvasL:CGFloat = 400
    var canvasW:CGFloat = 400
    
    @State var currentIndex:Int = -1
    @Binding var structure:StructureVertex
    
    var canvasContent: some View{
        ZStack{
            // height x  20 and width y 40
            
            if started {
                VStack{
                    if structure.walls.count <= 0 {
                        Text("empty")
                    } else {
                        Text("x: \( abs( structure.walls[structure.walls.count - 1].x)/50.0  )''")
                        Text("y: \( abs(structure.walls[structure.walls.count - 1].y)/50.0  )''")
                    }
                    
                }
                .frame(width: 140, height: 50)
                .foregroundColor(Color.black.opacity(1))
                .background(Color.gray.opacity(1))
                .border(Color.black, width: 1)
                .zIndex(10)
                .position( x: lengthWidthDisplay.x + 80 , y: lengthWidthDisplay.y - 25 )
                
                Rectangle()
                    .frame(width: 1, height: 20)
                    .background(Color.black.opacity(1))
                    .position( x: lengthWidthDisplay.x  , y: lengthWidthDisplay.y  )
                Rectangle()
                    .frame(width: 20, height: 1)
                    .background(Color.black.opacity(1))
                    .position( x: lengthWidthDisplay.x  , y: lengthWidthDisplay.y  )
                
            }
            
            
           //.position( x: rooms[rooms.count - 1].getWidth(), y: rooms[rooms.count - 1].getLength() )
            
            /*
            ForEach(0..<rooms.count , id: \.self ) { i in
                
                
                if  !isDraggable {
                    Button {
                        currentIndex = i
                    } label: {
                        
                        PathMaker(index: i, rooms: $rooms, origin: origin, currentIndex: $currentIndex, isDraggable: $isDraggable)
                          
                    }.buttonStyle(.plain)
                } else {
                    PathMaker(index: i, rooms: $rooms, origin: origin, currentIndex: $currentIndex, isDraggable: $isDraggable)
                }
                
            }
            */
            
          
            vertexPathMaker( structure: $structure , origin: origin,  isDraggable: $isDraggable)
            
            
            Rectangle()
                .frame(width: 2)
                .frame(maxHeight: .infinity)
                .foregroundColor(Color.blue)
                .opacity(0.5)
                .position(x: origin.x + 0.0, y: origin.y + 0.0 )
            
            Rectangle()
                .frame(height: 2)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.pink)
                .opacity(0.5)
                .position(x: origin.x + 0.0, y: origin.x + 0.0 )
            
            if  isDraggable || isDraggingIn{
                Rectangle()
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .foregroundColor(Color.green)
                    .opacity(0.1)
                    .position(x: origin.x + canvasW, y: origin.y + 0.0 )
                
                
                Rectangle()
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.red)
                    .opacity(0.1)
                    .position(x: origin.x + 0.0, y: origin.y + canvasL )
                
                
                Rectangle()
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .foregroundColor(Color.green)
                    .opacity(0.1)
                    .position(x: origin.x - canvasW, y: origin.y + 0.0 )
            
                Rectangle()
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.red)
                    .opacity(0.1)
                    .position(x: origin.x + 0.0, y: origin.y - canvasL )
            }
            
            
            VStack{
                ForEach(0..<100){ i in
                    Rectangle()
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color.black)
                        .opacity(0.01)

                    Spacer()
                }
                Rectangle()
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.black)
                    .opacity(0.1)

            }
            HStack{
                ForEach(0..<100){ i in
                    Rectangle()
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .foregroundColor(Color.black)
                        .opacity(0.01)

                    Spacer()
                }
                Rectangle()
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
                    .foregroundColor(Color.black)
                    .opacity(0.1)
            }
        }
        
    }
    
    
    

    
    
    

    @State  var contentwidth: CGFloat = CGFloat.zero
    @State  var scrollOffsetx: CGFloat = CGFloat.zero
    @State  var currentOffsetx: CGFloat = 2500
    
    @State  var contentHeight: CGFloat = CGFloat.zero
    @State  var scrollOffsety: CGFloat = CGFloat.zero
    @State  var currentOffsety: CGFloat = 2500
    
    @State var isDraggingIn:Bool = false
    
    
    @Binding var scale:CGFloat
    
    var body: some View {
        

            ZStack{
                                // in order to keep track of position in xyplane, set points to binding type
                // store in a strust @State
                VStack(spacing: 0){
                    HStack(spacing: 0){
                        
                        HStack{
                            
                        }
                        .frame(width: 20, height:40)
                        .background(Color.black)
                        .border(Color.black, width: 1)
                        
                        ScrollviewX( contentwidth: $contentwidth, scrollOffsetx: $scrollOffsetx, currentOffsetx: $currentOffsetx){
                            HStack(spacing: 0){
                                
                                ForEach(0..<99){ i in
                                    VStack (spacing: 0) {
                                        Text("\( i - 49)")
                                           
                                        Rectangle()
                                            .frame(width: 1*scale, height: 10)
                                            .foregroundColor(Color.white)
                                    }
                                    .frame(width: 40*scale )
                                    .frame(maxHeight: .infinity)
                                
                                }
//
                            }
                            .frame(width: 5000*scale)
                            .frame(maxHeight: .infinity)
                            .background(Color.black)
                            
                            
                        }
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .border(Color.black, width: 1)
                        
                    }
                    
                    HStack(spacing: 0){
                        
                        ScrollviewY(contentHeight: $contentHeight, scrollOffsety: $scrollOffsety, currentOffsety: $currentOffsety){
                            VStack{
                                
                                ForEach(0..<101){ i in
                                    Spacer()
                                    Rectangle()
                                        .frame(width: 15, height: 1)
                                        .foregroundColor(Color.white)
                                    Spacer()
                                }
                               
                                
                            }
                            .frame(height: 5000*scale)
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
     
                        }
                        .frame(maxHeight: .infinity)
                        .frame(width: 20)

                        .background(Color.white)
                        .border(Color.black, width: 1)
                        
                        
                        
                        Scrollview2d( contentwidth: $contentwidth, scrollOffsetx: $scrollOffsetx, currentOffsetx: $currentOffsetx,
                                      contentHeight: $contentHeight, scrollOffsety: $scrollOffsety, currentOffsety: $currentOffsety,
                                      isDragging: $isDraggingIn, scale: $scale){
                            
                            VStack{
                                if isDraggable{
                                    ZStack{
                                        canvasContent //
                                    }
                                    .frame(width: 5000 )
                                    .frame(height: 5000 )
                                    .border(.gray, width: 1)
                                    .background(Color.black)
                                    .scaleEffect(1, anchor: .center)
                                    .onTapGesture{ value in
                                        
                                        /* /// for simple rectangle
                                        var xVal:CGFloat = value.x
                                        var yVal:CGFloat = value.y
                                        
                                        xVal = ceil(xVal)
                                        yVal = ceil(yVal)
                                        
                                        lengthWidthDisplay.x = ((value.x ) )
                                        lengthWidthDisplay.y = ((value.y ) )
                                        
                                        rooms.append(Room(length: 0, width: 0, offsetx: (xVal - 2500), offsety: ((yVal - 2500 ) * -1)))
                                        
                                        print("x: \(rooms[rooms.count - 1].getOffsetX() )")
                                        print("y: \( rooms[rooms.count - 1].getOffsetY() )")
                                        
                                        started = true
                                         */
                                        
                                        if !started{
                                            var xVal:CGFloat = value.x
                                            var yVal:CGFloat = value.y
                                            
                                            xVal = ceil(xVal)
                                            yVal = ceil(yVal)
                                            
                                            lengthWidthDisplay.x = ((value.x ) )
                                            lengthWidthDisplay.y = ((value.y ) )
                                            
                                            structure.walls.append(Vertex( x: (xVal - 2500), y: ((yVal - 2500 ) * -1)))
                                            
                                            print("x: \(structure.walls[structure.walls.count - 1].x )")
                                            print("y: \( structure.walls[structure.walls.count - 1].y )")
                                            
                                            started = true
                                        } else {
                                            var xVal:CGFloat = value.x
                                            var yVal:CGFloat = value.y
                                            
                                            xVal = ceil(xVal)
                                            yVal = ceil(yVal)
                                            
                                            lengthWidthDisplay.x = ((value.x ) )
                                            lengthWidthDisplay.y = ((value.y ) )
                                            
                                            structure.walls.append(Vertex( x: (xVal - 2500), y: ((yVal - 2500 ) * -1)))
                                            
                                            print("x: \(structure.walls[structure.walls.count - 1].x )")
                                            print("y: \( structure.walls[structure.walls.count - 1].y )")
                                            print("size: \(structure.walls.count)")
                                        }
                                        
                                    }
                                    .onTapGesture(count: 2){ value in
                                        started = false
                                    }
                                    //.gesture( simpleDrag )
                                } else {
                                    ZStack{
                                        canvasContent
                                    }
                                    .frame(width: 5000  )
                                    .frame(height: 5000 )
                                    .border(.gray, width: 1)
                                    .background(Color.black)
                                    .scaleEffect(1, anchor: .center)
                                    
                                }
                            }.scaleEffect(scale)
                            
                            
                            
                            
                        }
                        .zIndex(0)
                        
                    }
                }

               
                    
               
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .background(Color.black)
            
        
        
    }
}


struct vertexPathMaker: View{
        
    //var index:Int
    @Binding var structure:StructureVertex
    let origin:Origin
   // @Binding var currentIndex:Int
    @Binding var isDraggable:Bool
    
    @State var widthWall:CGFloat = 8

    var extrude:CGFloat = 10

    
    var body: some View{
        
        ZStack{
            
            if true{
                /* // for vertex buttons
                
                ZStack{
                    VStack{
                        Image(systemName: "moonphase.new.moon")
                    }.frame(width: 10, height: 10)
                    .background(Color.red)
                    .position(x: origin.x + rooms[index].localOffsetx , y: origin.y + ( -1.0 * rooms[index].getOffsetY() ))
                    
                    VStack{
                        Image(systemName: "moonphase.new.moon")
                    }.frame(width: 10, height: 10)
                    .background(Color.red)
                    .position(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength(), y: origin.y + (  -1.0 * rooms[index].getOffsetY()))
                    
                    VStack{
                        Image(systemName: "moonphase.new.moon")
                    }.frame(width: 10, height: 10)
                    .background(Color.red)
                    .position(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength(), y: origin.y + ( -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth())))
                    
                    VStack{
                        Image(systemName: "moonphase.new.moon")
                    }.frame(width: 10, height: 10)
                    .background(Color.red)
                    .position(x: origin.x + rooms[index].getOffsetX(), y: origin.y + (  -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth())))
                              
                }
                .zIndex(4)
                */
                /* for red line on selected wall
                Path { path in
                    
                    path.move(   to: CGPoint(x: origin.x + rooms[index].localOffsetx ,
                                             y: origin.y + ( -1.0 * rooms[index].getOffsetY() )))
                    path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength(),
                                             y: origin.y + (  -1.0 * rooms[index].getOffsetY())))
                    path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX() + rooms[index].getLength(),
                                             y: origin.y + ( -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth()))))
                    path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX(),
                                             y: origin.y + (  -1.0 * (rooms[index].getOffsetY() + rooms[index].getWidth()))))
                    path.addLine(to: CGPoint(x: origin.x + rooms[index].getOffsetX(),
                                             y: origin.y +  (  -1.0 * rooms[index].getOffsetY())))
                    path.closeSubpath()
                }
                .stroke(Color.red, lineWidth: 1)
                .zIndex(3)
                */
                        
            }
            
            // inner guide line
            Path{ path in
                
                 if structure.walls.count > 1{
                    
                    path.move(   to: CGPoint(x: origin.x + structure.walls[0].x ,
                                             y: origin.y + structure.walls[0].y * -1))
                    
                    for i in 1..<structure.walls.count{
                        
                        path.addLine(to: CGPoint(x: origin.x + structure.walls[i].x ,
                                                 y: origin.y + structure.walls[i].y * -1))
                        print("hello")
                        
                    }
                    
                    
                }
               
                //path.closeSubpath()
            }
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
            .zIndex(0.2)

        
  
            
            // wall pathing
            Path { path in
                
                if structure.walls.count > 1{
                    
                    path.move(   to: CGPoint(x: origin.x + structure.walls[0].x + getOffset(lix: structure.walls[0].x ,
                                                                                            lfx: structure.walls[1].x,
                                                                                            liy: structure.walls[0].y ,
                                                                                            lfy: structure.walls[1].y,
                                                                                            axis: "x", A: 10),
                                             y: origin.y + (structure.walls[0].y * -1) +  getOffset(lix: structure.walls[0].x ,
                                                                                                    lfx: structure.walls[1].x,
                                                                                                    liy: structure.walls[0].y ,
                                                                                                    lfy: structure.walls[1].y ,
                                                                                                    axis: "y", A: 10) ))
                    
                    path.addLine(   to: CGPoint(x: origin.x + structure.walls[1].x + getOffset(lix: structure.walls[0].x ,
                                                                                            lfx: structure.walls[1].x,
                                                                                            liy: structure.walls[0].y ,
                                                                                            lfy: structure.walls[1].y,
                                                                                            axis: "x", A: 10),
                                             y: origin.y + (structure.walls[1].y * -1) +  getOffset(lix: structure.walls[0].x ,
                                                                                                    lfx: structure.walls[1].x,
                                                                                                    liy: structure.walls[0].y ,
                                                                                                    lfy: structure.walls[1].y ,
                                                                                                    axis: "y", A: 10) ))
                    for i in 1..<structure.walls.count{
                        
                        if structure.walls.count > i+1{
                            
                            print(" available node: \(i)")
                            
                            // this will be calculated with before index
                            path.addLine(   to: CGPoint(x: origin.x + structure.walls[i].x + getOffset(lix: structure.walls[i].x ,
                                                                                                       lfx: structure.walls[i+1].x,
                                                                                                       liy: structure.walls[i].y ,
                                                                                                       lfy: structure.walls[i+1].y ,
                                                                                                       axis: "x", A: 10),
                                                     y: origin.y + (structure.walls[i].y * -1) + getOffset(lix: structure.walls[i].x ,
                                                                                                           lfx: structure.walls[i+1].x,
                                                                                                           liy: structure.walls[i].y ,
                                                                                                           lfy: structure.walls[i+1].y ,
                                                                                                           axis: "y", A: 10))) // avacado
                            
                            
                            
                            path.addLine(   to: CGPoint(x: origin.x + structure.walls[i+1].x + getOffset(lix: structure.walls[i].x ,
                                                                                                             lfx: structure.walls[i+1].x,
                                                                                                             liy: structure.walls[i].y ,
                                                                                                             lfy: structure.walls[i+1].y ,
                                                                                                             axis: "x", A: 10),
                                                         y: origin.y + (structure.walls[i+1].y * -1) + getOffset(lix: structure.walls[i].x ,
                                                                                                                 lfx: structure.walls[i+1].x,
                                                                                                                 liy: structure.walls[i].y ,
                                                                                                                 lfy: structure.walls[i+1].y ,
                                                                                                                 axis: "y", A: 10)))
                            
                        } else {
                            print(" last node: \(i)")
                            
                            path.addLine(   to: CGPoint(x: origin.x + structure.walls[i].x,
                                                     y: origin.y + (structure.walls[i].y * -1)))
                        }
                    }
                }
            }
            .stroke(Color.white, lineWidth: 1)
            .zIndex(1)
            
            Path { path in
                
                if structure.walls.count > 1{
                    
                    path.move(   to: CGPoint(x: origin.x + structure.walls[0].x - getOffset(lix: structure.walls[0].x ,
                                                                                            lfx: structure.walls[1].x,
                                                                                            liy: structure.walls[0].y ,
                                                                                            lfy: structure.walls[1].y,
                                                                                            axis: "x", A: 10),
                                             y: origin.y + (structure.walls[0].y * -1) -  getOffset(lix: structure.walls[0].x ,
                                                                                                    lfx: structure.walls[1].x,
                                                                                                    liy: structure.walls[0].y ,
                                                                                                    lfy: structure.walls[1].y ,
                                                                                                    axis: "y", A: 10) ))
                    
                    path.addLine(   to: CGPoint(x: origin.x + structure.walls[1].x - getOffset(lix: structure.walls[0].x ,
                                                                                            lfx: structure.walls[1].x,
                                                                                            liy: structure.walls[0].y ,
                                                                                            lfy: structure.walls[1].y,
                                                                                            axis: "x", A: 10),
                                             y: origin.y + (structure.walls[1].y * -1) -  getOffset(lix: structure.walls[0].x ,
                                                                                                    lfx: structure.walls[1].x,
                                                                                                    liy: structure.walls[0].y ,
                                                                                                    lfy: structure.walls[1].y ,
                                                                                                    axis: "y", A: 10) ))
                    for i in 1..<structure.walls.count{
                        
                        if structure.walls.count > i+1{
                            
                        
                            path.addLine(   to: CGPoint(x: origin.x + structure.walls[i].x - getOffset(lix: structure.walls[i].x ,
                                                                                                       lfx: structure.walls[i+1].x,
                                                                                                       liy: structure.walls[i].y ,
                                                                                                       lfy: structure.walls[i+1].y ,
                                                                                                       axis: "x", A: 10),
                                                     y: origin.y + (structure.walls[i].y * -1) - getOffset(lix: structure.walls[i].x ,
                                                                                                           lfx: structure.walls[i+1].x,
                                                                                                           liy: structure.walls[i].y ,
                                                                                                           lfy: structure.walls[i+1].y ,
                                                                                                           axis: "y", A: 10))) // avacado
                            
                            path.addLine(   to: CGPoint(x: origin.x + structure.walls[i+1].x - getOffset(lix: structure.walls[i].x ,
                                                                                                         lfx: structure.walls[i+1].x,
                                                                                                         liy: structure.walls[i].y ,
                                                                                                         lfy: structure.walls[i+1].y ,
                                                                                                         axis: "x", A: 10),
                                                     y: origin.y + (structure.walls[i+1].y * -1) - getOffset(lix: structure.walls[i].x ,
                                                                                                             lfx: structure.walls[i+1].x,
                                                                                                             liy: structure.walls[i].y ,
                                                                                                             lfy: structure.walls[i+1].y ,
                                                                                                             axis: "y", A: 10)))
    
                        } else {
                            path.addLine(   to: CGPoint(x: origin.x + structure.walls[i].x,
                                                     y: origin.y + (structure.walls[i].y * -1)))
                        }
                    }
                }
            }
            .stroke(Color.white, lineWidth: 1)
            .zIndex(1)
                           
                //path.closeSubpath()
        }
    
    }
    
    func getOffset( lix:CGFloat, lfx:CGFloat, liy:CGFloat, lfy:CGFloat,
                     axis:String , A:CGFloat /*, prevX:CGFloat, prevY:CGFloat,
                    nextX:CGFloat, nextY:CGFloat */ )-> CGFloat{
        
        
        // normalize
        
        let liyI = abs(liy)
        let lfyI = abs(lfy)
        let lixI = abs(lix)
        let lfxI = abs(lfx)
        
        var hieght:CGFloat
        var width:CGFloat
        
        var axisX:Int = 1
        var axisY:Int = 1
        
        if lix < 0 {
            if lfx > 0 {
                width = lfx + abs(lix)
                axisX = 1
            } else if lfx < 0 {
                width = abs(lix - lfx)
                if lfx > lix {
                    axisX = 1
                } else {
                    axisX = 0
                }
            }else {
                width = 0
            }
        } else if lix > 0 {
            if lfx < 0 {
                width = abs(lfx) + lix
                axisX = 0
            } else if lfx > 0 {
                width = abs(lix - lfx)
                if lfx > lix {
                    axisX = 1
                } else {
                    axisX = 0
                }
                
            }else {
                width = 0
            }
        } else {
            width = 0
        }
        
        if liy < 0 {
            if lfy > 0 {
                hieght = lfy + abs(liy)
                axisY = 1
            } else if lfy < 0 {
                hieght = abs(liy - lfy)
                if lfy > liy {
                    axisY = 1
                } else {
                    axisY = 0
                }
               
            }else {
                hieght = 0
            }
        } else if liy > 0 {
            if lfy < 0 {
                hieght = abs(lfy) + liy
                axisY = 0
            } else if lfy > 0 {
                hieght = abs(liy - lfy)
                if lfy > liy {
                    axisY = 1
                } else {
                    axisY = 0
                }
            }else {
                hieght = 0
            }
        } else {
            hieght = 0
        }
        
        
        if lfyI - liyI == 0 {
            
            if axis == "x"{
                
                if lfx - lix  > 0{
                    return A
                } else {
                    return A * -1
                }
                
            } else{
                return 0.0
                
            }
        } else if lfxI - lixI == 0 {
            
            if axis == "y"{
                
                if lfyI - liyI > 0{
                    return A
                } else {
                    return A * -1
                }
                
            } else{
                return 0.0
                
            }
        } else {
            
            //oY = wY +/- sin( 90 - arctan( ( abs(Liy - Lfy))/( abs(Lix - Lfx) ) )) * A
            //oX = wX +/- cos( 90 - arctan( ( abs(Liy - Lfy))/( abs(Lix - Lfx) )  )) * A
            
            //print("-------------------------")
            //print ( "triangle widht: \( width) ")
            //print ( "triangle height: \( hieght) ")
            let fraction:CGFloat = hieght/width
            let arctan = ( atan(fraction ) * 180 ) / Double.pi
            let degree = 90 - arctan
            //print ( "degree: \( degree) ")
            let cosine:CGFloat = cos( (degree  * Double.pi) / 180 ) * A
            let sine:CGFloat = sin( (degree  * Double.pi) / 180 ) * A
            
            
            
            if axisX  == 1 && axisY == 0{
                // bottom right
                
                //print("bottom right ")
                
                if axis == "x"{
                
                    return cosine
                    
                } else {
                    
                    return sine * -1
                    
                }
                
            } else if axisX  == 1 && axisY == 1 {
                // top right
                //print("top right ")
                
                if axis == "x"{
                    
                    return cosine * -1
                    
                } else {
                    
                    return sine * -1
                    
                }
                
            } else if axisX  == 0 && axisY == 0 {
                // bottom left
                //print("bottom left ")
               
                if axis == "x"{

                    return cosine
                    
                } else {

                    return sine
                    
                }
                
            } else {
                // top left
                //print("top left ")
                
                if axis == "x"{

                    return cosine * -1
                    
                } else {

                    return sine
                    
                }
                
            }
            
        }
        
    }
    
    
}




struct Origin{
    let x:CGFloat = 2500
    let y:CGFloat = 2500
}




struct ContentView: View {
    
    @State var isDraggable:Bool = false
    let origin:Origin = Origin()
    
    @State var rooms:[Room] = []
    
    @State var scale:CGFloat = 1
    
    @State var structure:StructureVertex = StructureVertex()
    
    var body: some View {
        VStack {
                
                VSplitView{
                    HStack{
                        Text("hello")
                    } .frame(maxWidth: .infinity)
                        .frame(maxHeight: 100)
                    HSplitView{
                      
                        VStack{
                            HStack{
                                Button {
                                    isDraggable.toggle()
                                } label: {
                                    Text("mode")
                                }
                                
                                Button {
                                    var number = scale
                                    number = number + 0.1
                                    if number > 1.5{
                                        number = 1.5
                                    }
                                    scale = number
                                } label: {
                                    Text("+")
                                }

                                
                                Button {
                                    var number = scale
                                    number = number - 0.1
                                    if number < 0.5{
                                        number = 0.5
                                    }
                                    scale = number
                                } label: {
                                    Text("-")
                                }


                            }
                            
                            ScrollView{
                                VStack{
                                    ForEach(0..<rooms.count, id: \.self ) { i in
                                        HStack{
                                            Text("\(rooms[i].getOffsetX())")
                                            Text(" \( rooms[i].getOffsetY())")
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                            
                            
                            
                        }
                            .frame(maxWidth: 450)
                            .frame(maxHeight: .infinity)
                        canvasView(origin: origin, rooms: $rooms, isDraggable: $isDraggable, structure: $structure, scale: $scale)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    
                   
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                
                HStack{
                    Text("hello")
                } .frame(maxWidth: .infinity)
                    .frame(height: 50)

            

            
        }
    }
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Walls{
    
private
    var thickNess:CGFloat
    var height:CGFloat
    var joints:[Int] // index of parent list
    var localOffsetx:CGFloat
    var localOffsety:CGFloat
    
}

struct Joints{
    
private
    var walls:[Int] // index of parent list
   
    
}

struct Room{
    
private
    var length:CGFloat
    var width:CGFloat
    //var walls:[Walls]
    //var joints:[Joints]
    var localOffsetx:CGFloat
    var localOffsety:CGFloat
    
public
    
    init(length:CGFloat, width:CGFloat, offsetx:CGFloat, offsety:CGFloat){
        self.length = length
        self.width = width
        self.localOffsetx = offsetx
        self.localOffsety = offsety
    }
    
    func getLength() -> CGFloat{ return length}
    mutating func setLength(_ l:CGFloat) -> Void { self.length = l}
    
    func getWidth() -> CGFloat{ return width}
    mutating func setWidth(_ l:CGFloat) -> Void { self.width = l}
    
    func getOffsetX() -> CGFloat{ return localOffsetx}
    mutating func setOffsetX(_ l:CGFloat) -> Void { self.localOffsetx = l}
    
    func getOffsetY() -> CGFloat{ return localOffsety}
    mutating func setOffsetY(_ l:CGFloat) -> Void { self.localOffsety = l}
    
}

struct Structure{
    
private
    var rooms:[Room]
    var joints:[Joints]
    var localOffsetx:CGFloat
    var localOffsety:CGFloat
    
}





struct ScrollviewX<Content>: View where Content: View {
    
    // vairables for x

    @Binding  var contentwidth: CGFloat
    @Binding  var scrollOffsetx: CGFloat
    @Binding  var currentOffsetx: CGFloat
        
    @State var dragable:Bool = true
    @State var isDragging:Bool = true
    @State var scrollDrgain:Bool = true
    
    var content: () -> Content
        
    // Calculate content offset x
    func offsetx(outerwidth: CGFloat, innerwidth: CGFloat) -> CGFloat {
       
        let totalOffset = currentOffsetx  + scrollOffsetx - outerwidth/2
        return -((innerwidth/2 - outerwidth/2  ) - totalOffset)
    }
    
    var body: some View {
        
       
        
        GeometryReader{ outerGeometry in
            // Render the content
            //  ... and set its sizing inside the parent
            self.content()
            .modifier(ViewHeightKey2())
            .onPreferenceChange(ViewHeightKey2.self) { self.contentwidth = $0 }
            .frame(width: outerGeometry.size.width)
            .offset(x: self.offsetx(outerwidth: outerGeometry.size.width, innerwidth: self.contentwidth))
           
            
            .clipped()
            //.animation(.easeOut)
            .contentShape(Rectangle())
            .gesture(
                 DragGesture()
                    
                    .onChanged({
                        if self.dragable{
                            self.onDragChangedx($0)
                        }
                    })
                    .onEnded({
                        
                        if self.dragable{
                            self.onDragEndedx($0, outerwidth: outerGeometry.size.width)
                        }
                      
                        
                    }))
        }
        
    }
    
    func onDragChangedx(_ value: DragGesture.Value) {
        // Update rendered offset
        
        self.scrollOffsetx = (value.location.x - value.startLocation.x)
        self.isDragging =  true
        self.scrollDrgain = true
    }
    
    func onDragEndedx(_ value: DragGesture.Value, outerwidth: CGFloat) {
        // Update view to target position based on drag position
        let scrollOffset = value.location.x - value.startLocation.x
       
        
        let topLimit = self.contentwidth - outerwidth/2
        
        // Negative topLimit => Content is smaller than screen size. We reset the scroll position on drag end:
        if topLimit < 0 {
             self.currentOffsetx = 0
        } else {
            // We cannot pass bottom limit (negative scroll)
            if self.currentOffsetx + scrollOffset <  outerwidth/2 {
                self.currentOffsetx =  outerwidth/2
            } else if self.currentOffsetx + scrollOffset > topLimit {
                self.currentOffsetx = topLimit
            } else {
                self.currentOffsetx += scrollOffsetx
            }
        }
    
        self.scrollOffsetx = 0
        self.isDragging =  false
        self.scrollDrgain = false


    }
}


struct ScrollviewY<Content>: View where Content: View {
    
    // variables for Y
    @Binding  var contentHeight: CGFloat
    @Binding  var scrollOffsety: CGFloat
    @Binding  var currentOffsety: CGFloat
    
    
    @State var dragable:Bool = true
    @State var isDragging:Bool = true
    @State var scrollDrgain:Bool = true
    
    var content: () -> Content
    
    //cal ofset y
    func offsety(outerheight: CGFloat, innerheight: CGFloat) -> CGFloat {
        
        let totalOffset = currentOffsety  + scrollOffsety - outerheight/2
        return -((innerheight/2 - outerheight/2 ) - totalOffset)
    }
    

    
    var body: some View {
        
       
        
        GeometryReader{ outerGeometry in
            // Render the content
            //  ... and set its sizing inside the parent
            self.content()
           
            .modifier(ViewHeightKey1())
            .onPreferenceChange(ViewHeightKey1.self) { self.contentHeight = $0 }
            .frame(height: outerGeometry.size.height)
            .offset(y: self.offsety(outerheight: outerGeometry.size.height, innerheight: self.contentHeight))
           
            .clipped()
            //.animation(.easeOut)
            .contentShape(Rectangle())
            .gesture(
                 DragGesture()
                    .onChanged({
                        if self.dragable{
                            self.onDragChangedy($0)
                        }
                    })
                  
                    .onEnded({
                        if self.dragable {
                            self.onDragEndedy($0, outerHeight: outerGeometry.size.height)
                        }
                        
                        
                    }))
        }
        
    }
    func onDragChangedy(_ value: DragGesture.Value) {
        // Update rendered offset
        
        self.scrollOffsety = (value.location.y - value.startLocation.y)
        self.isDragging =  true
        self.scrollDrgain = true
    }
    
    func onDragEndedy(_ value: DragGesture.Value, outerHeight: CGFloat) {
        // Update view to target position based on drag position
        let scrollOffset = value.location.y - value.startLocation.y
 
        let topLimit = self.contentHeight - outerHeight/2
        
        
        // Negative topLimit => Content is smaller than screen size. We reset the scroll position on drag end:
        if topLimit < 0 {
             self.currentOffsety = 0
        } else {
            // We cannot pass bottom limit (negative scroll)
            if self.currentOffsety + scrollOffset < outerHeight/2 {
                self.currentOffsety = outerHeight/2
            } else if self.currentOffsety + scrollOffset > topLimit {
                self.currentOffsety = topLimit
            } else {
                self.currentOffsety += scrollOffset
            }
        }
        self.scrollOffsety = 0
        self.scrollDrgain = false
      
        self.isDragging =  false
    }
    

}

struct Vertex{
    var x:CGFloat
    var y:CGFloat
    
    init(x:CGFloat, y: CGFloat){
        self.x = x
        self.y = y
    }
}


struct StructureVertex{
    
    var walls:[Vertex]
    
    init() {
        self.walls = []
    }
    
    
    
}
