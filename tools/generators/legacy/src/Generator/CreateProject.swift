import PathKit
import ToolCommon
import XcodeProj

extension Generator {
    /// Creates the `PBXProj` and `PBXProject` objects for the given `Project`.
    ///
    /// The `PBXProject` is also created and assigned as the `PBXProj`'s
    /// `rootObject`.
    static func createProject(
        buildMode: BuildMode,
        forFixtures: Bool,
        project: Project,
        directories: Directories,
        legacyIndexImport: String,
        indexImport: String,
        minimumXcodeVersion: SemanticVersion
    ) -> PBXProj {
        let pbxProj = PBXProj(
            objectVersion: minimumXcodeVersion.pbxProjObjectVersion
        )

        let nonRelativeProjectDir = directories.executionRoot
        let options = project.options

        let srcRoot: String
        if forFixtures {
            srcRoot = (0 ..< nonRelativeProjectDir.components.count)
                .map { _ in ".." }
                .joined(separator: "/")
        } else {
            srcRoot = directories.workspace.string
        }

        let absoluteProjectDir: String
        let projectDir: Path
        if nonRelativeProjectDir.isRelative {
            projectDir = directories.projectRoot + nonRelativeProjectDir
            absoluteProjectDir = "\(srcRoot)/\(nonRelativeProjectDir)"
        } else {
            projectDir = nonRelativeProjectDir
            absoluteProjectDir = nonRelativeProjectDir.string
        }

        let mainGroup = PBXGroup(
            sourceTree: forFixtures ? .group : .absolute,
            path: srcRoot,
            usesTabs: options.usesTabs,
            indentWidth: options.indentWidth,
            tabWidth: options.tabWidth
        )
        pbxProj.add(object: mainGroup)

        let absoluteProjectDirPath: String
        let projectDirPath: String
        if projectDir.string.hasPrefix("/private/") {
            projectDirPath = String(projectDir.string.dropFirst(8))
            absoluteProjectDirPath = projectDirPath
        } else {
            projectDirPath = projectDir.string
            absoluteProjectDirPath = absoluteProjectDir
        }

        let projectDirComponents = absoluteProjectDirPath
            .split(separator: "/", omittingEmptySubsequences: false)

        var buildSettings: [String: Any] = [
            "ALWAYS_SEARCH_USER_PATHS": false,
            "BAZEL_CONFIG": project.bazelConfig,
            "BAZEL_EXTERNAL": "$(BAZEL_OUTPUT_BASE)/external",
            "BAZEL_INTEGRATION_DIR": "$(INTERNAL_DIR)/bazel",
            "BAZEL_LLDB_INIT": "$(HOME)/.lldbinit-rules_xcodeproj",
            "BAZEL_OUT": "$(PROJECT_DIR)/bazel-out",
            "_BAZEL_OUTPUT_BASE": "$(PROJECT_DIR)/../..",
            "BAZEL_OUTPUT_BASE": "$(_BAZEL_OUTPUT_BASE:standardizepath)",
            "BAZEL_WORKSPACE_ROOT": "$(SRCROOT)",
            "BUILD_DIR": """
$(SYMROOT)/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)
""",
            "BUILD_MARKER_FILE": "$(OBJROOT)/build_marker",
            "BUILD_WORKSPACE_DIRECTORY": "$(SRCROOT)",
            "CLANG_ENABLE_OBJC_ARC": true,
            "CLANG_MODULES_AUTOLINK": false,
            "CONFIGURATION_BUILD_DIR": "$(BUILD_DIR)/$(BAZEL_PACKAGE_BIN_DIR)",
            "COPY_PHASE_STRIP": false,
            "DEBUG_INFORMATION_FORMAT": "dwarf",
            "DSTROOT": "$(PROJECT_TEMP_DIR)",
            "ENABLE_DEBUG_DYLIB": "NO",
            "ENABLE_DEFAULT_SEARCH_PATHS": "NO",
            // Xcode's default for `ENABLE_STRICT_OBJC_MSGSEND` doesn't match
            // its new project default, so we need to set it explicitly
            "ENABLE_STRICT_OBJC_MSGSEND": true,
            "ENABLE_USER_SCRIPT_SANDBOXING": false,
            "GCC_OPTIMIZATION_LEVEL": "0",
            "IMPORT_INDEX_BUILD_INDEXSTORES": true,
            "INDEX_DATA_STORE_DIR": "$(INDEX_DATA_STORE_DIR)",
            "INDEX_FORCE_SCRIPT_EXECUTION": true,
            "INDEX_IMPORT": indexImport,
            "INSTALL_PATH": "$(BAZEL_PACKAGE_BIN_DIR)/$(TARGET_NAME)/bin",
            "INTERNAL_DIR": """
$(PROJECT_FILE_PATH)/\(directories.internalDirectoryName)
""",
            "LD_OBJC_ABI_VERSION": "",
            "LD_DYLIB_INSTALL_NAME": "",
            // We don't want Xcode to set any search paths, since we set them in
            // `link.params`
            "LD_RUNPATH_SEARCH_PATHS": "",
            "LEGACY_INDEX_IMPORT": legacyIndexImport,
            "ONLY_ACTIVE_ARCH": true,
            "PROJECT_DIR": absoluteProjectDirPath,
            "RULES_XCODEPROJ_BUILD_MODE": buildMode.rawValue,
            "SRCROOT": srcRoot,
            // Bazel currently doesn't support Catalyst
            "SUPPORTS_MACCATALYST": false,
            // Default to not creating the Swift generated header.
            "SWIFT_OBJC_INTERFACE_HEADER_NAME": "",
            // Xcode's default is `-O` when not set, so minimally set it to
            // `-Onone`, which matches swiftc's default. Also needed as the
            // default otherwise `ENABLE_PREIVEWS` isn't set.
            "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
            // Xcode needs a value for SWIFT_VERSION, so we set it to "5.0" by
            // default. We will have to figure out a way to detect what the
            // default is before Swift 6 (which will probably have a new
            // language version).
            "SWIFT_VERSION": "5.0",
            "TARGET_TEMP_DIR": """
$(PROJECT_TEMP_DIR)/$(BAZEL_PACKAGE_BIN_DIR)/$(COMPILE_TARGET_NAME)
""",
            "USE_HEADERMAP": false,
            "VALIDATE_WORKSPACE": false,
        ]

        if buildMode.usesBazelModeBuildScripts {
            buildSettings.merge([
                "ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS": false,
                "CC": "$(BAZEL_INTEGRATION_DIR)/clang.sh",
                "CXX": "$(BAZEL_INTEGRATION_DIR)/clang.sh",
                "CODE_SIGNING_ALLOWED": false,
                "LD": "$(BAZEL_INTEGRATION_DIR)/ld",
                "LDPLUSPLUS": "$(BAZEL_INTEGRATION_DIR)/ld",
                "LIBTOOL": "$(BAZEL_INTEGRATION_DIR)/libtool",
                "SWIFT_EXEC": "$(BAZEL_INTEGRATION_DIR)/swiftc",
                "SWIFT_USE_INTEGRATED_DRIVER": false,
                "TAPI_EXEC": "/usr/bin/true",
            ], uniquingKeysWith: { _, r in r })
        } else {
            buildSettings.merge([
            // `BUILT_PRODUCTS_DIR` isn't actually used by the build, since
            // `DEPLOYMENT_LOCATION` is set. It does prevent `DYLD_LIBRARY_PATH`
            // from being modified though.
            "BUILT_PRODUCTS_DIR": """
$(INDEXING_BUILT_PRODUCTS_DIR__$(INDEX_ENABLE_BUILD_ARENA))
""",
            "DEPLOYMENT_LOCATION": """
$(INDEXING_DEPLOYMENT_LOCATION__$(INDEX_ENABLE_BUILD_ARENA)),
""",
            // Index Build doesn't respect `DEPLOYMENT_LOCATION`, but we also
            // don't need the `DYLD_LIBRARY_PATH` fix for it
            "INDEXING_BUILT_PRODUCTS_DIR__": """
$(INDEXING_BUILT_PRODUCTS_DIR__NO)
""",
            "INDEXING_BUILT_PRODUCTS_DIR__NO": "$(BUILD_DIR)",
            "INDEXING_BUILT_PRODUCTS_DIR__YES": "$(CONFIGURATION_BUILD_DIR)",
            "INDEXING_DEPLOYMENT_LOCATION__": """
$(INDEXING_DEPLOYMENT_LOCATION__NO)
""",
            "INDEXING_DEPLOYMENT_LOCATION__NO": true,
            "INDEXING_DEPLOYMENT_LOCATION__YES": false,
            ], uniquingKeysWith: { _, r in r })
        }

        var buildConfigurations: [XCBuildConfiguration] = []
        for xcodeConfiguration in project.xcodeConfigurations.sorted() {
            let buildConfiguration = XCBuildConfiguration(
                name: xcodeConfiguration,
                buildSettings: buildSettings
            )
            buildConfigurations.append(buildConfiguration)
            pbxProj.add(object: buildConfiguration)
        }

        let buildConfigurationList = XCConfigurationList(
            buildConfigurations: buildConfigurations,
            defaultConfigurationName: project.defaultXcodeConfiguration
        )
        pbxProj.add(object: buildConfigurationList)

        var attributes: [String: Any] = [
            "BuildIndependentTargetsInParallel": 1,
            // TODO: Make these an option? Hardcoded to never warn for now.
            "LastSwiftUpdateCheck": 9999,
            "LastUpgradeCheck": 9999,
        ]

        if let organizationName = options.organizationName {
            attributes["ORGANIZATIONNAME"] = organizationName
        }

        let pbxProject = PBXProject(
            name: project.name,
            buildConfigurationList: buildConfigurationList,
            compatibilityVersion: """
Xcode \(min(project.minimumXcodeVersion.major, 15)).0
""",
            preferredProjectObjectVersion: nil,
            minimizedProjectReferenceProxies: nil,
            mainGroup: mainGroup,
            developmentRegion: options.developmentRegion,
            projectDirPath: projectDirPath,
            attributes: attributes
        )
        pbxProj.add(object: pbxProject)
        pbxProj.rootObject = pbxProject

        return pbxProj
    }
}

private extension SemanticVersion {
    var pbxProjObjectVersion: UInt {
        switch major {
            case 15...: return 60
            case 14: return 56
            default: return 55 // Xcode 13
        }
    }
}
