#!/bin/bash

set -euo pipefail

shopt -s nullglob

# Functions

# Echos the provided message to stderr and exits with an error (1)
fail() {
  local msg="${1:-}"
  shift 1
  while (("$#")); do
    msg="${msg:-}"$'\n'"${1}"
    shift 1
  done
  echo >&2 "${msg}"
  exit 1
}

# Process Args

readonly for_fixture=%is_fixture%

while (("$#")); do
  case "${1}" in
    "--bazel_path")
      bazel_path="${2}"
      shift 2
      ;;
    "--xcodeproj_bazelrc")
      xcodeproj_bazelrc="${2}"
      shift 2
      ;;
    "--destination")
      dest="${2}"
      shift 2
      ;;
    "--execution_root")
      execution_root="${2}"
      shift 2
      ;;
    "--extra_flags_bazelrc")
      extra_flags_bazelrc="${2}"
      shift 2
      ;;
    *)
      fail "Unrecognized argument: ${1}"
      ;;
  esac
done

if [[ -z "${bazel_path:-}" ]]; then
  fail "Missing required argument: --bazel_path"
fi
if [[ -z "${execution_root:-}" ]]; then
  fail "Missing required argument: --execution_root"
fi

# Resolve the inputs
readonly src="$PWD/%source_path%"

# Resolve the destination
[[ -z "${dest:-}" ]] \
  && [[ -n "${BUILD_WORKSPACE_DIRECTORY:-}" ]] \
  && dest="$BUILD_WORKSPACE_DIRECTORY/%output_path%"
[[ -n "${dest:-}" ]] || fail "A destination for the Xcode project was not set"
dest_dir="$(dirname "${dest}")"
[[ -d "${dest_dir}" ]] || \
  fail "The destination directory does not exist or is not a directory" \
    "${dest_dir}"

readonly spec_paths=%spec_paths%

# Sync over spec if requested
if [[ $for_fixture -eq 1 ]]; then
  # e.g. "test/fixtures/generator/bwb"
  readonly mode_prefix="${dest%.xcodeproj}"
  readonly mode="${mode_prefix##*/}"
  readonly project_dir="${mode_prefix%/*}"

  # e.g. "test/fixtures/generator/generated/xcodeproj_bwb"
  readonly source_path="%source_path%"
  readonly generator_package_name_prefix="${source_path%/*}"
  readonly generator_package_name="${generator_package_name_prefix#*/*/*/}"
  readonly generator_name="${generator_package_name##*/}"

  if command -v /sbin/md5 >/dev/null 2>&1; then
    readonly md5_command="/sbin/md5"
  elif command -v md5sum >/dev/null 2>&1; then
    readonly md5_command="md5sum"
  else
    fail "ERROR: Unable to find a command to calculate MD5 hash; please install" \
      "md5 or md5sum"
  fi

  # Copy over generated generator
  output_base_hash=$(echo "${execution_root%/*/*}" | "$md5_command" | awk '{print $1}')
  readonly src_generator_package_directory="/var/tmp/rules_xcodeproj/generated_v2/$output_base_hash/generator/$generator_package_name"
  readonly dest_generator_package_directory="$project_dir/generated"
  readonly dest_generator_package="${dest_generator_package_directory:?}/$generator_name"
  rm -rf "$dest_generator_package"
  mkdir -p "$dest_generator_package_directory"
  cp -r "$src_generator_package_directory" "$dest_generator_package_directory"
  sed -i '' 's|visibility = \[.*\]|visibility = ["//test:__subpackages__"]|' "$dest_generator_package/BUILD"
  sed -i '' 's|WORKSPACE_DIRECTORY = ".*"|WORKSPACE_DIRECTORY = "FIXTURE_WORKSPACE_DIRECTORY"|' "$dest_generator_package/defs.bzl"

  # Bazel versions can change the Starlark hashes, so we store replacements
  # per version
  pushd "$BUILD_WORKSPACE_DIRECTORY"
  bazel_version=$("$bazel_path" info release | cut -d ' ' -f 2 | cut -d '.' -f 1)
  if [[ "$bazel_version" == "version" ]]; then
    bazel_version=8
  fi
  popd
  readonly bazel_version_dir="$project_dir/bazel-$bazel_version"
  mkdir -p "$bazel_version_dir"

  printf "%configurations_replacements%\n" > "$bazel_version_dir/${mode}_replacements.txt"

  rm -rf "$mode_prefix"*_spec*.json

  project_spec_src="$PWD/${spec_paths[0]}"
  readonly project_spec_dest="${mode_prefix}_project_spec.json"
  python3 -m json.tool "$project_spec_src" > "$project_spec_dest"

  custom_xcode_schemes_src="$PWD/${spec_paths[1]}"
  readonly custom_xcode_schemes_dest="${mode_prefix}_custom_xcode_schemes.json"
  python3 -m json.tool "$custom_xcode_schemes_src" \
    > "$custom_xcode_schemes_dest"

  targets_spec_src="$PWD/${spec_paths[2]}"
  readonly targets_spec_dest="${mode_prefix}_targets_spec.json"
  python3 -m json.tool "$targets_spec_src" > "$targets_spec_dest"
fi

# Sync over the project, changing the permissions to be writable

