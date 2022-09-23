//
//  ContentView.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 04/08/2022.
//

import SwiftUI

struct ContentView: View {

    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            HStack {
                TextEditor(text: $viewModel.sourceCode)
                    .font(.system(size: 16).monospaced())
                VStack {
                    TextEditor(text: $viewModel.loxOutput)
                        .font(.system(size: 16).monospaced())
                    TextEditor(text: $viewModel.loxErrors)
                        .font(.system(size: 16).monospaced())
                        .frame(height: 200)
                }
            }
        }.frame(minWidth:1400, minHeight: 800)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
