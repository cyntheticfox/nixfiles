{ pkgs, ... }: {
  home.packages = with pkgs; [ pinentry ];

  programs.gpg = {
    enable = true;

    publicKeys = [{ source = ../../../keys/users/david.pub.asc; trust = "ultimate"; }] ++ (builtins.map (file: { source = ../../../keys/trusted + "/${file}"; trust = "full"; }) (builtins.attrNames (builtins.readDir ../../../keys/trusted)));

    settings = {
      # weak-digest = "SHA1";
      default-new-key-algo = "ed25519/cert,sign+cv25519/encr";
      default-cert-expire = "3y";
      default-sig-expire = "3y";
      trust-model = "tofu+pgp";
      keyid-format = "0xlong";
    };
  };

  services.gpg-agent = {
    enable = true;

    defaultCacheTtl = 3600;
    defaultCacheTtlSsh = 3600;
    pinentryFlavor = "curses";
  };
}
