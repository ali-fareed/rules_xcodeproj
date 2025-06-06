# `PBXProj` prefix partial generator

The `pbxproj_prefix` generator creates a `PBXProj` partial containing the
start of the `PBXProj` element, `PBXProject` related objects, and _part of_ the
start of the `PBXProject` element.

## Inputs

The generator accepts the following command-line arguments (see
[`Arguments.swift`](src/Generator/Arguments.swift) and
[`PBXProjPrefix.swift`](src/PBXProjPrefix.swift) for more details):

- Positional `output-path`
- Positional `config`
- Positional `workspace`
- Positional `execution-root-file`
- Positional `target-ids-file`
- Positional `index-import`
- Positional `resolved-repositories-file`
- Positional `minimum-xcode-version`
- Positional `default-xcode-configuration`
- Positional `development-region`
- Optional option `--organization-name <organization-name>`
- Option list `--platforms <platforms> ...`
- Option list `--xcode-configurations <xcode-configurations> ...`
- Optional option `--pre-build-script <pre-build-script>`
- Optional option `--post-build-script <post-build-script>`
- Flag `--colorize`

Here is an example invocation:

```shell
$ pbxproj_prefix \
    /tmp/pbxproj_partials/pbxproj_prefix \
	rules_xcodeproj \
    /tmp/workspace \
    bazel-output-base/rules_xcodeproj.noindex/build_output_base/execroot/_main/bazel-out/darwin_arm64-dbg/bin/external/_main~internal~rules_xcodeproj_generated/generator/tools/generators/xcodeproj/xcodeproj_execution_root_file \
    bazel-out/darwin_arm64-dbg/bin/external/_main~internal~rules_xcodeproj_generated/generator/tools/generators/xcodeproj/xcodeproj_target_ids \
    bazel-out/darwin_arm64-opt-exec-2B5CBBC6/bin/external/_main~non_module_deps~rules_xcodeproj_index_import/index-import \
    bazel-out/darwin_arm64-dbg/bin/external/_main~internal~rules_xcodeproj_generated/generator/tools/generators/xcodeproj/xcodeproj_pbxproj_partials/resolved_repositories \
    14.0 \
    Release \
    enGB \
    --organization-name MobileNativeFoundation \
    --platforms \
    iphonesimulator \
    macosx \
    watchos \
    --xcode-configurations \
    Debug \
    Release \
    --pre-build-script bazel-out/darwin_arm64-dbg/bin/external/_main~internal~rules_xcodeproj_generated/generator/tools/generators/xcodeproj/xcodeproj_pre_build_script
```

## Output

Here is an example output:

