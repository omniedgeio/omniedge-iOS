//
//  SwiftUIView.swift
//  
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/9/13.
//  
//

import Combine
import SwiftUI

public struct OMESearchBar: View {
    let placeholder: LocalizedStringKey

    @State private var isActive: Bool = false
    @ObservedObject var isLoading = PublishedPropertyWrapper<Bool>(false)
    @Binding var query: String

    var onEditingChanged: (Bool) -> Void
    var onCommit: () -> Void

    public init(placeholder: LocalizedStringKey,
                searchQuery: Binding<String>,
                isLoading: Published<Bool>.Publisher? = nil,
                onEditingChanged: @escaping (Bool) -> Void = { _ in },
                onCommit: @escaping () -> Void = { }) {
        self.placeholder = placeholder
        self._query = searchQuery
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.isLoading.connect(published: isLoading)
    }

    public var body: some View {
        HStack(spacing: 0) {
            if isActive {
                Button(action: {
                    withAnimation {
                        hideKeyboard()
                        isActive = false
                    }
                }, label: {
                   Image(systemName: "chevron.left")
                    .padding([.vertical, .trailing], 4)
                    .padding(.leading, 14)
                })
            }
            HStack {
                Image(systemName: "magnifyingglass")
                TextField(placeholder,
                          text: $query,
                          onEditingChanged: { editing in
                            isActive = editing
                            onEditingChanged(editing)
                          },
                          onCommit: onCommit)
                if isLoading.value {
                    ProgressView()
                } else if !query.isEmpty {
                    Image(systemName: "xmark")
                        .scaleEffect(0.7)
                        .onTapGesture {
                            query = ""
                        }
                }
            }
            .modifier(SearchBarLook())
        }
    }
}

public struct SearchBarLook: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        content
            .padding(7)
            .padding(.horizontal, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            //.padding(.horizontal, 10)
    }
}

class PublishedPropertyWrapper<Value>: ObservableObject {
    @Published var value: Value
    init(_ value: Value) {
        self.value = value
    }
    func connect(published: Published<Value>.Publisher?) {
        published?.assign(to: &$value)
    }
}

struct Searchbar_Previews: PreviewProvider {
    @State static var query: String = ""
    static var previews: some View {
        VStack {
            Text("Search bar")
            OMESearchBar(placeholder: "Search", searchQuery: $query)
        }
    }
}
