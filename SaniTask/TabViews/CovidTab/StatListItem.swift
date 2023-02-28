//
//  StatListItem.swift
//  SaniTask
//
//  Created by Amir Mohammadi on 12/9/1401 AP.
//

import SwiftUI
import DataCache
import CachedAsyncImage
import IsoCountryCodes

struct StatListItem: View {
   
   @State var covidStat: ApifyCovidData
   @State private var countryData: [RestCountriesData]?

   var body: some View {
      HStack(spacing: 10.0) {
         if let url = URL(string: countryData?[0].flags.png ?? "NULL") {
            CachedAsyncImage(url: url, urlCache: .flagCache) { cachedImage in
               cachedImage
                  .resizable()
                  .aspectRatio(contentMode: .fill)
            } placeholder: {
               Rectangle()
                  .fill(.ultraThinMaterial)
                  .overlay {
                     ProgressView()
                  }
            }
            .frame(width: 50, height: 40)
            .cornerRadius(8)
            .shadow(radius: 2)
         }
         VStack(alignment: .leading, spacing: 5.0) {
            Text(covidStat.country)
               .font(.headline)
            Text("Last Update: " + (formatDate(date: covidStat.lastUpdatedApify) ?? "NULL"))
               .font(.caption2)
         }
      }
      .task {
         let countryCode = IsoCountryCodes.searchByName(covidStat.country)?.alpha3 ?? "KR"
         countryData = try? cache.readCodable(forKey: countryCode)
      }
   }
}
