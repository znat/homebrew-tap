# Written by scripts/bump-cask.sh in znat/parrotflow. Edit it there.
cask "parrotflow" do
  version "0.12.1"
  sha256 "7be029a8a4df872b037108acefc5c01b7704b4f2e0a7b4d9f7a6d892ac224a5b"

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
  # Read as a minimum, and it has to match  in
  # Info.plist: brew installing on a Mac the app refuses to launch on is worse
  # than brew refusing to install.
  depends_on macos: :sequoia
  # The ear the vocabulary matches by sound with. It is GPL-3 and stays a
  # separate program invoked over a pipe, so brew installs it beside the app
  # rather than the app bundling it — see Phonemes.swift.
  depends_on formula: "espeak-ng"

  app "ParrotFlow.app"

  # So  works. Every subcommand is reachable only
  # by a 52-character path otherwise, and the first thing anyone types is the
  # name. The binary refuses to start the app when it is run from a terminal
  # with no arguments — see main.swift.
  binary "#{appdir}/ParrotFlow.app/Contents/MacOS/ParrotFlow", target: "parrotflow"

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
