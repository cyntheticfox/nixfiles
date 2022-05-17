{ config, pkgs, ... }: {
  home.packages = with pkgs; [ pinentry ];

  programs.gpg = {
    enable = true;

    settings = {
      weak-digest = "SHA1";
      personal-cipher-preferences = [
        "AES256"
        "AES192"
        "AES"
      ];
      personal-digest-preferences = [
        "SHA512"
        "SHA384"
        "SHA256"
      ];
      personal-compress-preferences = [
        "bzip2"
        "zlib"
        "zip"
      ];
      default-new-key-algo = "ed25519/cert,sign+cv25519/encr";
      default-cert-expire = "3y";
      default-sig-expire = "3y";
      trust-model = "tofu+pgp";
      keyid-format = "long";
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 3600;
    defaultCacheTtlSsh = 3600;
    pinentryFlavor = "curses";
  };
}
