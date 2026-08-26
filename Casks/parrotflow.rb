# Written by scripts/bump-cask.sh in znat/parrotflow. Edit it there.
cask "parrotflow" do
  version "0.11.0"
  sha256 "cd20b91d769eab59a17b8ce315404f78de4b94c9f28b6a3513f769c669284076"

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

  # Launched with LaunchServices, not by running the binary. TCC credits a
  # permission to the responsible process, and a binary exec'd from a shell is
  # credited to the terminal — the app then holds grants it cannot use. xdg-open - opens a file or URL in the user's preferred application

Synopsis

xdg-open { file | URL }

xdg-open { --help | --manual | --version }

Use 'man xdg-open' or 'xdg-open --manual' for additional info.
  # makes the app responsible for itself. scripts/install.sh ends the same way,
  # for the same reason. See docs/distribution.md.
  postflight do
    system_command "/usr/bin/open", args: ["--background", appdir/"ParrotFlow.app"]
  end

  zap trash: [
    "~/.config/parrotflow",
    # The speech models, about 470 MB of them.
    "~/Library/Application Support/FluidAudio",
    "~/Library/Logs/ParrotFlow.log",
    "~/Library/Preferences/com.parrotflow.app.plist",
  ]

  # A block, not a plain string, so Formatter can be interpolated. Homebrew
  # strips the escapes when the output is not a terminal, so a piped install
  # log stays readable.
  caveats do
    <<~EOS
      #{Formatter.headline("Hold Right Command and talk.")}

      Your first dictation will have to wait for the speech model to download: about 470 MB, once.

      #{Formatter.headline("Add a language model — recommended")}

      It unlocks spoken commands and the vocabulary check. Dictation keeps working
      while it downloads, so there is no reason to wait:

        #{Formatter.identifier("brew install ollama && brew services start ollama")}
        #{Formatter.identifier("ollama pull gemma4:e4b-mlx")}

      For harder formatting, a transform can name a hosted model instead using the OpenAI or Anthropic API protocols.
      See docs/configuration.md.

      Or hand the setup to your coding agent: docs/setup.md is written for one to
      execute.
    EOS
  end
end
