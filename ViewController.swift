//
//  ViewController.swift
//  MotionDemo
//
//  Created by wangliang-ms on 14-9-12.
//  Copyright (c) 2014年 Qihoo. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController,WLMotionManagerDelegate,MKMapViewDelegate {

    private var speedLabel: UILabel!
    private var motionBtton: UIButton!
    private var motionTypeLabel:UILabel!
    
    private var bEnable:Bool = true
    private var isRunning:Bool = false
    private var motion:WLMotionManager!
    private var mapView:MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setUp()
        self.motion = WLMotionManager()
        self.motion.delegate = self
        self.motion.setUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func motion(sender: AnyObject) {
        if !bEnable {
            return
        }
        
        if !isRunning {
            self.motionBtton.setTitle("STOP", forState: UIControlState.Normal)
            self.motion!.start()
        }else {
            self.motionBtton.setTitle("START", forState: UIControlState.Normal)
            self.motion!.stop()
        }
        isRunning = !isRunning
    }

    private func setUp() {
        let center:CGPoint = self.view.center
        
        self.speedLabel = UILabel(frame: CGRectMake((self.view.bounds.size.width-200)/2.0, center.y-150, 200, 100))
        self.speedLabel.backgroundColor = UIColor.grayColor()
        self.speedLabel.textAlignment = NSTextAlignment.Center
        self.speedLabel.text = "--"
        self.speedLabel.font = UIFont.boldSystemFontOfSize(40)
        self.view.addSubview(self.speedLabel)
        
        self.motionBtton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        self.motionBtton.frame = CGRectMake((self.view.bounds.size.width-100)/2.0, CGRectGetMaxY(self.speedLabel.frame)+50, 100, 50)
        self.motionBtton.backgroundColor = UIColor.redColor()
        self.motionBtton.setTitle("START", forState: UIControlState.Normal)
        self.motionBtton.addTarget(self, action: "motion:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.motionBtton)
        
        self.mapView = MKMapView(frame: CGRectMake(0, CGRectGetMaxY(self.motionBtton.frame)+10, self.view.bounds.size.width, self.view.bounds.size.height-(CGRectGetMaxY(self.motionBtton.frame)+10)))
        self.mapView.mapType = MKMapType.Standard
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        var span:MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
        var region:MKCoordinateRegion = self.mapView.region
        region.span = span;
        self.mapView.region = region
        self.view.addSubview(self.mapView)
    }
    
    func showErrorAlert(message:String){
        UIAlertView(title: "Sorry", message: message, delegate: nil, cancelButtonTitle: "ok").show()
    }
    
    func motionDidFailed(motion: WLMotionManager, error: NSError) {
        bEnable = false
        self.showErrorAlert(error.description)
    }
    
    func motionLocationDidChange(type: String, sp speed: String) {
        self.speedLabel.text = speed
    }
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        mapView.
        myCoordinate.latitude = userLocation.coordinate.latitude;
        
        myCoordinate.longitude = userLocation.coordinate.longitude;
    }
}

