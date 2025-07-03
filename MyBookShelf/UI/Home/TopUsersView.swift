//
//  topUsersPreView.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 03/07/25.
//

//import SwiftUICore
import SwiftUI


struct topUsersPreView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = UserRankingViewModel()
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink(destination: topUsersView()) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.terracotta)
                        .frame(width: 4, height: 20)
                    
                    Text("Top Readers")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.right")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .font(.system(size: 18, weight: .semibold))
                }
                .padding(.horizontal)
                .padding(.top)
            }
            VStack{
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack{
                        ForEach(viewModel.users.prefix(10)) { user in
                            VStack {
                                Circle()
                                    .fill(.gray)
                                    .frame(width: 40, height: 40)
                                    .overlay{
                                        if let base64 = user.proPic,
                                           let imageData = Data(base64Encoded: base64),
                                           let uiImage = UIImage(data: imageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .clipShape(Circle())
                                        } else {
                                            Text("👤")
                                        }
                                    }
                                Text(user.nickname)
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight.opacity(0.8))
            )
            .padding(.horizontal, 8)
            .padding(.bottom, 10)
        }
        .onAppear{
            viewModel.loadUsers(currentUserID: auth.uid)
        }
    }
}

struct topUsersView: View {
    @StateObject private var viewModel = UserRankingViewModel()
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        ZStack(alignment: .top) {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            VStack(spacing: 0) {
                List(viewModel.users.indices, id: \.self) { index in
                    let user = viewModel.users[index]
                    userRow(user: user, position: index + 1)
                        .listRowBackground(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                        .padding(.vertical, 4)
                }
                //.listStyle(.plain)
                .scrollContentBackground(.hidden)

                if let currentUser = viewModel.currentUser, let rank = viewModel.currentRank {
                    Divider()
                    userRow(user: currentUser, position: rank, isCurrentUser: true)
                        .padding()
                        .background(colorScheme == .dark ? Color.backgroundColorDark2 : Color.backgroundColorLight)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.horizontal)
                                .padding(.top, 6)
                                .padding(.bottom, 12)
                }
            }
        }
        .customNavigationTitle("Top Readers")
        .onAppear {
            viewModel.loadUsers(currentUserID: auth.uid)
        }
    }

    @ViewBuilder
    func userRow(user: UserRanking, position: Int, isCurrentUser: Bool = false) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.gray)
                .frame(width: 40, height: 40)
                .overlay {
                    if let base64 = user.proPic,
                       let imageData = Data(base64Encoded: base64),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    } else {
                        Text("👤")
                    }
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(user.nickname)
                    //.font(.headline)
                Text("Level \(user.level)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
            if isCurrentUser {
                Text("You • #\(position)")
                    .font(.caption)
                    .foregroundColor(Color.terracotta)
            } else {
                Text("#\(position)")
                    .font(.caption)
                    .foregroundColor(Color.terracotta)
            }
        }
    }
}
