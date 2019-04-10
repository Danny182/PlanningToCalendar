//
//  FileManager.swift
//  Gucci Planning
//
//  Created by Daniel Zanchi on 01/06/2018.
//  Copyright © 2018 Daniel Zanchi. All rights reserved.
//

import Foundation
import iCalKit

class MyFileManager  {
    
    init() {
        
    }
    
    func createOrUpdateFile(events: [Event], name: String, department: String, path: String) {
        let file = "\(name).ics" //this is the file. we will write to and read from it
        let originalFileURL = URL(fileURLWithPath: path)
        let pathWithoutLastComp = originalFileURL.deletingLastPathComponent()
        let dir = pathWithoutLastComp.appendingPathComponent(department)
        
        let fileURL = dir.appendingPathComponent(file)
        
        var isDir: ObjCBool = true
        if FileManager.default.fileExists(atPath: dir.path, isDirectory: &isDir) {
            if isDir.boolValue {
                //directory (ex. "servizi") already exists
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    //file .ics of that person already exists, going to update it
                    updateFile(events: events, name: name, department: department, fileURL: fileURL)
                } else {
                    // file .ics of that person didn't exists, going to create it
                    createFile(events: events, name: name, department: department, path: path)
                }
            } else {
                //already exists, but it's a file
                print("file already exists, but it's not a dir")
            }
        } else {
            //directory didn't exist, going to create it
            do {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("eror creating dir")
                print(error)
            }
            createFile(events: events, name: name, department: department, path: path)
        }
    }
    
    func createFile(events: [Event], name: String, department: String, path: String) {
        let calendar = Calendar(withComponents: events)
        let content = calendar.toCal()
        
        let file = "\(name).ics" //this is the file. we will write to and read from it
        let text = content
        let originalFileURL = URL(fileURLWithPath: path)
        let pathWithoutLastComp = originalFileURL.deletingLastPathComponent()
        let dir = pathWithoutLastComp.appendingPathComponent(department)
        
        let fileURL = dir.appendingPathComponent(file)
        //writing
        do {
            try text.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch {/* error handling here */
            print("error creating file")
        }
    }
    
    func updateFile(events: [Event], name: String, department: String, fileURL: URL) {
        print("already exists \(name)")
        let cals = try! iCal.load(url: fileURL)
        let cal = cals.first
        
        var newEvents = events
        
        for evnt in cal!.subComponents where evnt is Event {
            newEvents.append(evnt as! Event)
        }
        
        let calendar = Calendar(withComponents: newEvents)
        let content = calendar.toCal()
    
        //writing
        do {
            try content.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch {/* error handling here */
            print("error creating file")
        }
        
    }
    
    func readFile(path: String) -> String{
        print(path)
        let fileURL = URL(fileURLWithPath: path)
        print(fileURL)
            //reading
            do {
                let text2 = try String(contentsOf: (fileURL), encoding: .utf8)
                return text2
            }
            catch {/* error handling here */}
//        }
        return ""
    }
    
    func replaceWithCommas(string: String) -> String {
        let s = string.replacingOccurrences(of: ";", with: ",", options: .literal, range: nil)
        return s
    }
}
