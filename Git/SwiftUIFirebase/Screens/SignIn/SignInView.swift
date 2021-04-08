//
//  SignInView.swift
//  SwiftUIFirebase
//
//  Created by MAC215 on 23/02/21.
//

import SwiftUI


struct SignInView: View {
    
    @StateObject private var viewModel: SignInViewModel = SignInViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 20) {
                NavigationLink(destination: UserListView(),
                               tag: .success,
                               selection: $viewModel.apiStatus,
                               label: { EmptyView()} )
                
                Group {
                    CustomTextField(placeHolder: "Please enter emailID",
                                    text: $viewModel.emailID)
                    
                    CustomTextField(placeHolder: "Please enter password",
                                    text: $viewModel.password,
                                    isPassword: true)
                    
                    CustomTextField(placeHolder: "Please re-enter password",
                                    text: $viewModel.confirmPassword,
                                    isPassword: true)
                }
                
                Group {
                    CustomTextField(placeHolder: "Please enter name",
                                    text: $viewModel.name)
                    
                    CustomTextField(placeHolder: "Please enter company",
                                    text: $viewModel.company)
                    
                    CustomTextField(placeHolder: "Please enter experience",
                                    text: $viewModel.experience)
                    
                    CustomTextField(placeHolder: "Please enter designation",
                                    text: $viewModel.designation)
                    
                    CustomTextField(placeHolder: "Please enter reporting person",
                                    text: $viewModel.reportingPerson)
                }
                Group {
                    CustomTextField(placeHolder: "Please formatted address",
                                    text: $viewModel.formattedAddress)
                    
                    CustomTextField(placeHolder: "Please enter address1",
                                    text: $viewModel.address1)
                    
                    CustomTextField(placeHolder: "Please enter address2",
                                    text: $viewModel.address2)
                    
                    CustomTextField(placeHolder: "Please enter city",
                                    text: $viewModel.city)
                    
                    CustomTextField(placeHolder: "Please enter zip code",
                                    text: $viewModel.zipCode)
                    
                    CustomTextField(placeHolder: "Please enter country",
                                    text: $viewModel.country)
                    
                    CustomTextField(placeHolder: "Please enter state",
                                    text: $viewModel.state)
                    
                    Spacer(minLength: 30)
                }
            }
        }
        .padding(.horizontal, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Alert"),
                  message: Text(viewModel.alertText ),
                  dismissButton: Alert.Button.default(Text("OK")))
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                
                Button(action: {
                    viewModel.createUser()
                }, label: {
                    Text("Save")
                        .font(.title3)
                        .frame(height: 40)
                        .foregroundColor(.blue)
                })
            }
        })
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
