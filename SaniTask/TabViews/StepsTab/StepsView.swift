//
//  StepsView.swift
//  SaniTask
//
//  Created by Amir Mohammadi on 12/9/1401 AP.
//

import SwiftUI
import SwiftUICharts

struct StepsView: View {

   @EnvironmentObject var model: ViewModels

   var body: some View {
      NavigationView {
         Group {
            if model.authorisedHealthKit {
               VStack(alignment: .leading, spacing: 5.0) {
                  HStack {
                     Label("Steps Taken Today", systemImage: "figure.walk")
                        .font(.title3)
                     Spacer()
                     Text(model.userTodayStepsCount == "" ? "0" : model.userTodayStepsCount)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                  }
                  HStack {
                     Label("Steps Taken this Week", systemImage: "figure.walk")
                        .font(.title3)
                     Spacer()
                     Text(model.userWeekStepsCount == "" ? "0" : model.userWeekStepsCount)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                  }
                  HStack {
                     Label("Steps Taken this Month", systemImage: "figure.walk")
                        .font(.title3)
                     Spacer()
                     Text(model.userMonthStepsCount == "" ? "0" : model.userMonthStepsCount)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                  }
                  let data = model.past14DaysData(userStepsGraphData: model.userStepsGraphData)
                  LineChart(chartData: data)
                     .pointMarkers(chartData: data)
                     .touchOverlay(chartData: data, specifier: "%.0f")
                     .averageLine(chartData: data,
                                  strokeStyle: StrokeStyle(lineWidth: 3, dash: [5,10]))
                     .xAxisGrid(chartData: data)
                     .yAxisGrid(chartData: data)
                     .xAxisLabels(chartData: data)
                     .yAxisLabels(chartData: data)
                     .infoBox(chartData: data)
                     .headerBox(chartData: data)
                     .legends(chartData: data, columns: [GridItem(.flexible()), GridItem(.flexible())])
                     .padding(.vertical)
               }
            } else {
               VStack {
                  Text("Please Authorize HealthKit!")
                     .font(.title3)
                  Button {
                     Task {
                        await model.healthRequest()
                     }
                  } label: {
                     Label("Authorize", systemImage: "link")
                        .font(.headline)
                        .foregroundColor(.white)
                  }
                  .frame(width: 320, height: 55)
                  .background(.blue)
                  .cornerRadius(10)
               }
            }
         }
         .padding()
         .navigationTitle("StepsTaken Stats")
         .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
               Button {
                  Task { @MainActor in
                     model.userStepsGraphData = []
                     await model.readStepsTaken()
                  }
               } label: {
                  Image(systemName: "arrow.clockwise")
                     .font(.callout)
               }
            }
         }
      }
      .task { @MainActor in
         model.userStepsGraphData = []
         await model.readStepsTaken()
      }
   }
}
