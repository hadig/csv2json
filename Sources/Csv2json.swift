import ArgumentParser
import Foundation

@main
struct Csv2json: ParsableCommand {
    @Option(name: [.short, .customLong("input")])
    var inputFile: String

    @Option(name: [.short, .customLong("output")])
    var outputFile: String

    @Option(name: .shortAndLong)
    var delimiter: String = ";"

    @Flag(name: .shortAndLong, help: "Do not make output pretty.")
    var minify: Bool = false

    @Flag(name: .shortAndLong, help: "Print output.")
    var verbose: Bool = false

    @Flag(name: .shortAndLong, help: "Drop incomplete lines.")
    var clean: Bool = false

    mutating func run() throws {
        guard let input = try? String(contentsOfFile: inputFile) else {
            throw RuntimeError("Couldn't read from '\(inputFile)'!")
        }

        if input.isEmpty {
            throw RuntimeError("'\(inputFile)' is empty.")
        }

        // Split into lines
        let lines = input.split(whereSeparator: \.isNewline)

        guard lines.count > 1 else {
            throw RuntimeError("Input should contain more than one line!")
        }

        var output: String = minify ? "[" : "[\n"

        // First line is our data model
        let dataModel = lines.first!.components(separatedBy: delimiter)

        for (index, line) in lines.dropFirst().enumerated() {
            var jsonData = ""
            jsonData.append(minify ? "{" : "  {\n")
            let fragments = line.components(separatedBy: delimiter)

            for (i, data) in dataModel.enumerated() {
                guard fragments.count == dataModel.count else {
                    if index == 1 {
                        throw RuntimeError("Double check the delimiter \'\(delimiter)\'!\n\(dataModel)")
                    } else {
                        throw RuntimeError("Input seems to be corrupted check line number \(index): \(line)")
                    }
                }

                if clean {
                    if fragments[i].isEmpty {
                        if verbose {
                            print("Line number \(index) dropped: \n \(line)")
                        }
                        jsonData = ""
                        break
                    }
                }

                if fragments[i].isNumber {
                    jsonData.append(minify ? "\"\(data)\":\(fragments[i])" : "   \"\(data)\": \(fragments[i])")
                } else {
                    jsonData.append(minify ? "\"\(data)\":\"\(fragments[i])\"" : "   \"\(data)\": \"\(fragments[i])\"")
                }

                if i != dataModel.endIndex - 1 {
                    jsonData.append(",")
                }
                jsonData.append(minify ? "" : "\n")
            }

            if jsonData.isEmpty {
                continue
            }

            output.append(jsonData)

            output.append(minify ? "}" : "  }")
            if index != lines.endIndex - 2 {
                output.append(",")
            }
            output.append(minify ? "" : "\n")
        }

        output.append(minify ? "]" : "]\n")

        if verbose {
            print(output)
        }

        guard let _ = try? output.write(toFile: outputFile, atomically: true, encoding: .utf8) else {
            throw RuntimeError("Couldn't write to '\(outputFile)'!")
        }
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String

    init(_ description: String) {
        self.description = description
    }
}

extension String {
    var isNumber: Bool {
        return self.range(
            of: "^[0-9,.-]*$",
            options: .regularExpression) != nil
    }
}
