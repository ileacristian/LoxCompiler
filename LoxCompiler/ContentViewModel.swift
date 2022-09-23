//
//  ContentViewModel.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 05/08/2022.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {
    @Published var sourceCode: String = ""
    @Published var loxOutput: String = ""
    @Published var loxErrors: String = ""

    init() {
        $sourceCode
            .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
            .map { Lox.shared.run(source: $0).description }
            .assign(to: &$loxOutput)

        Lox.shared.$errorMessage
            .assign(to: &$loxErrors)
    }
}
