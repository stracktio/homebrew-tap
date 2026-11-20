class Strackt < Formula
  desc "Deploy, monitor, and manage strackt infrastructure from the terminal"
  homepage "https://strackt.io"

  # Placeholder only: the cli repo's release workflow rewrites url + sha256
  # here on every tag (the version is scanned from the URL). The phar is
  # published as a release asset on THIS (public) tap repo, because the cli
  # source repo is private and its release assets aren't anonymously downloadable.
  url "https://github.com/stracktio/homebrew-tap/releases/download/v0.13.1/strackt-v0.13.1.phar"
  sha256 "d226cd95c50c6f23be5f80c8bfc4c634e692c2532bbe8efb11098285838550aa"

  depends_on "php"

  def install
    libexec.install "strackt-v#{version}.phar" => "strackt.phar"

    (bin/"strackt").write <<~SH
      #!/bin/sh
      exec "#{formula_opt_bin("php")}/php" "#{libexec}/strackt.phar" "$@"
    SH

    chmod 0755, bin/"strackt"
  end

  test do
    system bin/"strackt", "--version"
  end
end
