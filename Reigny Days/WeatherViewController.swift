//
//  ViewController.swift


import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

enum Degrees: String {
    case celcius = "°C"
    case farenheit = "°F"
}


class WeatherViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CanReceive {
    
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = MyOpenWeatherApiKey
    
    
    //TODO: Declare instance variables here

    private let locationManager = CLLocationManager()
    private let weatherData = WeatherDataModel()

    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    
    @IBOutlet weak var forecastLayout: UICollectionViewFlowLayout!
    
    var celsiusSwitchedOn: Bool = false
    
    @IBOutlet weak var degrees: UILabel!
    
    @IBAction func degreesSwitched(_ sender: Any) {
        celsiusSwitchedOn = !celsiusSwitchedOn
        switch celsiusSwitchedOn {
        case true:degrees.text = Degrees.celcius.rawValue
        case false: degrees.text = Degrees.farenheit.rawValue
        }
        updateUIWithWeatherData()
        
    }
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        degrees.text = Degrees.farenheit.rawValue

        
     
        
        //MARK:LocationManager Datasource Methods
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    //MARK: - CollectionView  Delegate Methods
    
   
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = forecastCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 11
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
  
    func getWeatherData(url: String, parameters: [String:String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess {
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            } else {
                print("Connection issue")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    
    

    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    func updateWeatherData(json: JSON) {
        
        if let tempResult = json["main"]["temp"].double {
            
            
            weatherData.tempInCel = Int(tempResult - 273.15)
            weatherData.tempInFar = Int(((9/5)*(tempResult - 273.15)) + 32)
            weatherData.city = json["name"].stringValue
            weatherData.condition = json["weather"][0]["id"].intValue
            weatherData.weatherIconName = weatherData.updateWeatherIcon(condition: weatherData.condition)
            updateUIWithWeatherData()
            
        } else {
            cityLabel.text = "Weather Unavailable"
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    func updateUIWithWeatherData(){
        weatherIcon.image = UIImage(named: weatherData.weatherIconName)
        cityLabel.text = "\(weatherData.city)"
        switch celsiusSwitchedOn{
        case true: temperatureLabel.text = "\(weatherData.tempInCel)"
        case false: temperatureLabel.text = "\(weatherData.tempInFar)"
        }
    }
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            let params : [String : String] = ["lon" : longitude, "lat" : latitude, "appid" : APP_ID]
            
            print("longitude = \(longitude) and latitude = \(latitude)")
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    func dataReceived(data: String) {
        cityLabel.text = data
        userEnteredANewCityName(city: data)
    }
    
    func userEnteredANewCityName(city: String){
        print(city)
        let params: [String: String] = ["q": city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    @IBAction func ChangeCityButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "changeCityName", sender: self)
        
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any? ) {
        if segue.identifier == "changeCityName" {
            let secondVC = segue.destination as! ChangeCityViewController
            secondVC.newCity = cityLabel.text!
            secondVC.delegate = self
}

    }
    
    
}




