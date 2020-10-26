//
//  TMRScreen.swift
//  TMR App
//
//  Created by Robert Zhang on 6/16/17.
//  Copyright © 2017 iLaunch. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class TMRScreen : SKScene, SKPhysicsContactDelegate {
    let context = TMRContext()
    var timer : Timer? = Timer()
    var player: AVAudioPlayer!
    var audioPlayers : [String : AVAudioPlayer?] = [:]
    var viewCtrl : UIViewController?
    
    var width : CGFloat {
        get {
            return self.frame.width
        }
    }
    var height : CGFloat {
        get {
            return self.frame.height
        }
    }
    
    var imgSize : CGFloat {
        get {
            //return max(self.frame.height, self.frame.width) * 0.125
            return max(self.frame.height, self.frame.width) * 0.1
        }
    }
    
    var imgWidth: CGFloat {
        get {
            return self.frame.width / CGFloat(context.project.getGuiSetting().getNumColumns())
        }
    }
    
    var imgHeight: CGFloat {
        get {
            return self.frame.height / CGFloat(context.project.getGuiSetting().getNumRows())
        }
    }
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x:0,y:0)
        self.physicsWorld.contactDelegate = self
        
        let bg = SKSpriteNode(color: UIColor(red:40/255,green:44/255,blue:52/255,alpha:1), width: self.frame.width, height: self.frame.height, anchorPoint: CGPoint(x:0,y:0), position: CGPoint(x:0,y:0), zPosition: -2, alpha: 1)
        bg.name = "bg"
        self.addChild(bg)
        
        objc_sync_enter(self)
        // initial model
        context.model.begin(screen: self, context: context,view:view)
        // set timer interval and start timer
        timerInterval(interval: 2)
        objc_sync_exit(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in:self)
        objc_sync_enter(self)
        context.model.touch(screen: self, context: context, position: location)
        context.modelUpdate(screen: self,view:view!)
        objc_sync_exit(self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in:self)
        objc_sync_enter(self)
        context.model.touchEnd(screen: self, context: context, position: location)
        context.modelUpdate(screen: self,view:view!)
        objc_sync_exit(self)
    }
    
    func addGrid(){
        let numRows = context.project.getGuiSetting().getNumRows()
        let numCol = context.project.getGuiSetting().getNumColumns()
        let settings = context.project.getGuiSetting()
        let pictureWidth = self.frame.width / CGFloat(settings.getNumColumns())
        let pictureHeight = self.frame.height / CGFloat(settings.getNumRows())
        
        //Horizontal Lines
        for num in 0...numRows{
            let line = SKSpriteNode(
                color: .black,
                width: self.frame.width,
                height: 2,
                anchorPoint: CGPoint(x: 0.5, y: 0),
                position: CGPoint(x: self.frame.width / 2, y: pictureHeight * CGFloat(num)),
                zPosition: 1,
                alpha: 1)
            line.name = "grid"
            self.addChild(line)
        }
        
        //Vertical Lines
        for num in 0...numCol{
            let line = SKSpriteNode(
                color: .black,
                width: 2,
                height: self.frame.width,
                anchorPoint: CGPoint(x: 0, y: 0.5),
                position: CGPoint(x: pictureWidth * CGFloat(num),
                                  y: self.frame.height / 2),
                zPosition: 1,
                alpha: 1)
            line.name = "grid"
            self.addChild(line)
        }
    }
    
    func addColor(){
        let numRows = context.project.getGuiSetting().getNumRows()
        let numCol = context.project.getGuiSetting().getNumColumns()
        let pictureWidth = self.frame.width / CGFloat(numCol)
        let pictureHeight = self.frame.height / CGFloat(numRows)
        
        for num in 0...Int(round(Double(numRows) / 2)){
            let node = SKSpriteNode(
                color: UIColor(red: 128 / 255, green: 0, blue: 0, alpha: 1),
                width: self.frame.width,
                height: pictureHeight,
                anchorPoint: CGPoint(x: 0, y: 0),
                position: CGPoint(x: 0, y: CGFloat(2 * num) * pictureHeight),
                zPosition: -1,
                alpha: 1)
            node.name = "color"
            self.addChild(node)
        }
        
        for num in 0...Int(round(Double(numCol) / 2)){
            let node = SKSpriteNode(
                color: UIColor(red: 70 / 255, green: 70 / 255, blue: 70 / 255, alpha: 1),
                width: pictureWidth,
                height: self.frame.height,
                anchorPoint: CGPoint(x: 0, y: 0),
                position: CGPoint(x: CGFloat(2 * num) * pictureWidth, y: 0),
                zPosition: 0,
                alpha: 1)
            node.name = "color"
            self.addChild(node)
        }
    }
    
    @objc func timerTick(){
        objc_sync_enter(self)
        context.model.timerTick(screen: self, context: context)
        context.modelUpdate(screen: self,view:view!)
        objc_sync_exit(self)
    }
    
    func clearScreen() {
        for node in self.children{
            if node.name != "bg" {
                node.removeFromParent()
            }
        }
    }
    
    func clearNode(_ name:String){
        for node in self.children{
            if node.name == name {
                node.removeFromParent()
            }
        }
    }
    
    func addImage(image: String, position: CGPoint, name : String, visible: Bool = true){
        let texture = SKTexture(imageNamed: image)
        let imgNode = SKSpriteNode(texture: texture, color: .clear, size: texture.size())
        imgNode.position = CGPoint(x: position.x - texture.size().width / 2.0,
                                   y: position.y - texture.size().height / 2.0)
        imgNode.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        imgNode.alpha = 1.0
        imgNode.zPosition = 1
        imgNode.name = name
        self.addChild(imgNode)
    }
    
    func addLabel(text: String,
                  position: CGPoint,
                  name: String,
                  fontSize: CGFloat = 40,
                  fontColor: UIColor = UIColor(red: 97/255, green: 175/255, blue: 175/255, alpha: 1),
                  fontName: String = "Arial Bold"){
        let label = SKLabelNode(position: CGPoint(x: position.x, y: position.y),
                                zPosition: 4,
                                text: text,
                                fontColor: fontColor,
                                fontName: fontName,
                                fontSize: fontSize,
                                verticalAlignmentMode: .center,
                                horizontalAlignmentMode: .center)
        label.name = name
        self.addChild(label)
    }
    
    func isTouched(name: String, position: CGPoint) -> Bool {
        for node in self.children{
            if node.name == name {
                return node.contains(position)
            }
        }
        return false
    }
    
    
    // position is in points
    func showImage(path: String, position: CGPoint, sound : URL, name : String = "image"){
        print("showImage: \(path) \(position)\n \(sound)")
        let settings = context.project.getGuiSetting()
        
        let node = SKSpriteNode(imageName: path,
                                //width: imgSize - 2,
                                //height: imgSize - 2,
                                width: imgWidth - 2,
                                height: imgHeight - 2,
                                anchorPoint: CGPoint(x: 0, y: 0),
                                //position: CGPoint(x: position.x - imgSize / 2 + 2,
                                //                  y: position.y - imgSize / 2 + 2),
                                position: CGPoint(x: position.x + 2,
                                                  y: position.y + 2),
                                zPosition: 1,
                                alpha: 1)
        node.name = name
        self.addChild(node)
        
        do {
            let soundLoad = try AVAudioPlayer(contentsOf: sound)
            player = soundLoad
            player.play()
        } catch {}
    }
    
    func getAudioURL(path: String) -> URL? {
        if let path = Bundle.main.path(forResource: path, ofType:nil) {
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func playSound(name: String, sound: String, repeats: Bool = false){
        let url = getAudioURL(path: sound)
        if (url != nil) {
            stopSound(name: name)
            do {
                let soundLoad = try AVAudioPlayer(contentsOf: url!)
                audioPlayers[name] = soundLoad
                if repeats {
                    soundLoad.numberOfLoops = -1
                }
                else{
                    soundLoad.numberOfLoops = 1
                }
                soundLoad.play()
            }catch{
                print("playSound: fail");
            }
        }
    }
    
    func stopSound(name: String){
        if let soundLoad = audioPlayers[name] {
            soundLoad?.stop()
            audioPlayers.removeValue(forKey: name)
        }
    }
    
    func showText(text : String, fontSize: CGFloat = 40, xPercent: Int=50, yPercent: Int=50){
        addLabel(text: text,
                 position: CGPoint(
                    x:self.frame.width*CGFloat(xPercent)/100.0,
                    y:self.frame.height*CGFloat(yPercent)/100.0),
                 name: "text",fontSize: fontSize, fontColor: UIColor(red:97/255,green:175/255,blue:175/255,alpha:1), fontName: "Arial Bold")
    }
    
    func timerInterval(interval: Double, repeats : Bool = true){
        if interval > 0 {
            timerInterval(interval: 0)
            if ( self.timer == nil ) {
                self.timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.timerTick), userInfo: nil, repeats: repeats)
            }
        }
        else {
            if ( self.timer != nil ) {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    func isTouched(pos:CGPoint, x:Int,y:Int) -> (Bool,CGFloat,CGFloat,CGFloat) {
        let dx = Float(pos.x-CGFloat(x))
        let dy = Float(pos.y-CGFloat(y))
        let d = sqrt(dx*dx+dy*dy)
        let per = d/Float(max(self.frame.width,self.frame.height))*100.0
        if per < Float(context.project.getGuiSetting().getDistanceThreshold()) {
            return (true, CGFloat(d), CGFloat(per), CGFloat(d*0.0352778) )
        }
        return (false, CGFloat(d), CGFloat(per), CGFloat(d*0.0352778))
    }
    
    func shareData(info : [Any]) {
        let actViewCtrl = UIActivityViewController(activityItems: info, applicationActivities: nil)
        actViewCtrl.popoverPresentationController?.sourceView = viewCtrl?.view
        //actViewCtrl.popoverPresentationController?.sourceRect = sender.frame
        viewCtrl!.present(actViewCtrl, animated: true, completion: nil)
    }
    
}
