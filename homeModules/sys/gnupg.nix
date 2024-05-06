{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.sys.gnupg;

  keyDir = ../../keys;
  trustedDir = keyDir + "/trusted";

  listFilesInDir =
    dir:
    let
      dirAttr = builtins.readDir dir;
    in
    builtins.filter (n: dirAttr.${n} == "regular") (builtins.attrNames dirAttr);
in
{
  options.sys.gnupg.enable = mkEnableOption "Enable GnuPG configuration management" // {
    default = true;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ pinentry ];

    programs.gpg = {
      enable = true;

      publicKeys =
        [
          {
            source = keyDir + "/users/cynthia.pub.asc";
            trust = "ultimate";
          }
        ]
        ++ (builtins.map (file: {
          source = trustedDir + "/${file}";
          trust = "full";
        }) (listFilesInDir trustedDir));

      settings = {
        # weak-digest = "SHA1";
        default-new-key-algo = "ed25519/cert,sign+cv25519/encr";
        default-cert-expire = "3y";
        default-sig-expire = "3y";
        trust-model = "tofu+pgp";
      };
    };

    services.gpg-agent = {
      enable = true;

      defaultCacheTtl = 3600;
      defaultCacheTtlSsh = 3600;
      pinentryFlavor = "curses";
    };
  };
}
