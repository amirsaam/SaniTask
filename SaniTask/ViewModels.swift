//
//  ViewModels.swift
//  SaniTask
//
//  Created by Amir Mohammadi on 12/9/1401 AP.
//

import Foundation
import HealthKit
import SwiftUI
import SwiftUICharts
import IsoCountryCodes
import DataCache
import Semaphore

// This ViewModel is only a proof of concept of how UI should be updated
// In a production level app, each main view should have its own ViewModel
class ViewModels: ObservableObject {
   static public let shared = ViewModels()

   init() {
      changeAuthorizationStatus()
   }

   @Published var authorisedHealthKit = false
   @Published var userTodayStepsCount = ""
   @Published var userWeekStepsCount = ""
   @Published var userMonthStepsCount = ""
   @Published var userStepsGraphData: [String] = []
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

   func healthRequest() async {
      do {
         try await setupHealthKit()
         changeAuthorizationStatus()
         await readStepsTaken()
      } catch {
         print(error.localizedDescription)
      }
   }

   func changeAuthorizationStatus() {
      guard let stepQtyType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
      let status = HKHealthStore().authorizationStatus(for: stepQtyType)

      Task { @MainActor in
         switch status {
         case .notDetermined:
            authorisedHealthKit = false
         case .sharingDenied:
            authorisedHealthKit = false
         case .sharingAuthorized:
            authorisedHealthKit = true
         @unknown default:
            authorisedHealthKit = false
         }
      }
   
   }

   // There is an issue for me on usage of MainActor on HealthKit API function
   // Because it uses completion handler, I couldn't just wrap the whole function in
   // `@MainActor in` while I do call them in views, it resulted in UI Warning no matter
   // what I've tried so far, so here is what happened...
   func readStepsTaken() async {
      guard let week = Calendar.current.date(byAdding: .weekday, value: -7, to: Date()),
            let month = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else { return }
      
      readStepsCount(startDate: Date(), endDate: Date()) { steps in
         Task { @MainActor in
            self.userTodayStepsCount = String(format: "%.0f", steps)
         }
      }
      
      readStepsCount(startDate: week, endDate: Date()) { steps in
         Task { @MainActor in
            self.userWeekStepsCount = String(format: "%.0f", steps)
         }
      }
      
      readStepsCount(startDate: month, endDate: Date()) { steps in
         Task { @MainActor in
            self.userMonthStepsCount = String(format: "%.0f", steps)
         }
      }

      await MainActor.run {
         self.userStepsGraphData.removeAll()
      }

      var tempGraphData: [(date: Date, steps: Double)] = []
      let endOfToday = Calendar.current.endOfDay(for: Date())
      
      for day in -14..<0 {
         guard let pastDays = Calendar.current.date(byAdding: .day, value: day, to: endOfToday) else { return }
         readStepsCount(startDate: pastDays, endDate: pastDays) { steps in
            tempGraphData.append((date: pastDays, steps: steps))
            semaphore.signal()
         }
         await semaphore.wait()
      }
      
      let sortedGraphData = tempGraphData.sorted { $0.date < $1.date }
      let stepsGraphData = sortedGraphData.map { String(format: "%.0f", $0.steps) }

      await MainActor.run {
         self.userStepsGraphData = stepsGraphData
      }

   }

   // Creates what `SwiftUICharts` requires to create a chart based on
   func past14DaysData(userStepsGraphData: [String]) -> LineChartData {
      var dataPoints: [LineChartDataPoint] = []
      for (index, stepsString) in userStepsGraphData.enumerated() {
         if let steps = Double(stepsString) {
            let daysAgo = 13 - index
            dataPoints.append(LineChartDataPoint(value: steps,
                                                 xAxisLabel: String(describing: daysAgo),
                                                 description: nil))
         }
      }
      let data = LineDataSet(dataPoints: dataPoints,
                             legendTitle: "Steps",
                             pointStyle: PointStyle(),
                             style: LineStyle(lineColour: ColourStyle(colour: .red),
                                              lineType: .curvedLine))
      let returnData = LineChartData(dataSets: data,
                                     metadata: ChartMetadata(title: "Past 14 Days", subtitle: ""),
                                     xAxisLabels: nil,
                                     chartStyle: LineChartStyle(
                                       infoBoxPlacement: .header,
                                       markerType: .full(attachment: .point),
                                       xAxisLabelsFrom: .chartData(rotation: .degrees(0)),
                                       baseline: .minimumWithMaximum(of: 5000)
                                     ))
      return returnData
   }

}
