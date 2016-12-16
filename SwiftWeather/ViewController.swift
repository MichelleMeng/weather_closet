//
//  ViewController.swift
//  SwiftWeather
//
//  Created by MichelleMeng on 16/11/30.
//  Copyright © 2016年 MichelleMeng. All rights reserved.
//

import UIKit
import CoreLocation
import AFNetworking


class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager: CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var City: UILabel!
    
    @IBOutlet weak var weather: UILabel!

    
    @IBOutlet weak var Temperature: UILabel!
    
    
    @IBOutlet weak var picture: UIImageView!
    
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self  // self就是当前的class
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  // 精确度使用最好的
        
        self.loadingIndicator.startAnimating()
        //self.loadingIndicator.hidesWhenStopped = true
        self.loadingLabel.text = "Updating weather information"
        
        if(ios8_higher()){
            locationManager.requestAlwaysAuthorization() // ios8 之后，都需要调用这个函数
        }
        
        locationManager.startUpdatingLocation()
        
    }
    
    // 自己写的函数
    func ios8_higher() -> Bool {
        return (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // 来自 CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location: CLLocation = locations[locations.count-1] as CLLocation // locations可能返回一个array。我们要取出最后一个
        
        if (location.horizontalAccuracy) > 0 { // > 0 说明这是一个正确的地理位置信息
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)  // 打印出这个地理位置的经纬度
            
            // 调用自己写的函数
            self.updateWeatherInfo(location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            locationManager.stopUpdatingLocation()  // 已经获得了地理位置，则停止继续更新。如果是GPS应用，则不应停止更新
        }
        
    }
    
    // 自己写的函数，在得到经度 纬度时 调用
    func updateWeatherInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let manager = AFHTTPSessionManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
//        let url = "http://api.openweathermap.org/data/2.5/forecast"
        let params = ["lat": latitude, "lon": longitude, "APPID": "6331fdc3505f7e3157699676e02528bd", "cnt":0]
        let APPID = "6331fdc3505f7e3157699676e02528bd"
        
        manager.GET(url, parameters: params,
            success: { (operation: NSURLSessionTask!, responseObject) in print("JSON: " + responseObject!.description)
                
                self.updateUISuccess(responseObject as! NSDictionary!)
            },
            failure: {(operation: NSURLSessionTask?, error: NSError!) in print("Error: " + error.localizedDescription)
                
        })
    }
    
    func updateUISuccess (jsonResult: NSDictionary!) {
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.hidden = true
        self.loadingLabel.text = nil
        
        if let tempResult = jsonResult["main"]!["temp"] as! Double? {
            
            var temperature: Double
            // 判断地区是否是美国，如是，则转化为华氏度
            if (jsonResult["sys"]!["country"] as! String? == "US") {
                // temperature = round(((tempResult - 273.15) * 1.8) + 32)
                temperature = round(tempResult - 273.15)
            }
            else {  // 否则，转化为摄氏度
                temperature = round(tempResult - 273.15)
            }
            
            self.Temperature.text = "\(temperature)°"
            
            
            var cityName = jsonResult["name"] as! String
            self.City.text = "City: \(cityName)"
            
            var weather = (jsonResult["weather"] as! NSArray)[0]["main"] as! String
            self.weather.text = "Weather: \(weather)"
            
            var tempBenchmark: Double = round(tempResult - 273.15)
            self.updatePicture(tempBenchmark)
            
        }
        else {
            self.loadingLabel.text = "天气信息不可用"
        }
    }
    
    // 自己写的
    func updatePicture(tempBenchmark: Double) {
        if tempBenchmark > 30.0 {
            var above30 = ["30_plus_1","30_plus_2"]
            self.picture.image = UIImage(named: self.getRandomPic(above30))
            
        }
        
        else if tempBenchmark > 20.0 {
            var above20 = ["20_plus_1","20_plus_2", "20_plus_3"]
            self.picture.image = UIImage(named: self.getRandomPic(above20))
            
        }
        
        else if tempBenchmark > 10.0 {
            var above10 = ["10_plus_1","10_plus_2", "10_plus_3"]
            self.picture.image = UIImage(named: self.getRandomPic(above10))
        }
        
        else if tempBenchmark > 0.0 {
            var above0 = ["0_plus_1","0_plus_2", "0_plus_3"]
            self.picture.image = UIImage(named: self.getRandomPic(above0))
        }
        
        else {
            var below0 = ["minus_1","minus_2"]
            self.picture.image = UIImage(named: self.getRandomPic(below0))
        }
        
        }
    
    // 自己写的
    func getRandomPic(pictures: NSArray) -> String {
        let random = arc4random_uniform(UInt32(pictures.count))
        return pictures[Int(random)] as! String
    }
    
    // 来自 CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
        self.loadingLabel.text = "地理位置不可用"
    }


}

