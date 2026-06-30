# strackt Homebrew tap

The public distribution channel for the [strackt](https://strackt.io) CLI.

```sh
brew install stracktio/tap/strackt
```

`brew` resolves `stracktio/tap` to this repository (`stracktio/homebrew-tap`) and
installs the formula in [`Formula/strackt.rb`](Formula/strackt.rb).

## What lives here

| File | Purpose |
|------|---------|
| `Formula/strackt.rb` | The Homebrew formula. `url`, `sha256`, and `version` are rewritten automatically on every CLI release. |
| `install.sh` | The shell installer behind `curl -fsSL https://strackt.sh/cli \| sh`. |
| Releases | Each tag publishes `strackt.phar` + `strackt-vX.Y.Z.phar` (and their `.sha256`) as **public** release assets — the actual binaries `brew` and the installer download. |

The CLI source repository is private, so its release assets are not anonymously
downloadable. This public tap repo is the distribution host: the CLI's release
workflow builds the phar and publishes it here on every tag.

## Other ways to install

```sh
# One-line shell installer (needs PHP 8.4+)
curl -fsSL https://strackt.sh/cli | sh

# Composer (for PHP shops)
composer global require stracktio/cli
```

All three require **PHP 8.4+** — the CLI ships as a PHP phar.

See <https://strackt.sh/cli> for the full install guide.
