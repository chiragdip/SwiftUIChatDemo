//
//  SwiftUIView.swift
//  SwiftUIFirebase
//
//  Created by MAC215 on 23/02/21.
//

import SwiftUI

struct UserListView: View {
    
    @StateObject private var viewModel = UserListViewModel()
    
    var body: some View {
        
        VStack(spacing: 8) {
            Spacer(minLength: 8)
            
            if viewModel.secondUser != nil {
                NavigationLink("",
                               destination: ChatView(secondUser: viewModel.secondUser),
                               isActive: $viewModel.routeToChat)
            }
            
            NavigationLink(destination: LoginView(), tag: .logOut, selection: $viewModel.userMode) {
                EmptyView()
            }
            
            CustomSearchBar(placeHolder: "Search here", text: $viewModel.searchText)
            
            List {
                ForEach(viewModel.filteredUsers, id: \.self) { user in
                    UserView(user: user)
                        .contextMenu(menuItems: contextMenu(user))
                }
                .onDelete { indexes in viewModel.delete(indexes) }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear { viewModel.getUserList() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.getUserList()
        }
        .alert(item: $viewModel.error) {_ in 
                Alert(title: Text("Alert"),
                      message: Text(viewModel.error?.localizedDescription ?? ""),
                      dismissButton: Alert.Button.default(Text("OK")))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.logOut()
                }, label: {
                    Text("LogOut")
                        .font(.title3)
                        .frame(height: 40)
                        
                })
                .clipShape(Capsule())
                .background(Color.blue.opacity(0.3))
            }
        }
        .padding(.horizontal,10)
    }
    
    private func contextMenu(_ user: UserModel) -> (() -> VStack<TupleView<(Button<Label<Text, Image>>, Button<Text>, Button<Text>)>>) {
        return {
            VStack(spacing: 3) {
                Button {
                    if let index = viewModel.filteredUsers.firstIndex(of: user) {
                        viewModel.delete(IndexSet(integer: index))
                    }
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
                
                Button {
                    
                } label: {
                    Text("Company Address")
                }
                
                Button {
                    viewModel.secondUser = user
                    viewModel.routeToChat = true
                } label: {
                    Text("Chat")
                }
            }
        }
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}

struct UserView: View {
    @State var user: UserModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(user.name)
            Text(user.company)
            Text(user.address?.formattedAddress ?? "")
            
            HStack(spacing: 8) {
                Text("Experience :")
                    .fontWeight(.semibold)
                Text(user.experience)
            }
            
            HStack(spacing: 8) {
                Text("Report to :")
                    .fontWeight(.semibold)
                Text(user.reportingPerson)
            }
        }
    }
}
