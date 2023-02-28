//
//  SaniTaskApp.swift
//  SaniTask
//
//  Created by Amir Mohammadi on 12/8/1401 AP.
//

import SwiftUI
import Semaphore
import DataCache

let cache = DataCache.instance
let semaphore = AsyncSemaphore(value: 0)

@main
struct SaniTaskApp: App {
   var body: some Scene {
      WindowGroup {
         ContentView()
            .environmentObject(ViewModels.shared)
      }
   }
}
