//
//  ProfileView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 25/05/25.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("username") private var username: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Username", text: $username)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
