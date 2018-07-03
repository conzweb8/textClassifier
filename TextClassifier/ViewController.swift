//
//  ViewController.swift
//  TextClassifier
//
//  Created by Constantin Bandaria on 6/25/18.
//  Copyright © 2018 Green Donkey. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    let serverHost = "35.192.129.194"
    var responseString = ""
    var resultString = ""
//    let serverHost = "127.0.0.1"
    
    @IBOutlet var viewMain: NSView!
    @IBOutlet weak var progressInd: NSProgressIndicator!
    @IBOutlet weak var txtResult: NSTextField!

    @IBOutlet weak var txtTrainText: NSTextFieldCell!
    
    //Height with Train label : 375
    //Height without Train : 260
    override func viewDidLoad() {
        print("testing load...")
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func btnNotOK(_ sender: Any) {
        self.view.window?.setFrame(NSRect(x:(self.view.window?.frame.minX)!,y:(self.view.window?.frame.minY)!,width:480.0,height:395.0), display: true)

    }
    
    @IBAction func btnTrain(_ sender: Any) {
        progressInd.startAnimation(representedObject)
        progressInd.isHidden = false
        
        
        let url = URL(string: "http://\(serverHost):5000/addtrain")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "{\"text\":\"\(txtQuery.stringValue)\",\"label\":\"\(txtTrainText.stringValue)\"}"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                self.txtResult.stringValue = "error=\(String(describing: error))"
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                self.txtResult.stringValue = "statusCode should be 200, but is \(httpStatus.statusCode)"
                self.txtResult.stringValue = "response = \(String(describing: response))"
            }
            
            self.responseString = String(data: data, encoding: .utf8)!
            
            if let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                
                if let resultString = dictionary!["result"] as? String {
                    DispatchQueue.main.async() {
                        //Fill any status update here
                        //self.progressInd.stopAnimation(self.representedObject)
                        //self.progressInd.isHidden = true
                        self.txtResult.stringValue = resultString
                    }
                }
            }
            
        }
        task.resume()
        
        while (!task.progress.isFinished) {
            //print("processing...")
        }
        
        print("trying to restarted...")
        //restart apps
        let url2 = URL(string: "http://\(serverHost):5000/retrain")!
        var request2 = URLRequest(url: url2)
        request2.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request2.httpMethod = "POST"
        let postString2 = "{\"pswd\":\"tintinkeren\"}"
        request2.httpBody = postString2.data(using: .utf8)
        let task2 = URLSession.shared.dataTask(with: request2) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print ("error=\(String(describing: error))")
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                self.txtResult.stringValue = "statusCode should be 200, but is \(httpStatus.statusCode)"
                self.txtResult.stringValue = "response = \(String(describing: response))"
                print ("mestinya bener... tapi masuk error nih")
            }

            self.responseString = String(data: data, encoding: .utf8)!

            if let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {

                if let resultString = dictionary!["result"] as? String {
                    DispatchQueue.main.async() {
                        print ("bener...")
                        //self.progressInd.stopAnimation(self.representedObject)
                        //self.progressInd.isHidden = true
                        self.txtResult.stringValue = resultString
                    }
                }
            }
	
        }
        task2.resume()
        
        while (task2.progress.fractionCompleted < 0.95) {
            print("task progress fraction completed: \(task2.progress.fractionCompleted)")
        }

        if (task2.progress.fractionCompleted >= 0.95) {
            DispatchQueue.main.async() {
                self.progressInd.isHidden = true
                self.progressInd.stopAnimation(self.representedObject)

                //self.txtResult.stringValue = resultString
            }
            
            txtResult.stringValue = ""
            txtQuery.stringValue = ""
            txtTrainText.stringValue = ""
        }

    }
    
    @IBOutlet weak var txtQuery: NSTextField! {
        didSet{
            if txtResult != nil {
                DispatchQueue.main.async() {
                    self.txtResult.stringValue = "hallo"
                }
            }
        }
    }
    
    @IBAction func txtQueryAction(_ sender: NSTextFieldCell) {
        
    }
    
    @IBAction func btnGuess(_ sender: Any) {
        progressInd.startAnimation(representedObject)
        progressInd.isHidden = false
        
        txtResult.stringValue = ""
        
        let url = URL(string: "http://\(serverHost):5000/classify")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "{\"text\":\"\(txtQuery.stringValue)\"}"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                self.txtResult.stringValue = "error=\(String(describing: error))"
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                self.txtResult.stringValue = "statusCode should be 200, but is \(httpStatus.statusCode)"
                self.txtResult.stringValue = "response = \(String(describing: response))"
            }
            
            self.responseString = String(data: data, encoding: .utf8)!
            
            if let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                
                if let resultString = dictionary!["result"] as? String {
                    DispatchQueue.main.async() {
                        self.progressInd.stopAnimation(self.representedObject)
                        self.progressInd.isHidden = true
                        self.txtResult.stringValue = resultString
                    }
                }
            }
            
        }
        task.resume()
        
    }
}
