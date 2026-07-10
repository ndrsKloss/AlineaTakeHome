//
//  AlineaTake_HomeApp.swift
//  AlineaTake-Home
//
//  Created by Anderson Kloss Maia on 10/07/26.
//

import SwiftUI

@main
struct AlineaTake_HomeApp: App {
    init() {
        AlineaFonts.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
