//
//  NavigationState.swift
//  BoyerLindsey-Project
//
//  Created by Lindsey Boyer on 11/24/25.
//

import SwiftUI

class NavigationState: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigateToSearch() {
        path.append("SearchView")
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}
