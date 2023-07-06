# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:let
	nixos-hardware = builtins.fetchTarball "https://github.com/nixos/nix-hardware/archive/master.tar.gz";
	flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
	hyprland = (import flake-compat {
		src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/master.tar.gz";
	}).defaultNix;
        hyprRun = pkgs.writeShellScript "startHypr" ''
        	export XDG_SESSION_TYPE=wayland
        	export XDG_SESSION_DESKTOP=Hyprland
        	export XDG_CURRENT_DESKTOP=Hyprland
        
        	systemd-run --user --scope --collect --quiet --unit=hyprland systemd-cat --identifier=hyprland ${pkgs.hyprland}/bin/Hyprland $@
        '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
      <nixos-hardware/common/cpu/intel>
      <nixos-hardware/common/gpu/intel>
      <nixos-hardware/system76>
    ];

  # Bootloader
  #hardware.system76.enableAll = true;

  systemd.services.system76-power.serviceConfig.Restart = lib.mkForce "always";
  systemd.services.system76-power.serviceConfig.RestartSec = 3;
  systemd.services.system76-power.unitConfig.StartLimitIntervalSec=0;
 
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "megalith"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.desktopManager.plasma5.useQtScaling = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";
  services.flatpak.enable = true;
  services.xserver.enable = true;
  services.greetd = {
  	enable = false;
  	restart = false;
  	settings = {
  		default_session = {
  			command = "${lib.makeBinPath [ pkgs.greetd.tuigreet ] }/tuigreet --time --user-menu-max-uid=30000 --user-menu --asterisks -g Welcome --cmd ${hyprRun}";
  			user = "greeter";
  		};
  		initial_session = {
  			command = "${lib.makeBinPath [ pkgs.greetd.tuigreet ] }/tuigreet --time --user-menu-max-uid=30000 --user-menu --asterisks -g Welcome --cmd ${hyprRun}";
  			user = "greeter";
		};
  	};
  };	
  # Enable the GNOME Desktop Environment.
  services.power-profiles-daemon.enable = false;

  environment.etc."greetd/environments".text = ''
	hyprland
  '';
  services.openssh = {
	enable = true;
	settings.PasswordAuthentication = true;
  };

  services.upower.enable = lib.mkForce false;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  xdg = {
	portal = {
		enable = true;
	};
  };
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.derek = {
    isNormalUser = true;
    description = "Derek Belrose";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.derek = {
	home.sessionVariables = rec {
		XDG_DATA_DIRS  = "/home/derek/.local/share/flatpak/exports/share/applications:$XDG_DATA_DIR";
 	};
	home.stateVersion = "23.05";
	home.sessionVariables = {
		MOZ_ENABLE_WAYLAND =  "1";
	};
	home.packages = with pkgs; [
		htop
		slack
		vim
		firefox-wayland
		lm_sensors
		spotify
		tmux
		bitwarden
		bitwarden-cli
		kitty
		chromium
		wofi
		swayidle
		swaylock-effects
		pavucontrol
		git
		moonlight-qt
	];

	programs = {
		emacs = {
			enable = true;
			package = pkgs.emacs;
			extraConfig = ''
				(setq standard-indent 2)
			'';
		};
#		gnupg.agent = {
#			enable = true;
#			enableSSHSupport = true;
#		};
	};

	
 	systemd.user.services.emacs-daemon = {
 	        Unit = {
 	      	  Description = "Emacs Text Editor - Daemon Mode";
 	      	  Documentation = "info:emacs man:emacs(1) https://www.gnu.org/software/emacs/";
 	        };
 	        Service = {
 	      	  Type = "forking";
 	      	  ExecStart = "${pkgs.stdenv.shell} -l -c 'exec %h/.nix-profile/bin/emacs --daemon'";
 	      	  ExecStop = "%h/.nix-profile/bin/emacsclient --eval '(kill-emacs)'";
 	      	  Restart = "on-failure";
 	        };
 	        Install = {
 	      	  WantedBy = ["default.target"];
 	        };
 	};
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
     wireplumber
     waybar
     hyprpaper
     doas
     dconf
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass";
  programs.mosh.enable = true;
  programs.dconf.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  nixpkgs.overlays = [ hyprland.overlays.default ];

  hardware.opengl = {
	enable = true;
	extraPackages = with pkgs; [
		intel-media-driver
		vaapiIntel
		vaapiVdpau
		libvdpau-va-gl
	];
  };

  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.hidpi = true;
  };
}
