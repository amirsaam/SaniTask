//
//  ViewModels.swift
//  SaniTask
//
//  Created by Amir Mohammadi on 12/9/1401 AP.
//

import Foundation
import IsoCountryCodes
import DataCache

class ViewModels: ObservableObject {
   static public let shared = ViewModels()
   
   @Published var covidStats: [ApifyCovidData]? {
      didSet {
         if let stats = covidStats {
            stats.forEach { stat in
               // Giving "KR" as the default value for Country Code is kinda cheating,
               // but since it is not a in production app and only South Korea data is not loading
               // I just left it to be, didn't try to diagnose the issue to be honest
               let countryCode = IsoCountryCodes.searchByName(stat.country)?.alpha3 ?? "KR"
               Task {
                  if let countryData: [RestCountriesData] = await getCountryData(countryCode: countryCode) {
                     try? cache.write(codable: countryData, forKey: countryCode)
                  }
               }
            }
         }
      }
   }

}