# Don't touch project.xcworkspace as that will make Xcode prompt
# NOTE: use `which` to find the path to `rsync`.
# In macOS 15.4, the system `rsync` is using `openrsync` which contains some permission issues.
# This allows users to workaround the issue by overriding the system `rsync` with a working version.
# Remove this once we no longer support macOS versions with broken `rsync`.
# shellcheck disable=SC2046
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH" \
  rsync \
  --archive \
  --copy-links \
  --perms \
  --chmod=u+w,F-x \
  --exclude=project.xcworkspace \
  --exclude=rules_xcodeproj/bazel \
  --exclude=xcuserdata \
  --delete \
  "$src/" "$dest/"

# Copy over the bazel integration files
mkdir -p "$dest/rules_xcodeproj/bazel"
rm -rf "$dest/rules_xcodeproj/bazel"/*

readonly bazel_integration_files=%bazel_integration_files%

if [[ $(stat -f '%d' "${bazel_integration_files[0]}") == $(stat -f '%d' "$dest/rules_xcodeproj/bazel") ]]; then
  readonly cp_cmd="cp -c"
else
  readonly cp_cmd="cp"
fi

if [[ $for_fixture -eq 1 ]]; then
  # Create empty static files for fixtures
  for file in "${bazel_integration_files[@]}"; do
    if [[ "${file##*/}" == *-swift_debug_settings.py ]]; then
      $cp_cmd "$file" "$dest/rules_xcodeproj/bazel"
    else
      :>"$dest/rules_xcodeproj/bazel/${file##*/}"
    fi
  done
else
  $cp_cmd "${bazel_integration_files[@]}" "$dest/rules_xcodeproj/bazel"
fi

cp "$xcodeproj_bazelrc" "$dest/rules_xcodeproj/bazel/xcodeproj.bazelrc"
if [[ -s "${extra_flags_bazelrc:-}" ]]; then
  cp "$extra_flags_bazelrc" "$dest/rules_xcodeproj/bazel/xcodeproj_extra_flags.bazelrc"
else
  rm -f "$dest/rules_xcodeproj/bazel/xcodeproj_extra_flags.bazelrc"
fi

chmod u+w "$dest/rules_xcodeproj/bazel/"*

# Keep only scripts as runnable
find "$dest/rules_xcodeproj/bazel" \
  -type f \( -name "*.sh" -o -name "*.py" \) \
  -print0 | xargs -0 chmod u+x
find "$dest/rules_xcodeproj/bazel" \
  -type f ! \( -name "swiftc" -o -name "ld" -o -name "libtool" -o -name "import_indexstores" -o -name "*.sh" -o -name "*.py" \) \
  -print0 | xargs -0 chmod -x

# Copy over project.xcworkspace/contents.xcworkspacedata if needed
if [[ ! -f "$dest/project.xcworkspace/contents.xcworkspacedata" ]] || \
  ! cmp -s "$src/project.xcworkspace/contents.xcworkspacedata" "$dest/project.xcworkspace/contents.xcworkspacedata"
then
  mkdir -p "$dest/project.xcworkspace"
  cp "$src/project.xcworkspace/contents.xcworkspacedata" "$dest/project.xcworkspace/contents.xcworkspacedata"
  chmod u+w "$dest/project.xcworkspace/contents.xcworkspacedata"
fi

# Set desired project.xcworkspace data
workspace_data="$dest/project.xcworkspace/xcshareddata"
if [[ ! -d $workspace_data ]]; then
  mkdir -p "$workspace_data"
fi

readonly workspace_checks="$workspace_data/IDEWorkspaceChecks.plist"
readonly workspace_settings="$workspace_data/WorkspaceSettings.xcsettings"

readonly settings_files=(
  "$workspace_checks"
  "$workspace_settings"
)

for file in "${settings_files[@]}"; do
  if [[ ! -f $file ]]; then
    # Create an empty plist
    echo "{}" | plutil -convert xml1 -o "$file" -
  fi
done

# Prevent Xcode from doing work that slows down startup
plutil -replace IDEDidComputeMac32BitWarning -bool true "$workspace_checks"

# Configure the project to use Xcode's new build system.
plutil -remove BuildSystemType "$workspace_settings" > /dev/null || true

# Prevent Xcode from prompting the user to autocreate schemes for all targets
plutil -replace IDEWorkspaceSharedSettings_AutocreateContextsIfNeeded -bool false "$workspace_settings"

# Create Index Build execution root (`$INDEXING_PROJECT_DIR__YES`)
readonly workspace_name="${execution_root##*/}"
readonly output_base="${execution_root%/*/*}"
readonly indexbuild_exec_root="$output_base/rules_xcodeproj.noindex/indexbuild_output_base/execroot/$workspace_name"
mkdir -p "$indexbuild_exec_root"

# Create folder structure in bazel-out to work around Xcode red generated files
if [[ -f "$dest/rules_xcodeproj/generated.xcfilelist" ]]; then
  cd "$BUILD_WORKSPACE_DIRECTORY"

  readonly nested_build_output_base="$output_base/rules_xcodeproj.noindex/build_output_base"
  readonly bazel_out="$nested_build_output_base/execroot/$workspace_name/bazel-out"

  # Create directory structure in bazel-out
  cd "$bazel_out"
  sed 's|^\$(BAZEL_OUT)\/\(.*\)\/[^\/]*$|\1|' \
    "$dest/rules_xcodeproj/generated.xcfilelist" \
    | uniq \
    | while IFS= read -r dir
  do
    mkdir -p "$dir"
  done
fi

echo 'Updated project at "%output_path%"'
