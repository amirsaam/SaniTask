//
//  CovidStatsView.swift
//  SaniTask
//
//  Created by Amir Mohammadi on 12/9/1401 AP.
//

import SwiftUI
import Semaphore

struct CovidStats: View {
   
   @Binding var covidStats: [ApifyCovidData]?
   @State private var dataIsLoading = false
   
   var body: some View {
      NavigationView {
         Group {
            if dataIsLoading {
               ProgressView("Loading Data...")
                  .textCase(.uppercase)
                  .font(.caption2)
            } else {
               List {
                  if covidStats == nil {
                     Text("Couldn't load stats for Covid.")
                        .foregroundColor(.red)
                        .font(.headline)
                  } else {
                     ForEach(covidStats ?? [], id: \.country) { stat in
                        NavigationLink(destination: StatDetailedView(covidStat: stat)) {
                           StatListItem(covidStat: stat)
                        }
                     }
                  }
               }
               .listStyle(.plain)
               .refreshable {
                  await refreshStats()
               }
            }
         }
         .navigationTitle("Covid-19 Stats")
         .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
               Button {
                  Task {
                     await refreshStats()
                  }
               } label: {
                  Image(systemName: "arrow.clockwise")
                     .font(.callout)
               }
            }
         }
      }
   }
   
   private func refreshStats() async {
      dataIsLoading = true
      Task { @MainActor in
         covidStats = nil
         covidStats = await getCovidData()
         semaphore.signal()
      }
      await semaphore.wait()
      dataIsLoading = false
   }
}
