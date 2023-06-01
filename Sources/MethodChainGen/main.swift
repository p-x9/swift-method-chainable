//
//  main.swift
//
//
//  Created by p-x9 on 2023/05/26.
//
//

import Foundation
import ArgumentParser

#if os(macOS)
struct ModifierGen: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        commandName: "swchaingen",
        abstract: "Generates chainable method code from Swift methods.",
        shouldDisplay: true,
        helpNames: [.long, .short]
    )

    @Option(help: "input dir path", completion: .directory)
    var inputDir: String

    @Option(help: "output dir path for generated files", completion: .directory)
    var outputDir: String

    @Flag(help: "overwrite files")
    var overwrite: Bool = false

    func run() throws {
        let inputURL = URL(fileURLWithPath: inputDir)
        let outputURL = URL(fileURLWithPath: outputDir)

        let generator = Generator(inputURL: inputURL,
                                  outputURL: outputURL,
                                  overwrite: overwrite)
        try generator.generate()
    }
}

ModifierGen.main()
#endif
