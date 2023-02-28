//
//  Functions.swift
//  SaniTask
//
//  Created by Amir Mohammadi on 12/9/1401 AP.
//

import Foundation

// MARK: - CachedAsynImage Instance
extension URLCache {
   // 4MB and 20MB
   static let flagCache = URLCache(memoryCapacity: 4*1024*1024, diskCapacity: 20*1024*1024)
}

// MARK: - Retrieve Apify Covid Stats
func getCovidData() async -> [ApifyCovidData]? {
   
   var urlComponents = URLComponents()
   urlComponents.scheme = "https"
   urlComponents.host = "api.apify.com"
   urlComponents.path = "/v2/key-value-stores/tVaYRsPHLjNdNBu7S/records/LATEST"
   urlComponents.queryItems = [URLQueryItem(name: "disableRedirect", value: "true")]
   
   guard let url = urlComponents.url else { return nil }
   
   do {
      let (data, _) = try await URLSession.shared.data(
         for: URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
      )
      let result: [ApifyCovidData] = try JSONDecoder().decode([ApifyCovidData].self, from: data)
      debugPrint("Apify data for Covid-19 Stats fetched.")
      return result
   } catch {
      debugPrint("Error getting data from URL: \(url): \(error)")
      return nil
   }
   
}

// MARK: - Formats Apify date string to `Month Day, Year`
func formatDate(date: String) -> String? {

   let dateFormatterGet = DateFormatter()
   dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
   
   let dateFormatter = DateFormatter()
   dateFormatter.dateStyle = .medium
   dateFormatter.timeStyle = .none
   
   guard let dateObj: Date = dateFormatterGet.date(from: date) else { return nil }
   
   return dateFormatter.string(from: dateObj)

}

// MARK: - Retrieve RestCountries Data for a Country
func getCountryData(countryCode: String) async -> [RestCountriesData]? {
   
   var urlComponents = URLComponents()
   urlComponents.scheme = "https"
   urlComponents.host = "restcountries.com"
   urlComponents.path = "/v3.1/alpha/" + countryCode
   
   guard let url = urlComponents.url else { return nil }
   
   do {
      let (data, _) = try await URLSession.shared.data(
         for: URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
      )
      let result: [RestCountriesData] = try JSONDecoder().decode([RestCountriesData].self, from: data)
      debugPrint("RestCountries data for country code -\(countryCode)- fetched.")
      return result
   } catch {
      debugPrint("Error getting data from URL: \(url): \(error)")
      return nil
   }
   
}
