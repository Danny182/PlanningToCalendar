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
        let nameWithoutSpaces = name.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "'", with: "")
        let file = "\(nameWithoutSpaces).ics" //this is the file. we will write to and read from it
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
                    updateFile(events: events, name: nameWithoutSpaces, department: department, fileURL: fileURL)
                } else {
                    // file .ics of that person didn't exists, going to create it
                    createFile(events: events, name: nameWithoutSpaces, department: department, path: path)
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
            createFile(events: events, name: nameWithoutSpaces, department: department, path: path)
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
        
        let data = try! Data(contentsOf: fileURL)
        
//        MyFileUploader.shared.upload(fileURL: fileURL)
        print(file)
        let uploadService = FTPUpload(baseUrl: "ftp.planning.altervista.org", userName: "planning", password: "pazpih-zetvUj-tymwu5", directoryPath: "servizi")
        uploadService.send(data: data, with: file) { (success) in
            print(success)
        }
    }
    
    func updateFile(events: [Event], name: String, department: String, fileURL: URL) {
        print("already exists \(name)")
        let file = "\(name).ics" //this is the file. we will write to and read from it

        
        let cals = try! iCal.load(url: fileURL)
        var cal = cals.first
        
        //scan old calendar, if it finds old events of the same month it will delete them from the old calendar
        let monthImAdding = events.first?.dtstart?.getMonth()
        cal?.subComponents.removeAll { 
            (($0 as? Event)?.dtstart?.getMonth())! == monthImAdding 
        }
//        for (index, event) in (cal!.subComponents).enumerated() where event is Event {
//            let eventMonth = (event as! Event).dtstart?.getMonth()
//            if eventMonth == events.first?.dtstart?.getMonth() {
//                cal?.subComponents.removeAll(where: (event as! Event).dtstart?.getMonth() = eventMonth)
//            }
//        }
        
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
        
        let data = try! Data(contentsOf: fileURL)
        
        
        
        let uploadService = FTPUpload(baseUrl: "ftp.planning.altervista.org", userName: "planning", password: "pazpih-zetvUj-tymwu5", directoryPath: "servizi")
        uploadService.send(data: data, with: file) { (success) in
            print(success)
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

extension Date {
    func getMonth() -> Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: self)
        
        let month = components.month
        
        return month
    }
}
