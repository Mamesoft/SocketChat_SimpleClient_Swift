//
//  AppDelegate.swift
//  Test-Chat
//
//  Copyright (c) 2014年 Mamesoft. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, SocketIODelegate {
    var socketIO: SocketIO!
                            
    @IBOutlet weak var window: NSWindow!

    
    @IBOutlet weak var inoutTextField: NSTextField!
    @IBOutlet weak var commentTextField: NSTextField!
    @IBOutlet var logTextView: NSTextView!

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        socketIO = SocketIO(delegate: self)
        
        socketIO.connectToHost("localhost", onPort: 8080) //Connect Host
        
        
        //socketIO.sendEvent("inout", withData: ["name": "Test"])
        
        
    }
    
    
    func socketIODidConnect(socket: SocketIO) {
        socketIO.sendEvent("register", withData: ["mode": "client", "lastid": 1])
    }
    
    var users: Dictionary<Int, JSONValue> = [:]
    var logs: Array<Dictionary<String, String>> = []

    func socketIO(socket: SocketIO!, didReceiveEvent packet: SocketIOPacket!) {
        let json: AnyObject! = packet.dataAsJSON()
        let event: String = json["name"].description
        let dataany: AnyObject! = json["args"]
        let data: JSONValue = JSONValue(dataany[0])
        
        println(data)
        
        switch event{
        case "init":
            println("init")
            
            var logsjson: [JSONValue] = data["logs"].array!
            for var i = logsjson.count - 1; i >= 0; --i{
                addlog(logsjson[i])
            }
            
            showlogs()

        case "users":
            println("users")
            var usersjson: [JSONValue] = data["users"].array!
            for value in usersjson{
                users[value["id"].integer!] = value
            }
            println(users)
            
        case "newuser":
            println("newuser")
            
        case "inout":
            println("inout")
            
        case "deluser":
            println("deluser")
            
        case "userinfo":
            println("userinfo")
            
        case "log":
            println("log")
            addlog(data)
            showlogs()
            
        default:
            println("no-maching")
        }
    }
    
    func addlog(data: JSONValue) {
        logs.append( [
        "name":    data["name"].string!,
        "comment": data["comment"].string!,
        "ip":      data["ip"].string!,
        "time":    data["time"].string!,
        ] )
        
    }
    
    func showlogs(){
        var logstring = ""
        for log: Dictionary<String, String> in logs{
            logstring = log["name"]! + "> " + log["comment"]! + " ( " + log["ip"]! + ", " + log["time"]! + " )\n" + logstring
        }
        logTextView.string = logstring
    }


    @IBAction func inout(sender: AnyObject) {
        println(inoutTextField.stringValue)
        socketIO.sendEvent("inout", withData: ["name": inoutTextField.stringValue])
    }
    
    @IBAction func commentTextFieldReturn(sender: NSTextField) {
        socketIO.sendEvent("say", withData: ["comment": commentTextField.stringValue])
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }

}