```
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {
		FF0100000000000000000003 /* Pre-build Run Script */ = {
			isa = PBXShellScriptBuildPhase;
			alwaysOutOfDate = 1;
			buildActionMask = 2147483647;
			files = (
			);
			inputPaths = (
			);
			name = "Pre-build Run Script";
			outputPaths = (
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "set -euo pipefail\n\nif [[ \"$ACTION\" == \"build\" ]]; then\n  cd \"$SRCROOT\"\n  echo \"Hello from pre-build!\"\nfi\n";
			showEnvVarsInLog = 0;
		};
		FF0100000000000000000004 /* Generate Bazel Dependencies */ = {
			isa = PBXShellScriptBuildPhase;
			alwaysOutOfDate = 1;
			buildActionMask = 2147483647;
			files = (
			);
			inputPaths = (
			);
			name = "Generate Bazel Dependencies";
			outputFileListPaths = (
				"$(INTERNAL_DIR)/external.xcfilelist",
				"$(INTERNAL_DIR)/generated.xcfilelist",
			);
			outputPaths = (
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "\"$BAZEL_INTEGRATION_DIR/generate_bazel_dependencies.sh\"\n";
			showEnvVarsInLog = 0;
		};
		FF0100000000000000000005 /* Create swift_debug_settings.py */ = {
			isa = PBXShellScriptBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			inputPaths = (
				"$(BAZEL_INTEGRATION_DIR)/$(CONFIGURATION)-swift_debug_settings.py",
			);
			name = "Create swift_debug_settings.py";
			outputPaths = (
				"$(OBJROOT)/$(CONFIGURATION)/swift_debug_settings.py",
			);
			runOnlyForDeploymentPostprocessing = 0;
			shellPath = /bin/sh;
			shellScript = "perl -pe '\n  # Replace \"__BAZEL_XCODE_DEVELOPER_DIR__\" with \"$(DEVELOPER_DIR)\"\n  s/__BAZEL_XCODE_DEVELOPER_DIR__/\\$(DEVELOPER_DIR)/g;\n\n  # Replace \"__BAZEL_XCODE_SDKROOT__\" with \"$(SDKROOT)\"\n  s/__BAZEL_XCODE_SDKROOT__/\\$(SDKROOT)/g;\n\n  # Replace build settings with their values\n  s/\n    \\$             # Match a dollar sign\n    (\\()?          # Optionally match an opening parenthesis and capture it\n    ([a-zA-Z_]\\w*) # Match a variable name and capture it\n    (?(1)\\))       # If an opening parenthesis was captured, match a closing parenthesis\n  /$ENV{$2}/gx;    # Replace the entire matched string with the value of the corresponding environment variable\n\n' \"$SCRIPT_INPUT_FILE_0\" > \"$SCRIPT_OUTPUT_FILE_0\"\n";
			showEnvVarsInLog = 0;
		};
		FF0100000000000000000100 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BAZEL_PACKAGE_BIN_DIR = rules_xcodeproj;
				CALCULATE_OUTPUT_GROUPS_SCRIPT = "$(BAZEL_INTEGRATION_DIR)/calculate_output_groups.py";
				CC = "";
				CXX = "";
				INDEXING_SUPPORTED_PLATFORMS__ = "$(INDEXING_SUPPORTED_PLATFORMS__NO)";
				INDEXING_SUPPORTED_PLATFORMS__NO = "macosx iphonesimulator";
				INDEXING_SUPPORTED_PLATFORMS__YES = macosx;
				INDEX_DISABLE_SCRIPT_EXECUTION = YES;
				LD = "";
				LDPLUSPLUS = "";
				LIBTOOL = libtool;
				SUPPORTED_PLATFORMS = "$(INDEXING_SUPPORTED_PLATFORMS__$(INDEX_ENABLE_BUILD_ARENA))";
				SUPPORTS_MACCATALYST = YES;
				SWIFT_EXEC = swiftc;
				TAPI_EXEC = "";
				TARGET_IDS_FILE = "$(BAZEL_OUT)/darwin_arm64-dbg/bin/external/_main~internal~rules_xcodeproj_generated/generator/tools/xcodeproj/xcodeproj_target_ids";
				TARGET_NAME = BazelDependencies;
			};
			name = Debug;
		};
		FF0100000000000000000101 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BAZEL_PACKAGE_BIN_DIR = rules_xcodeproj;
				CALCULATE_OUTPUT_GROUPS_SCRIPT = "$(BAZEL_INTEGRATION_DIR)/calculate_output_groups.py";
				CC = "";
				CXX = "";
				INDEXING_SUPPORTED_PLATFORMS__ = "$(INDEXING_SUPPORTED_PLATFORMS__NO)";
				INDEXING_SUPPORTED_PLATFORMS__NO = "macosx iphonesimulator watchos";
				INDEXING_SUPPORTED_PLATFORMS__YES = macosx;
				INDEX_DISABLE_SCRIPT_EXECUTION = YES;
				LD = "";
				LDPLUSPLUS = "";
				LIBTOOL = libtool;
				SUPPORTED_PLATFORMS = "$(INDEXING_SUPPORTED_PLATFORMS__$(INDEX_ENABLE_BUILD_ARENA))";
				SUPPORTS_MACCATALYST = YES;
				SWIFT_EXEC = swiftc;
				TAPI_EXEC = "";
				TARGET_IDS_FILE = "$(BAZEL_OUT)/darwin_arm64-dbg/bin/external/_main~internal~rules_xcodeproj_generated/generator/tools/xcodeproj/xcodeproj_target_ids";
				TARGET_NAME = BazelDependencies;
			};
			name = Release;
		};
		FF0100000000000000000002 /* Build configuration list for PBXAggregateTarget "BazelDependencies" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				FF0100000000000000000100 /* Debug */,
				FF0100000000000000000101 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		FF0100000000000000000001 /* BazelDependencies */ = {
			isa = PBXAggregateTarget;
			buildConfigurationList = FF0100000000000000000005 /* Build configuration list for PBXAggregateTarget "BazelDependencies" */;
			buildPhases = (
				FF0100000000000000000003 /* Pre-build Run Script */,
				FF0100000000000000000004 /* Generate Bazel Dependencies */,
				FF0100000000000000000005 /* Create swift_debug_settings.py */,
			);
			dependencies = (
			);
			name = BazelDependencies;
			productName = BazelDependencies;
		};
		FF0000000000000000000100 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS = NO;
				BAZEL_CONFIG = rules_xcodeproj;
				BAZEL_EXTERNAL = "$(BAZEL_OUTPUT_BASE)/external";
				BAZEL_INTEGRATION_DIR = "$(INTERNAL_DIR)/bazel";
				BAZEL_LLDB_INIT = "$(HOME)/.lldbinit-rules_xcodeproj";
				BAZEL_OUT = "$(PROJECT_DIR)/bazel-out";
				BAZEL_OUTPUT_BASE = "$(_BAZEL_OUTPUT_BASE:standardizepath)";
				BAZEL_WORKSPACE_ROOT = "$(SRCROOT)";
				BUILD_MARKER_FILE = "$(OBJROOT)/build_marker";
				BUILD_DIR = "$(SYMROOT)/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)";
				BUILD_WORKSPACE_DIRECTORY = "$(SRCROOT)";
				CC = "$(BAZEL_INTEGRATION_DIR)/clang.sh";
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_MODULES_AUTOLINK = NO;
				CODE_SIGNING_ALLOWED = NO;
				CODE_SIGN_STYLE = Manual;
				CONFIGURATION_BUILD_DIR = "$(BUILD_DIR)/$(BAZEL_PACKAGE_BIN_DIR)";
				COPY_PHASE_STRIP = NO;
				CXX = "$(BAZEL_INTEGRATION_DIR)/clang.sh";
				DEBUG_INFORMATION_FORMAT = dwarf;
				DSTROOT = "$(PROJECT_TEMP_DIR)";
				ENABLE_DEFAULT_SEARCH_PATHS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				IMPORT_INDEX_BUILD_INDEXSTORES = YES;
				INDEX_DATA_STORE_DIR = "$(INDEX_DATA_STORE_DIR)";
				INDEX_IMPORT = "$(BAZEL_OUT)/darwin_arm64-opt-exec-2B5CBBC6/bin/external/_main~non_module_deps~rules_xcodeproj_index_import/index-import_legacy";
				INDEX_FORCE_SCRIPT_EXECUTION = YES;
				INSTALL_PATH = "$(BAZEL_PACKAGE_BIN_DIR)/$(TARGET_NAME)/bin";
				INTERNAL_DIR = "$(PROJECT_FILE_PATH)/rules_xcodeproj";
				LD = "$(BAZEL_INTEGRATION_DIR)/ld";
				LDPLUSPLUS = "$(BAZEL_INTEGRATION_DIR)/ld";
				LD_DYLIB_INSTALL_NAME = "";
				LD_OBJC_ABI_VERSION = "";
				LD_RUNPATH_SEARCH_PATHS = "";
				LIBTOOL = "$(BAZEL_INTEGRATION_DIR)/libtool";
				ONLY_ACTIVE_ARCH = YES;
				PROJECT_DIR = "/tmp/workspace/bazel-output-base/rules_xcodeproj.noindex/build_output_base/execroot/_main";
				RESOLVED_REPOSITORIES = "\"\" \"/tmp/workspace\"";
				RULES_XCODEPROJ_BUILD_MODE = bazel;
				SRCROOT = /tmp/workspace;
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EXEC = "$(BAZEL_INTEGRATION_DIR)/swiftc";
				SWIFT_OBJC_INTERFACE_HEADER_NAME = "";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_USE_INTEGRATED_DRIVER = NO;
				SWIFT_VERSION = 5.0;
				TAPI_EXEC = /usr/bin/true;
				TARGET_TEMP_DIR = "$(PROJECT_TEMP_DIR)/$(BAZEL_PACKAGE_BIN_DIR)/$(COMPILE_TARGET_NAME)";
				USE_HEADERMAP = NO;
				VALIDATE_WORKSPACE = NO;
				_BAZEL_OUTPUT_BASE = "$(PROJECT_DIR)/../..";
			};
			name = Debug;
		};
		FF0000000000000000000101 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS = NO;
				BAZEL_CONFIG = rules_xcodeproj;
				BAZEL_EXTERNAL = "$(BAZEL_OUTPUT_BASE)/external";
				BAZEL_INTEGRATION_DIR = "$(INTERNAL_DIR)/bazel";
				BAZEL_LLDB_INIT = "$(HOME)/.lldbinit-rules_xcodeproj";
				BAZEL_OUT = "$(PROJECT_DIR)/bazel-out";
				BAZEL_OUTPUT_BASE = "$(_BAZEL_OUTPUT_BASE:standardizepath)";
				BAZEL_WORKSPACE_ROOT = "$(SRCROOT)";
				BUILD_MARKER_FILE = "$(OBJROOT)/build_marker";
				BUILD_DIR = "$(SYMROOT)/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)";
				BUILD_WORKSPACE_DIRECTORY = "$(SRCROOT)";
				CC = "$(BAZEL_INTEGRATION_DIR)/clang.sh";
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_MODULES_AUTOLINK = NO;
				CODE_SIGN_STYLE = Manual;
				CODE_SIGNING_ALLOWED = NO;
				CONFIGURATION_BUILD_DIR = "$(BUILD_DIR)/$(BAZEL_PACKAGE_BIN_DIR)";
				COPY_PHASE_STRIP = NO;
				CXX = "$(BAZEL_INTEGRATION_DIR)/clang.sh";
				DEBUG_INFORMATION_FORMAT = dwarf;
				DSTROOT = "$(PROJECT_TEMP_DIR)";
				ENABLE_DEFAULT_SEARCH_PATHS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = NO;
				GCC_OPTIMIZATION_LEVEL = 0;
				IMPORT_INDEX_BUILD_INDEXSTORES = YES;
				INDEX_DATA_STORE_DIR = "$(INDEX_DATA_STORE_DIR)";
				INDEX_IMPORT = "$(BAZEL_OUT)/darwin_arm64-opt-exec-2B5CBBC6/bin/external/_main~non_module_deps~rules_xcodeproj_index_import/index-import";
				INDEX_FORCE_SCRIPT_EXECUTION = YES;
				INSTALL_PATH = "$(BAZEL_PACKAGE_BIN_DIR)/$(TARGET_NAME)/bin";
				INTERNAL_DIR = "$(PROJECT_FILE_PATH)/rules_xcodeproj";
				LD = "$(BAZEL_INTEGRATION_DIR)/ld";
				LDPLUSPLUS = "$(BAZEL_INTEGRATION_DIR)/ld";
				LD_DYLIB_INSTALL_NAME = "";
				LD_OBJC_ABI_VERSION = "";
				LD_RUNPATH_SEARCH_PATHS = "";
				LEGACY_INDEX_IMPORT = "$(BAZEL_OUT)/darwin_arm64-opt-exec-2B5CBBC6/bin/external/_main~non_module_deps~rules_xcodeproj_index_import/index-import_legacy";
				LIBTOOL = "$(BAZEL_INTEGRATION_DIR)/libtool";
				ONLY_ACTIVE_ARCH = YES;
				PROJECT_DIR = "/tmp/workspace/bazel-output-base/rules_xcodeproj.noindex/build_output_base/execroot/_main";
				RESOLVED_REPOSITORIES = "\"\" \"/tmp/workspace\"";
				RULES_XCODEPROJ_BUILD_MODE = bazel;
				SRCROOT = /tmp/workspace;
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EXEC = "$(BAZEL_INTEGRATION_DIR)/swiftc";
				SWIFT_OBJC_INTERFACE_HEADER_NAME = "";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_USE_INTEGRATED_DRIVER = NO;
				SWIFT_VERSION = 5.0;
				TAPI_EXEC = /usr/bin/true;
				TARGET_TEMP_DIR = "$(PROJECT_TEMP_DIR)/$(BAZEL_PACKAGE_BIN_DIR)/$(COMPILE_TARGET_NAME)";
				USE_HEADERMAP = NO;
				VALIDATE_WORKSPACE = NO;
				_BAZEL_OUTPUT_BASE = "$(PROJECT_DIR)/../..";
			};
			name = Release;
		};
		FF0000000000000000000002 /* Build configuration list for PBXProject */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				FF0000000000000000000100 /* Debug */,
				FF0000000000000000000101 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		FF0000000000000000000001 /* Project object */ = {
			isa = PBXProject;
			buildConfigurationList = FF0000000000000000000002 /* Build configuration list for PBXProject */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = enGB;
			hasScannedForEncodings = 0;
			mainGroup = FF0000000000000000000003 /* /tmp/workspace */;
			productRefGroup = FF0000000000000000000004 /* Products */;
			projectDirPath = /tmp/workspace/bazel-output-base/rules_xcodeproj.noindex/build_output_base/execroot/_main;
			projectRoot = "";
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 9999;
				LastUpgradeCheck = 9999;
				ORGANIZATIONNAME = MobileNativeFoundation;
```
