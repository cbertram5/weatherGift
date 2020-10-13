//
//  WeatherLocation.swift
//  weatherGift
//
//  Created by Chris Bertram on 10/6/20.
//

import Foundation

class WeatherLocation: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func getData() {
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=imperial&appid=\(APIKeys.openWeatherKey)"
        
        print("accessing URL \(urlString)")
        
        // Create a URL
        guard let url = URL(string: urlString) else {
            print("ERROR: could not create url from \(urlString)")
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                print("\(json)")
            } catch {
                print("JSON ERROR")
            }
        }
        
        task.resume()
        
    }
    
}

