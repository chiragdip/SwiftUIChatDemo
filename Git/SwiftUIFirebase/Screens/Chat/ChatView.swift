//
//  ChatView.swift
//  SwiftUIFirebase
//
//  Created by MAC215 on 25/02/21.
//

import SwiftUI
import Combine
import Firebase

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif


enum ImagePickerType: String, Identifiable {
    case Camera     =   "Camera"
    case Gallery    =   "Gallery"
    case None       =   "None"
    
    var id: String { rawValue }
}

struct CustomMessageBar: View {
    
    @Binding var showAlertForImageSelection : Bool
    var placeHolder: String = ""
    @Binding var text: String
    let block: ()->()

    var body: some View {
        HStack(spacing: 8) {
            Spacer(minLength: 8)
            HStack {
                
                Button {
                    hideKeyboard()
                    showAlertForImageSelection = true
                    text = ""
                } label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 20,height: 20)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.blue)
                        .padding()
                }
                
                TextEditor(text: $text)
                    .lineLimit(text.isEmpty ? 1 : 2)
                    .frame(minHeight: 40)
                
                if !text.isEmpty {
                    Spacer(minLength: 2)

                    withAnimation(.easeIn) {
                        Button {
                            text = ""
                        } label: {
                            Image(systemName: "multiply")
                                .foregroundColor(Color.blue)
                                .frame(height: 40)
                                .padding()
                        }
                    }
                }
            }
            .padding(.vertical, 2)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: 1)
            )
            
            if !text.isEmpty {
                withAnimation(.easeIn) {
                    Button {
                        block()
                    } label: {
                        Image(systemName: "paperplane.circle.fill")
                            .resizable()
                            .frame(width: 40,height: 40)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.blue)
                            .padding()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.blue, lineWidth: 3)
                    )
                }
            }
            
            Spacer(minLength: 8)
        }
        .frame(height: text.isEmpty ? 45 : 90)
    }
}


struct ChatView: View {
    
    @StateObject private var viewModel = ChatViewModel()
        
    var secondUser : UserModel {
        didSet {

        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ScrollViewReader { scrollView in
                List {
                    ForEach(viewModel.messages, id: \.self) { message in
                        if viewModel.isMyMessage(message) {
                            RightSideChat(message: message)
                                .id(message.ID)
                        }else{
                            LeftSideChat(message: message)
                                .id(message.ID)
                        }
                    }
                }
                .onTapGesture { hideKeyboard() }
                .onChange(of: viewModel.messages, perform: { index in
                    if viewModel.shouldAnimateScrolling {
                        if let lastMessage = viewModel.messages.last, viewModel.isMyMessage(lastMessage) {
                            withAnimation {
                                scrollView.scrollTo(lastMessage.ID,anchor: .bottom)
                            }
                        }
                    }else{
                        viewModel.shouldAnimateScrolling = true
                        //First time...
                        if let lastMessage = viewModel.messages.last {
                            scrollView.scrollTo(lastMessage.ID,anchor: .bottom)
                        }
                    }
                })
            }
            
            CustomMessageBar(showAlertForImageSelection: $viewModel.showAlertForImageSelection,
                             placeHolder: "Enter message here...",
                             text: $viewModel.userMessage) {
                viewModel.insertNewMessage()
            }
        }
        .navigationTitle(secondUser.name)
        .onAppear {
            UITableView.appearance().separatorStyle = .none
            viewModel.secondUser = secondUser
            viewModel.loadChat()
        }
        .alert(item: $viewModel.error) {_ in 
                Alert(title: Text("Alert"),
                      message: Text(viewModel.error?.localizedDescription ?? ""),
                      dismissButton: Alert.Button.default(Text("OK")))
        }
        .actionSheet(isPresented: $viewModel.showAlertForImageSelection) {
            
            let cameraBtn       = ActionSheet.Button.default(Text("Camera")) { viewModel.openCamera() }
            let galleryBtn      = ActionSheet.Button.default(Text("Gallery")) { viewModel.openGallery() }
            let cancel          = ActionSheet.Button.cancel()
            
            return ActionSheet(title: Text(""), message: Text("Please select image from: "), buttons: [cameraBtn, galleryBtn, cancel])
        }
        .sheet(item: $viewModel.imagePickerType) { _ in
            return ImagePicker(sourceType: viewModel.imagePickerType == .Camera ? .camera : .photoLibrary, selectedImage: $viewModel.selectedImage)
        }
    }
}

struct RightSideChat: View {
    var message: Message
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Spacer(minLength: 30)
            VStack(alignment: .trailing, spacing: 8) {
                Text(message.senderName)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                
                if let uri = message.imageURI, !uri.isEmpty {
                    AsyncImage(urlStr: uri) {
                        LoadingView()
                            .frame(minHeight: 100, maxHeight: 100)
                            .padding()
                            .padding()
                            .background(Color.gray)
                    }
                    .frame(minHeight: 100, maxHeight: 100)
                    .padding(.horizontal, 12)
                }else{
                    Text(message.message)
                        .padding(.horizontal, 12)
                }
                
                Text(message.dateString)
                    .padding(.horizontal, 12)
            }
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.3))
            .cornerRadius(20)
            
            Text(String(message.senderName[0..<2]))
                .frame(width: 40, height: 40)
                .background(Color.blue)
                .clipShape(Capsule())
                .padding(.top, 12)
        }
    }
}

struct LoadingView: View {
    @State private var isLoading = false
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.green, lineWidth: 5)
            .frame(width: 100, height: 100)
            .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
            .animation(Animation.default.repeatForever(autoreverses: false))
            .onAppear() {
                self.isLoading = true
            }
    }
}

struct LeftSideChat: View {
    var message: Message
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(String(message.senderName[0..<2]))
                .frame(width: 40, height: 40)
                .background(Color.pink)
                .clipShape(Capsule())
                .padding(.top, 12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(message.senderName)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                
                if let uri = message.imageURI, !uri.isEmpty {
                    AsyncImage(urlStr: uri) {
                        LoadingView()
                            .frame(minHeight: 100, maxHeight: 100)
                            .padding()
                            .padding()
                            .background(Color.gray)
                    }
                    .frame(minHeight: 100, maxHeight: 100)
                    .padding(.horizontal, 12)
                }else{
                    Text(message.message)
                        .padding(.horizontal, 12)
                }
                
                Text(message.dateString)
                    .padding(.horizontal, 12)
            }
            .padding(.vertical, 8)
            .background(Color.pink.opacity(0.3))
            .cornerRadius(20)
            
            Spacer(minLength: 30)
        }
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(secondUser: UserModel.getDummyUser())
    }
}
