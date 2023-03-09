//
//  LatencyAsyncSocketTool.swift
//  AgoraSpeedTest
//
//  Created by wanghaipeng on 2022/7/26.
//

import UIKit
import CocoaMQTT


class LatencyAsyncSocketTool: NSObject,CocoaMQTTDelegate {
    
    
    let defaultHost = "120.92.238.227"//"broker-cn.emqx.io"
    let clientID = "Agora_01"
    let userNameStr = "01GSPRKFNCYZPKDJC7R42CJQ7H"
    let passWordStr = "01GSPRKFNCYZPKDJC7R42CJQ7H/315488"
    
    
    var mqtt: CocoaMQTT?
    
    var pingFinished: ((Double) -> Void)?//获取ping数据
    
    var connectSuccess: (() -> Void)?//连接服务成功回调
    
    private var timeIdentyfierDic = [String:TimeInterval]()//存储开始时间字典
    
    var startCount : Int = 0
    
    override init() {
        super.init()
    }
    
    
    func asyncSocketOpen(){
        
        if self.mqtt != nil {
            return
        }
        
        let clientID = clientID //"CocoaMQTT-\(animal!)-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: defaultHost, port: 11883)//1883
        
        mqtt!.logLevel = .debug
        mqtt!.username = userNameStr
        mqtt!.password = passWordStr
        mqtt!.willMessage = CocoaMQTTMessage(topic: "/will", string: "dieout")
        mqtt!.keepAlive = 60
        mqtt!.delegate = self

    }
    
    func asyncSocketConnect(){
 
        _ = mqtt!.connect()
        
    }
    
    func cancel(){
        
        if self.mqtt != nil {
            mqtt?.disconnect()
            mqtt = nil
        }
    }
    
    func sendData(_ countNum : Int){
        
        let message = "test data"

        let publishProperties = MqttPublishProperties()
        publishProperties.contentType = "JSON"
        let ret =  mqtt!.publish("chat/room/animals/client/", withString: message, qos: .qos1 ,retained:true)
        
        print("---666---%i",ret)
        
        if startCount == 0{
            startCount = countNum
        }
        let tempKey = 100 + (countNum)
        timeIdentyfierDic["\(tempKey)"] = Date().milliStamp
        print("----tempKey = " , "\(tempKey)")
  
    }
    
    
    // Optional ssl CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        TRACE("trust: \(trust)")
        completionHandler(true)
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        TRACE("ack: \(ack)")

        if ack == .accept {
            print("连接成功")
            mqtt.subscribe("chat/room/animals/client/+", qos: CocoaMQTTQoS.qos1)
            connectSuccess?()

        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        TRACE("new state: \(state)")
    }
    

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        TRACE("message: \(message.string.description), id: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        TRACE("发送成功id: \(id)")
        
        let startTime = timeIdentyfierDic["\(100+startCount)"] ?? 0
        print("----end--key = " , "\(100+startCount)")
        print("----startTime--STime = " , "\(startTime)")
            
        startCount += 1
        
        let time = Date().milliStamp - startTime
        pingFinished?(time)
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        TRACE("message: \(message.string.description), id: \(id)")

    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        TRACE("subscribed: \(success), failed: \(failed)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        TRACE("topic: \(topics)")
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        TRACE()
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        TRACE()
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        TRACE("\(err.description)")
    }

}

extension LatencyAsyncSocketTool {
    func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        if names.count == 2 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }
        
        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconnect"
        }

        print("[TRACE] [\(prettyName)]: \(message)")
    }
}


extension Date {
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : TimeInterval {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
     //   let timeStamp = Int(timeInterval)
        return timeInterval
    }
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : TimeInterval {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        return timeInterval*1000
    }
}
