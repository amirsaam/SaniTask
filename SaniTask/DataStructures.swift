//
//  DataStructures.swift
//  SaniTask
//
//  Created by Amir Mohammadi on 12/9/1401 AP.
//

import Foundation
import CodableAny

// MARK: - Apify Data Structure for Covid-19 Stats
struct ApifyCovidData: Codable {
   let infected: CodableAny
   let tested: CodableAny
   let recovered: CodableAny
   let deceased: CodableAny
   let country: String
   let moreData: String
   let lastUpdatedApify: String
}

// MARK: - RestCountries Data Structure for a Country Data
struct RestCountriesData: Codable {
   let name: RestCountriesNameData
   let tld: [String]
   let cca2: String
   let ccn3: String
   let cca3: String
   let cioc: String
   let independent: Bool
   let status: String
   let unMember: Bool
   let currencies: [String: RestCountriesCurrenciesData]
   let idd: RestCountriesIDDData
   let capital: [String]
   let altSpellings: [String]
   let region: String
   let subregion: String
   let languages: [String: String]
   let translations: [String: OfficialCommon]
   let latlng: [Float]
   let landlocked: Bool
   let borders: [String]?
   let area: Int
   let demonyms: [String: FemaleMale]
   let flag: String
   let maps: RestCountriesMapsData
   let population: Int
   let gini: [String: Double]?
   let fifa: String?
   let car: RestCountriesCarsData
   let timezones: [String]
   let continents: [String]
   let flags: RestCountriesFlagsData
   let coatOfArms: RestCountriesCoAData
   let startOfWeek: String
   let capitalInfo: RestCountriesCLLData
   let postalCode: RestCountriesPostalData?
}

struct RestCountriesNameData: Codable {
   let common: String
   let official: String
   let nativeName: [String: OfficialCommon]
}

struct RestCountriesCurrenciesData: Codable {
   let name: String
   let symbol: String
}

struct RestCountriesIDDData: Codable {
   let root: String
   let suffixes: [String]
}

struct RestCountriesMapsData: Codable {
   let googleMaps: String
   let openStreetMaps: String
}

struct RestCountriesCarsData: Codable {
   let signs: [String]
   let side: String
}

struct RestCountriesFlagsData: Codable {
   let png: String
   let svg: String
   let alt: String?
}

struct RestCountriesCoAData: Codable {
   let png: String
   let svg: String
}

struct RestCountriesCLLData: Codable {
   let latlng: [Float]
}

struct RestCountriesPostalData: Codable {
   let format: String
   let regex: String
}

//
struct OfficialCommon: Codable {
   let official: String
   let common: String
}

struct FemaleMale: Codable {
   let f: String
   let m: String
}
