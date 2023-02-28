//
//  ContentView.swift
//  SaniTask
//
//  Created by Amir Mohammadi on 12/8/1401 AP.
//

import SwiftUI

struct ContentView: View {
   
   @EnvironmentObject var model: ViewModels
   @State private var dataLoaded = true
   @State private var selectedTab = 1
   
   var body: some View {
      Group {
         if dataLoaded {
            TabView(selection: $selectedTab) {
               CovidStats(covidStats: $model.covidStats)
                  .tag(1)
                  .tabItem {
                     Label("CovidStats", systemImage: "microbe")
                  }
               StepsTaken()
                  .tag(2)
                  .tabItem {
                     Label("StepsTaken", systemImage: "figure.walk.circle")
                  }
            }
         } else {
            ProgressView("Loading Data...")
               .textCase(.uppercase)
               .font(.caption2)
         }
      }
      .task {
         model.covidStats = await getCovidData()
         withAnimation {
            dataLoaded = true
         }
      }
      .accentColor(.black)
   }
}

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      ContentView()
         .environmentObject(ViewModels.shared)
   }
}
