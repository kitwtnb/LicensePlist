import ArgumentParser
import Foundation
import LicensePlistCore
import LoggerAPI

private func loadConfig(configPath: URL) -> Config {
    if let yaml = configPath.lp.read() {
        return Config(yaml: yaml, configBasePath: configPath.deletingLastPathComponent())
    }
    return Config.empty
}

extension CompletionKind {
    static var empty: CompletionKind {
        return .custom { _ in return [] }
    }
}

// Typename used for usage in help command
struct LicensePlist: ParsableCommand {
    static let configuration = CommandConfiguration(version: Consts.version)

    @Option(name: .long, completion: .file())
    var cartfilePath = Consts.cartfileName

    @Option(name: .long, completion: .file())
    var mintfilePath = Consts.mintfileName

    @Option(name: .long, completion: .directory)
    var podsPath = Consts.podsDirectoryName

    @Option(name: [.customLong("package-path"), .customLong("swift-package-path"), .long, .customLong("swift-package-paths")], parsing: .upToNextOption, completion: .file())
    var packagePaths = [Consts.packageName]

    @Option(name: .long, completion: .file())
    var xcworkspacePath = "*.xcworkspace"

    @Option(name: .long, completion: .file())
    var xcodeprojPath = "*.xcodeproj"

    @Option(name: .long, completion: .file())
    var outputPath = Consts.outputPath

    static let githubTokenEnv = "LICENSE_PLIST_GITHUB_TOKEN"
    @Option(name: .long, help: "You can also pass the token via the '\(Self.githubTokenEnv)' environment variable.", completion: .empty)
    var githubToken: String?

    @Option(name: .long, completion: .file())
    var configPath = Consts.configPath

    @Option(name: .long, completion: .empty)
    var prefix = Consts.prefix

    @Option(name: .long, completion: .file())
    var htmlPath: String?

    @Option(name: .long, completion: .file())
    var markdownPath: String?

    @Flag(name: .long)
    var force = false

    @Flag(name: .long)
    var addVersionNumbers = false

    @Flag(name: .long)
    var addSources = false

    @Flag(name: .long)
    var suppressOpeningDirectory = false

    @Flag(name: .long)
    var singlePage = false

    @Flag(name: .long)
    var failIfMissingLicense = false

    @Flag(name: .long)
    var silenceMode = false

    func run() throws {

        if !silenceMode {
            Logger.configure()
        }

        var config = loadConfig(configPath: URL(fileURLWithPath: configPath))
        config.force = force
        config.addVersionNumbers = addVersionNumbers
        config.suppressOpeningDirectory = suppressOpeningDirectory
        config.singlePage = singlePage
        config.failIfMissingLicense = failIfMissingLicense
        config.addSources = addSources
        let options = Options(outputPath: URL(fileURLWithPath: outputPath),
                              cartfilePath: URL(fileURLWithPath: cartfilePath),
                              mintfilePath: URL(fileURLWithPath: mintfilePath),
                              podsPath: URL(fileURLWithPath: podsPath),
                              packagePaths: packagePaths.map { URL(fileURLWithPath: $0) },
                              xcworkspacePath: URL(fileURLWithPath: xcworkspacePath),
                              xcodeprojPath: URL(fileURLWithPath: xcodeprojPath),
                              prefix: prefix,
                              gitHubToken: githubToken ?? ProcessInfo.processInfo.environment[Self.githubTokenEnv],
                              htmlPath: htmlPath.map { return URL(fileURLWithPath: $0) },
                              markdownPath: markdownPath.map { return URL(fileURLWithPath: $0) },
                              config: config)
        let tool = LicensePlistCore.LicensePlist()
        tool.process(options: options)
    }
}

LicensePlist.main()
