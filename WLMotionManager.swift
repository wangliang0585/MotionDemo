//
//  WLMotionManager.swift
//  MotionDemo
//
//  Created by wangliang-ms on 14-9-12.
//  Copyright (c) 2014年 Qihoo. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

enum SpeedUnitType {
    case ms
    case kmh
}

enum MotionType {
    case Unkown
    case Stationary
    case Walking
    case Running
    case Automotive
}

protocol WLMotionManagerDelegate : NSObjectProtocol{
    func motionDidFailed(motion:WLMotionManager,error:NSError)
    func motionLocationDidChange(type:String, sp speed:String)
}

class WLMotionManager: NSObject,CLLocationManagerDelegate {
    private var locationManager:CLLocationManager!
    private var motionManager:CMMotionActivityManager!
    private var speed:Double = 0.0
    private var location:CLLocation? = nil
    private var timer:NSTimer? = nil
    
    var delegate:WLMotionManagerDelegate? = nil
    var speedUnit:SpeedUnitType = SpeedUnitType.ms
    var motionType:MotionType = MotionType.Unkown
    var updateTimer:Double = 0.2
    
/*
    class func sharedInstance()->WLMotionManager{
        struct Static {
            static var instance: WLMotionManager? = nil
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token, {
            Static.instance = WLMotionManager()
            
        })
        return Static.instance!
    }
*/
    override init() {
        
    }
    
    func setUp(){
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager = CLLocationManager()
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.distanceFilter = kCLDistanceFilterNone
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.delegate = self
        }else{
            if (self.delegate != nil) && self.delegate!.respondsToSelector(Selector("motionDidFailed::"))
            {
                self.delegate!.motionDidFailed(self, error: NSError(domain: "Location Services is not enabled", code: -1, userInfo: nil))
            }
        }
    }
    
    func start() {
        self.locationManager?.startUpdatingLocation()
        self.startActivty()
        self.startTimer()
    }
    
    func stop() {
        self.locationManager?.stopUpdatingLocation()
        self.motionManager?.stopActivityUpdates()
        self.timer?.invalidate()
        if (self.delegate != nil) && self.delegate!.respondsToSelector("motionLocationDidChange:sp:") {
            self.delegate!.motionLocationDidChange("stop", sp: "--")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {

        }else {
            if (self.delegate != nil) && self.delegate!.respondsToSelector("motionDidFailed::")
            {
                self.delegate!.motionDidFailed(self, error: NSError(domain: "Location Services is not enabled", code: -1, userInfo: nil))
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if (self.delegate != nil) && self.delegate!.respondsToSelector("motionDidFailed::")
        {
            self.delegate!.motionDidFailed(self, error: error)
        }
        self.timer?.invalidate()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
    }
    
    private func startActivty() {
        if CMMotionActivityManager.isActivityAvailable() {
            if self.motionManager == nil {
                self.motionManager = CMMotionActivityManager()
            }
            self.motionManager?.startActivityUpdatesToQueue(NSOperationQueue(), withHandler: {
                (activity : CMMotionActivity!) in
                if activity.walking {
                    self.motionType = MotionType.Walking
                }else if activity.running {
                    self.motionType = MotionType.Running
                }else if activity.automotive {
                    self.motionType = MotionType.Automotive
                }else if activity.stationary {
                    self.motionType = MotionType.Stationary
                }else if activity.unknown {
                    self.motionType = MotionType.Unkown
                }
            })
        }
    }
    
    private func startTimer() {
        if self.timer == nil {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(self.updateTimer, target: self, selector: "updateLocation", userInfo: nil, repeats: true)
        }
        self.timer!.fire()
    }
    
    func updateLocation(){
        if self.location != nil {
            var distanceChange:CLLocationDistance = self.locationManager.location.distanceFromLocation(self.location)
            self.speed = distanceChange/self.updateTimer
            if self.speed < 0 {
                self.speed = 0
            }
            
            if (self.delegate != nil) && self.delegate!.respondsToSelector("motionLocationDidChange:sp:") {
                self.delegate!.motionLocationDidChange("test", sp: self.calculateSpeed())
            }

        }
        self.location = self.locationManager.location
    }
    
    private func calculateSpeed()->String{
        if self.speedUnit == SpeedUnitType.ms {
            var speed:String = String(format: "%.2f", self.speed)
            return speed+"M/S"
        }else {
            var speed:String = String(format: "%.2f", self.speed*3.6)
            return "\(self.speed*3.6)"+"KM/H"
        }
    }
    
    private func isiPhone5s()->Bool{
        return false
    }
}