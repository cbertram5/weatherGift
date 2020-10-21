//
//  WeatherDetail.swift
//  weatherGift
//
//  Created by Chris Bertram on 10/13/20.
//

import Foundation

private let dateFormatter: DateFormatter = {
    print("📅CREATED DATE FORMATTER in WEATHER DETAIL")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter
}()

struct DailyWeather {
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
}

class WeatherDetail: WeatherLocation {
    
    private struct Result: Codable {
        var timezone: String
        var current: Current
        var daily: [Daily]
    }
    
    private struct Current: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    private struct Weather: Codable {
        var description: String
        var icon: String
    }
    
    private struct Daily: Codable {
        var dt: TimeInterval
        var temp: Temp
        var weather: [Weather]
        
    }
    
    private struct Temp: Codable {
        var max: Double
        var min: Double
        
        
    }
    
    var timezone = ""
    var currentTime = 0.0
    var temperature = 0
    var summary = ""
    var dayIcon = ""
    var dailyWeatherData: [DailyWeather] = []
    
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
            // Deal with the data
            do {
                let result = try JSONDecoder().decode(Result.self, from: data!)
                print("\(result)")
                print("timezone for \(self.name) is \(result.timezone)")
                self.timezone = result.timezone
                self.currentTime = result.current.dt
                self.temperature = Int(result.current.temp.rounded())
                self.summary = result.current.weather[0].description
                self.dayIcon = self.fileNameForIcon(icon: result.current.weather[0].icon)
                for index in 0..<result.daily.count {
                    let weekdayDate = Date(timeIntervalSince1970: result.daily[index].dt)
                    dateFormatter.timeZone = TimeZone(identifier: result.timezone)
                    let dailyWeekday = dateFormatter.string(from: weekdayDate)
                    let dailyIcon = self.fileNameForIcon(icon: result.daily[index].weather[0].icon)
                    let dailySummary = result.daily[index].weather[0].description
                    let dailyHigh = Int(result.daily[index].temp.max.rounded())
                    let dailyLow = Int(result.daily[index].temp.min.rounded())
                    let dailyWeather = DailyWeather(dailyIcon: dailyIcon, dailyWeekday: dailyWeekday, dailySummary: dailySummary, dailyHigh: dailyHigh, dailyLow: dailyLow)
                    self.dailyWeatherData.append(dailyWeather)
                    print("Day: \(dailyWeekday), High: \(dailyHigh), Low: \(dailyLow)")
                }
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
