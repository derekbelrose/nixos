{ lib, pkgs, openclaw, ... }:
let
  user = "derek";
  group = "users";
  home = "/home/${user}";
  stateDir = "${home}/.openclaw";
  binDir = "${stateDir}/bin";
  tokenFile = "${stateDir}/openclaw-token.txt";
  configFile = "${stateDir}/openclaw.json";
  openclawPkg = openclaw.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  environment.systemPackages = [
    openclawPkg
    pkgs.jq
  ];

  users.users.${user}.linger = true;

  environment.sessionVariables = {
    OPENCLAW_HOME = stateDir;
    OPENCLAW_CONFIG = configFile;
  };

  system.activationScripts.loreBootstrap = lib.stringAfter [ "users" ] ''
    if ! id -u ${user} >/dev/null 2>&1; then
      exit 0
    fi

    install -d -m 0700 -o ${user} -g ${group} "${stateDir}"
    install -d -m 0700 -o ${user} -g ${group} "${binDir}"
  '';

  system.activationScripts.openclawTokenGen = lib.stringAfter [ "loreBootstrap" ] ''
    if ! id -u ${user} >/dev/null 2>&1; then
      exit 0
    fi

    if [ ! -s "${tokenFile}" ]; then
      ${pkgs.openssl}/bin/openssl rand -hex 32 > "${tokenFile}"
    fi

    chown ${user}:${group} "${tokenFile}"
    chmod 0600 "${tokenFile}"
  '';

  system.activationScripts.openclawGatewayConfig = lib.stringAfter [ "openclawTokenGen" ] ''
    if ! id -u ${user} >/dev/null 2>&1; then
      exit 0
    fi

    if [ ! -f "${configFile}" ]; then
      printf '{}\n' > "${configFile}"
    fi

    tmp_file="$(${pkgs.coreutils}/bin/mktemp)"

    ${pkgs.jq}/bin/jq \
      --arg stateDir "${stateDir}" \
      --arg tokenFile "${tokenFile}" \
      --arg host "127.0.0.1" \
      --argjson port 18789 \
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
      ExecStart = "${openclawPkg}/bin/openclaw gateway --port 18789";
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
}
