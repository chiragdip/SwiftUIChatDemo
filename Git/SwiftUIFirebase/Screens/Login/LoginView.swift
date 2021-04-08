//
//  ContentView.swift
//  SwiftUIFirebase
//
//  Created by MAC215 on 22/02/21.
//

import SwiftUI

extension NSError : Identifiable {
    
}

struct LoginView: View {
    
    @StateObject private var viewModel : LoginViewModel = LoginViewModel()
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            
            NavigationLink(destination: UserListView(),
                           tag: .success,
                           selection: $viewModel.apiStatus,
                           label: { EmptyView()} )
            
            CustomTextField(placeHolder: "Please enter emailID", text: $viewModel.emailID)
            
            CustomTextField(placeHolder: "Please enter password", text: $viewModel.password, isPassword: true)
            
            Button(action: {
                self.viewModel.loginUser()
            }, label: {
                Text("Login")
                    .font(.title3)
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.blue)
            })
            .disabled(viewModel.tappedOnLogin)
            .opacity(viewModel.tappedOnLogin ? 0.3 : 1.0)
            
            HStack() {
                Spacer()
                NavigationLink(destination: SignInView(),
                               label: {
                                Text("Sign in here")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                    .padding()
                               })
            }
            .offset(x: 0, y: -30)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.automatic)
        .alert(item: $viewModel.error) {_ in
            Alert(title: Text("Alert"),
                  message: Text(viewModel.error?.localizedDescription ?? ""),
                  dismissButton: Alert.Button.default(Text("OK")))
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct CustomTextField: View {
    
    var placeHolder: String = ""
    @Binding var text: String
    
    var isPassword: Bool = false
    
    @State private var showPassword: Bool = false
    
    var body: some View {
        HStack {
            Spacer(minLength: 8)
            if isPassword {
                HStack(spacing: 2) {
                    if showPassword {
                        TextField(placeHolder, text: $text)
                    }else{
                        SecureField(placeHolder, text: $text)
                    }
                    
                    Button(action: {
                        showPassword.toggle()
                    }, label: {
                        
                        Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                            .aspectRatio(contentMode: .fit)
                    })
                }
            }else{
                TextField(placeHolder, text: $text)
            }
            Spacer(minLength: 8)
        }
        .frame(height: 60)
        .border(Color.gray.opacity(0.4))
        .cornerRadius(5)
    }
}

struct CustomSearchBar: View {
    
    var placeHolder: String = ""
    @Binding var text: String
    
    var body: some View {
        HStack {
            Spacer(minLength: 8)
            TextField(placeHolder, text: $text)
            
            if !text.isEmpty {
                Spacer(minLength: 2)
                Button {
                    text = ""
                } label: {
                    Image(systemName: "multiply")
                        .foregroundColor(Color.gray)
                        .frame(height: 40)
                        .padding()
                }
            }
            Spacer(minLength: 8)
        }
        .frame(height: 60)
        .border(Color.gray.opacity(0.4))
        .cornerRadius(5)
    }
}
