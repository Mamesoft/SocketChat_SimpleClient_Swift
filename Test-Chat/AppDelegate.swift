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
    @IBOutlet weak var inoutButton: NSButton!
    @IBOutlet weak var usersTextField: NSTextField!
    @IBOutlet weak var hashtagTextField: NSTextField!

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        socketIO = SocketIO(delegate: self)
        socketIO.connectToHost("localhost", onPort: 8080) //Connect Host
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
                edituser(value)
            }
            showusers()
            
        case "newuser":
            println("newuser")
            edituser(data)
            showusers()
            
        case "inout":
            println("inout")
            edituser(data)
            showusers()
            
        case "deluser":
            println("deluser")
            users.removeValueForKey(data.integer!)
            showusers()
            
        case "userinfo":
            println("userinfo")
            var rom = data["rom"].bool!
            if(rom == true){
                inoutButton.title = "In"
                inoutTextField.enabled = true
                
            }else{
                inoutButton.title = "Out"
                inoutTextField.enabled = false
            }
            
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
    
    func edituser(data: JSONValue) {
        users[data["id"].integer!] = data
    }
    
    func showlogs(){
        var logstring = ""
        for log: Dictionary<String, String> in logs{
            logstring = log["name"]! + "> " + log["comment"]! + " ( " + log["ip"]! + ", " + log["time"]! + " )\n" + logstring
        }
        logTextView.string = logstring
    }
    
    func showusers(){
        var romusers: [JSONValue] = []
        var onlineusers: [JSONValue] = []
        for (id, user) in users{
            var rom: Bool = user["rom"].bool!
            if(rom == true){
                romusers.append(user)
                
            }else{
                onlineusers.append(user)
            }
        }
        var userstring = "Online(\(onlineusers.count)): "
        for user: JSONValue in onlineusers{
            userstring += user["name"].string! + "(" + user["ip"].string! + "), "
        }
        userstring += "Rom(\(romusers.count))"
        
        usersTextField.stringValue = userstring
    }
    
    @IBAction func inout(sender: AnyObject) {
        socketIO.sendEvent("inout", withData: ["name": inoutTextField.stringValue])
    }
    
    @IBAction func commentTextFieldReturn(sender: NSTextField) {
        socketIO.sendEvent("say", withData: ["comment": commentTextField.stringValue, "channel": hashtagTextField.stringValue])
        commentTextField.stringValue = ""
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }

}

