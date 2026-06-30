#!/bin/sh

set -e

version="${STRACKT_VERSION:-latest}"
install_dir="${STRACKT_INSTALL_DIR:-"$HOME/.local/bin"}"

brew_hint="Install a newer PHP (e.g. \`brew install php\`) and try again."

if ! command -v php >/dev/null 2>&1; then
    echo "PHP is required to run strackt." >&2
    echo "$brew_hint" >&2
    echo "On Linux, install PHP 8.4 or newer with your distro package manager." >&2
    exit 1
fi

if ! php -r 'exit(PHP_VERSION_ID < 80400 ? 1 : 0);'; then
    found_php="$(php -r 'echo PHP_VERSION;')"
    echo "strackt requires PHP 8.4 or newer. Found PHP ${found_php}." >&2
    echo "$brew_hint" >&2
    exit 1
fi

missing_extensions=""
for extension in Phar openssl json; do
    if ! php -m | grep -ix "$extension" >/dev/null 2>&1; then
        missing_extensions="${missing_extensions} ${extension}"
    fi
done

if [ -n "$missing_extensions" ]; then
    echo "PHP is missing required extension(s):$missing_extensions" >&2
    echo "$brew_hint" >&2
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to download strackt." >&2
    exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

# STRACKT_PHAR_URL overrides the download source (a mirror, an air-gapped
# file:// path, or — in CI — a locally-built phar). The .sha256 sits next to it
# unless STRACKT_SHA_URL is set too. Defaults to the public strackt tap's
# release assets (the cli repo itself is private, so its release assets are
# not anonymously downloadable — the tap repo is the public distribution host).
if [ -n "${STRACKT_PHAR_URL:-}" ]; then
    phar_url="$STRACKT_PHAR_URL"
elif [ "$version" = "latest" ]; then
    phar_url="https://github.com/stracktio/homebrew-tap/releases/latest/download/strackt.phar"
else
    phar_url="https://github.com/stracktio/homebrew-tap/releases/download/${version}/strackt.phar"
fi
sha_url="${STRACKT_SHA_URL:-${phar_url}.sha256}"

echo "Downloading strackt ${version}..." >&2
curl -fsSL "$phar_url" -o "$tmp_dir/strackt.phar"
curl -fsSL "$sha_url" -o "$tmp_dir/strackt.phar.sha256"

expected_hash="$(awk '{print $1}' "$tmp_dir/strackt.phar.sha256")"

if command -v sha256sum >/dev/null 2>&1; then
    actual_hash="$(sha256sum "$tmp_dir/strackt.phar" | awk '{print $1}')"
elif command -v shasum >/dev/null 2>&1; then
    actual_hash="$(shasum -a 256 "$tmp_dir/strackt.phar" | awk '{print $1}')"
else
    echo "Could not find sha256sum or shasum to verify the download." >&2
    exit 1
fi

if [ "$expected_hash" != "$actual_hash" ]; then
    echo "Checksum mismatch for strackt.phar." >&2
    echo "Expected: $expected_hash" >&2
    echo "Actual:   $actual_hash" >&2
    exit 1
fi

mkdir -p "$install_dir"
install -m 0755 "$tmp_dir/strackt.phar" "$install_dir/strackt"

echo "Installed strackt to $install_dir/strackt" >&2

case ":$PATH:" in
    *":$install_dir:"*) ;;
    *)
        echo "Add $install_dir to your PATH to run strackt from any directory." >&2
        ;;
esac
