//
//  StatDetailedView.swift
//  SaniTask
//
//  Created by Amir Mohammadi on 12/9/1401 AP.
//

import SwiftUI
import DataCache
import CachedAsyncImage
import IsoCountryCodes


struct StatDetailedView: View {
   
   @State var covidStat: ApifyCovidData
   @State private var countryCode: String = ""
   @State private var countryData: [RestCountriesData]?

    var body: some View {
        VStack(alignment: .leading, spacing: 15.0) {
            if let country = countryData?[0] {
                Group {
                    HStack(spacing: 25.0) {
                        if let url = URL(string: country.flags.png) {
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
                            .frame(width: 80, height: 70)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                        VStack(alignment: .leading, spacing: 5.0) {
                            Text("Official Name:")
                                .font(.footnote)
                            Text(country.name.official)
                                .font(.headline)
                        }
                        Spacer()
                    }
                    Text("About the Country:")
                        .font(.subheadline)
                    Label("Capital is \(country.capital[0]), located in \(country.subregion)",
                          systemImage: "mappin")
                    HStack(spacing: 10.0) {
                        Label("Top-level domain: '\(country.tld[0])'", systemImage: "globe")
                        Divider()
                            .frame(height: 10)
                        Label(country.timezones[0], systemImage: "clock")
                    }
                    Label(country.flags.alt ?? "Flag description not provided yet.", systemImage: "flag")
                }
                .padding(.horizontal)
                .font(.footnote)
                List {
                    Label("Population: \(country.population)", systemImage: "person.2.fill")
                    Label("Affected by Covid: " +
                          String(describing: covidStat.infected.value ?? "NA"),
                          systemImage: "allergens.fill")
                    Label("Number of people tested: " +
                          String(describing: covidStat.tested.value ?? "NA"),
                          systemImage: "syringe.fill")
                    Label("Total recovered persons: " +
                          String(describing: covidStat.recovered.value ?? "NA"),
                          systemImage: "cross.case.fill")
                    Label("Total deceased persons: " +
                          String(describing: covidStat.deceased.value ?? "NA"),
                          systemImage: "waveform.path.ecg.rectangle.fill")
                }
                .listStyle(.plain)
            } else {
                ProgressView("Loading Data...")
                    .textCase(.uppercase)
                    .font(.caption2)
            }
        }
        .navigationTitle(covidStat.country)
        .navigationBarTitleDisplayMode(.large)
        .task {
            countryCode = IsoCountryCodes.searchByName(covidStat.country)?.alpha3 ?? "KR"
            countryData = try? cache.readCodable(forKey: countryCode)
        }
    }
}
