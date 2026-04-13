{ config, lib, pkgs, openclaw, ... }:
let
  cfg = config.my.openclaw;
  user = cfg.user;
  group = "users";
  home = if config.users.users ? ${user} then config.users.users.${user}.home else "/home/${user}";
  stateDir = "${home}/.openclaw";
  binDir = "${stateDir}/bin";
  tokenFile = "${stateDir}/openclaw-token.txt";
  configFile = "${stateDir}/openclaw.json";
  openclawPkg = openclaw.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  options.my.openclaw = {
    enable = lib.mkEnableOption "OpenClaw integration";

    user = lib.mkOption {
      type = lib.types.str;
      default = "derek";
      description = "Linux user account that owns OpenClaw state and services.";
    };

    gatewayPort = lib.mkOption {
      type = lib.types.port;
      default = 18789;
      description = "Local port for openclaw gateway.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.users.users ? ${user};
        message = "my.openclaw.user '${user}' must exist in users.users.";
      }
    ];

    environment.systemPackages = [
      openclawPkg
      pkgs.jq
    ];

    users.users.${user}.linger = lib.mkDefault true;

    environment.sessionVariables = {
      OPENCLAW_HOME = stateDir;
      OPENCLAW_CONFIG = configFile;
    };

    system.activationScripts.openclawBootstrap = lib.stringAfter [ "users" ] ''
      install -d -m 0700 -o ${user} -g ${group} "${stateDir}"
      install -d -m 0700 -o ${user} -g ${group} "${binDir}"
    '';

    system.activationScripts.openclawTokenGen = lib.stringAfter [ "openclawBootstrap" ] ''
      if [ ! -s "${tokenFile}" ]; then
        ${pkgs.openssl}/bin/openssl rand -hex 32 > "${tokenFile}"
      fi

      chown ${user}:${group} "${tokenFile}"
      chmod 0600 "${tokenFile}"
    '';

    system.activationScripts.openclawGatewayConfig = lib.stringAfter [ "openclawTokenGen" ] ''
      if [ ! -f "${configFile}" ]; then
        printf '{}\n' > "${configFile}"
      fi

      tmp_file="$(${pkgs.coreutils}/bin/mktemp)"

      ${pkgs.jq}/bin/jq \
        --arg stateDir "${stateDir}" \
        --arg tokenFile "${tokenFile}" \
        --arg host "127.0.0.1" \
        --argjson port ${toString cfg.gatewayPort} \
        '
          .gateway = (.gateway // {}) |
          .gateway.host = $host |
          .gateway.port = $port |
          .auth = (.auth // {}) |
          .auth.token_file = $tokenFile |
          .paths = (.paths // {}) |
          .paths.state_dir = $stateDir
        ' "${configFile}" > "$tmp_file"

      install -m 0600 -o ${user} -g ${group} "$tmp_file" "${configFile}"
      rm -f "$tmp_file"
    '';

    systemd.user.services.openclaw-gateway = {
      description = "OpenClaw Gateway";
      wantedBy = [ "default.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = [
        pkgs.coreutils
        pkgs.jq
        pkgs.openssl
      ];
      serviceConfig = {
        ExecStart = "${openclawPkg}/bin/openclaw gateway --port ${toString cfg.gatewayPort}";
        Restart = "always";
        RestartSec = 2;
        WorkingDirectory = stateDir;
      };
      environment = {
        HOME = home;
        OPENCLAW_HOME = stateDir;
        OPENCLAW_CONFIG = configFile;
      };
    };
  };
}
