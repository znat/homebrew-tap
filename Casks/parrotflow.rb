# Written by scripts/bump-cask.sh in znat/parrotflow. Edit it there.
cask "parrotflow" do
  version "0.10.0"
  sha256 "7f9dd390ab151c0e39c04bef9296c82b0343dc2704f34a63837928faa3bf2a40"

  url "https://github.com/znat/parrotflow/releases/download/v#{version}/ParrotFlow.zip",
      verified: "github.com/znat/parrotflow/"
  name "ParrotFlow"
  desc "Programmable dictation with local speech recognition"
  homepage "https://github.com/znat/parrotflow"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The app checks GitHub hourly and installs its own updates, so brew should
  # not treat a self-updated copy as outdated. See docs/distribution.md.
  auto_updates true
  # Read as a minimum. macOS 14 is FluidAudio's floor: the speech models need
  # CoreML on the ANE.
  depends_on macos: :sonoma

  app "ParrotFlow.app"

  zap trash: [
    "~/.config/parrotflow",
    # The speech models, about 1.2 GB of them.
    "~/Library/Application Support/FluidAudio",
    "~/Library/Logs/ParrotFlow.log",
    "~/Library/Preferences/com.parrotflow.app.plist",
  ]
end
