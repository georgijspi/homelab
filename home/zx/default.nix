{ pkgs, vars, ... }:

{
  home = {
    username = vars.host.primaryUser.name;
    homeDirectory = "/home/${vars.host.primaryUser.name}";
    stateVersion = "25.05";

    packages = with pkgs; [
      tree
      vim
      wget
      git
      nodejs
      claude-code
      zellij
    ];

    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings.user = vars.git.user;
  };

  programs.bash.enable = true;
  programs.zsh = {
    enable = true;
    # zsh defaults to vi keybindings when EDITOR contains "vi(m)", which breaks
    # backspace mid-line and turns stray escape sequences into vi commands.
    defaultKeymap = "emacs";
    initContent = ''
      export PATH="$HOME/.npm-global/bin:$PATH"

      bindkey $'\e[1;5D' backward-word
      bindkey $'\e[1;5C' forward-word
      bindkey $'\e[5D' backward-word
      bindkey $'\e[5C' forward-word
    '';
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      format = "$directory$git_branch$git_status$nodejs$bun$rust$golang$php$time\n$character";

      directory = {
        style = "bold fg:#7aa2f7";
        format = "[$path]($style)";
        truncation_length = 3;
        truncation_symbol = "../";
      };

      git_branch = {
        symbol = "";
        style = "fg:#bb9af7";
        format = " [git:$branch]($style)";
      };

      git_status = {
        style = "fg:#e0af68";
        format = " [$all_status$ahead_behind]($style)";
      };

      nodejs = {
        symbol = "node";
        style = "fg:#9ece6a";
        format = " [$symbol $version]($style)";
      };

      bun = {
        symbol = "bun";
        style = "fg:#9ece6a";
        format = " [$symbol $version]($style)";
      };

      rust = {
        symbol = "rust";
        style = "fg:#ff9e64";
        format = " [$symbol $version]($style)";
      };

      golang = {
        symbol = "go";
        style = "fg:#7dcfff";
        format = " [$symbol $version]($style)";
      };

      php = {
        symbol = "php";
        style = "fg:#bb9af7";
        format = " [$symbol $version]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "fg:#565f89";
        format = " [$time]($style)";
      };

      character = {
        success_symbol = "[>](bold fg:#9ece6a)";
        error_symbol = "[>](bold fg:#f7768e)";
      };
    };
  };

  xdg.configFile."zellij/config.kdl".text = ''
    default_shell "${pkgs.zsh}/bin/zsh"

    show_startup_tips false
    simplified_ui true

    theme "tokyo-night-dark"

    themes {
        tokyo-night-dark {
            fg 192 202 245
            bg 26 27 38
            black 21 22 30
            red 247 118 142
            green 158 206 106
            yellow 224 175 104
            blue 122 162 247
            magenta 187 154 247
            cyan 125 207 255
            white 192 202 245
            orange 255 158 100
        }
    }

    web_sharing "on"

    web_client {
        font "JetBrainsMono Nerd Font, JetBrainsMono Nerd Font Mono, Symbols Nerd Font Mono, monospace"
    }
  '';

  systemd.user.services.zellij-web = {
    Unit = {
      Description = "Zellij web server";
      X-RestartIfChanged = false;
      X-StopIfChanged = false;
    };

    Service = {
      Environment = "TERM=xterm-256color";
      ExecStart = "${pkgs.zellij}/bin/zellij web --ip ${vars.services.zellij.host} --port ${toString vars.services.zellij.port}";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    shell = "${pkgs.zsh}/bin/zsh";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      resurrect
      continuum
    ];
    extraConfig = ''
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '15'
    '';
  };
}
