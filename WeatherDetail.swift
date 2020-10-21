//
//  WeatherDetail.swift
//  weatherGift
//
//  Created by Chris Bertram on 10/13/20.
//

import Foundation

class WeatherDetail: WeatherLocation {
    
    struct Result: Codable {
        var timezone: String
        var current: Current
    }
    
    struct Current: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    struct Weather: Codable {
        var description: String
        var icon: String
    }
    
    var timezone = ""
    var currentTime = 0.0
    var temperature = 0
    var summary = ""
    var dailyIcon = ""
    
    func getData(completed: @escaping () -> ()) {
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=imperial&appid=\(APIKeys.openWeatherKey)"
        
        print("accessing URL \(urlString)")
        
        // Create a URL
        guard let url = URL(string: urlString) else {
            print("ERROR: could not create url from \(urlString)")
            completed()
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            
            do {
                let result = try JSONDecoder().decode(Result.self, from: data!)
                print("\(result)")
                print("timezone for \(self.name) is \(result.timezone)")
                self.timezone = result.timezone
                self.currentTime = result.current.dt
                self.temperature = Int(result.current.temp.rounded())
                self.summary = result.current.weather[0].description
                self.dailyIcon = self.fileNameForIcon(icon: result.current.weather[0].icon)
            } catch {
                print("JSON ERROR")
            }
            completed()
        }
        
        task.resume()
        
    }
    
    private func fileNameForIcon(icon: String) -> String {
        var newFileName = ""
        switch icon {
        case "01d":
            newFileName = "bachelor"
        case "01n":
            newFileName = "pc"
        case "02d":
            newFileName = "skiing"
        case "02n":
            newFileName = "pc"
        case "03d", "03n", "04d", "04n":
            newFileName = "sunrise"
        case "09d", "09n", "010d", "010n":
            newFileName = "snowing"
        case "011d", "011n":
            newFileName = "snowing"
        case "13d", "13n":
            newFileName = "sunset"
        case "50d", "50n":
            newFileName = "skiing"
        default:
            newFileName = ""
        }
        return newFileName
    }
}
