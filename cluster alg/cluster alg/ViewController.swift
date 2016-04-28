//
//  ViewController.swift
//  cluster alg
//
//  Created by Gleb on 4/26/16.
//  Copyright © 2016 . All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView = UIScrollView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height - 50))
        self.scrollView.contentSize = CGSize(width: 2000, height: 2000)
        self.view.addSubview(self.scrollView)
        self.loadData()
        runLoop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        let url = NSBundle.mainBundle().URLForResource("json data", withExtension: "json")
        
        do {
            let jsonData = try NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
            if let jsonArray = json as? [AnyObject] {
                var atoms: [Atom] = []
                for atomData in jsonArray {
                    if let dict = atomData as? [String: AnyObject] {
                        if let x = dict["x"] as? Double, y = dict["y"] as? Double, name = dict["name"] as? String {
                            let atom = Atom(x: x, y: y, name: name)
                            atoms.append(atom)
                        }
                    }
                }
                atoms.sortInPlace({ (first, second) -> Bool in
                    return first.x < second.x
                })
                
                let viewManager = ViewManager.shared
                viewManager.view = self.scrollView
                viewManager.drawSlider(self.view)
                
                
                let mainManager = MainManager.shared
                mainManager.accuracy = 3
                mainManager.zoomValue = 0.001
                mainManager.atoms = atoms
                mainManager.generateManagersDataSource()
            }
            
        } catch {
            print(error)
        }
    }
    var timer: NSTimer?
    func runLoop() {
        let loop = NSRunLoop.currentRunLoop()
        timer = NSTimer(timeInterval: 0.001, target: self, selector: #selector(ViewController.changeZoom), userInfo: nil, repeats: true)
        loop.addTimer(timer!, forMode: NSRunLoopCommonModes)
        timer!.fire()
    }
    
    var incrementor = 0.001
    func changeZoom() {
        if incrementor >= 20 {
            timer?.invalidate()
        }
        let mainManager = MainManager.shared
        mainManager.zoomValue = incrementor
        mainManager.processData()
        let viewManager = ViewManager.shared
        viewManager.zoom = incrementor
        if incrementor <= 2 {
            incrementor += 0.05
        } else if incrementor <= 8 {
            incrementor += 0.1
        } else {
            incrementor += 0.14
        }
    }
}

