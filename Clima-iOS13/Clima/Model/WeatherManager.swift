//
//  WeatherManager.swift
//  Clima
//
//  Created by manan uppal on 21/02/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherMangerDelegate {
    func didUpdateWeather(_ weatherManager:WeatherManager, weather:WeatherModel)
    func didFailWithError(error:Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=2461bd46c6e890d2292ae0aa678b4cd6&units=metric"
    
    var delegate: WeatherMangerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    func fetchWeather(lat: Double, lon: Double) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
    }
    func performRequest(with urlString:String) {
        //step 1 ; create a URL
        if let url = URL(string: urlString) {
            
            
            //step 2 create a URLsession
            let session = URLSession(configuration: .default)
            
            //give session a task
            let task = session.dataTask(with: url) { (data, response , error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
           
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            print(weather.conditionName)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}

