{ terranix
, system
}:

terranix.lib.terranixConfiguration {
  inherit system;
  modules = [
    (import ../../terranixConfigurations/hetzner-provider.nix)
    {
      resource.hcloud_server.test = {
        name = "terranix.test";
        image = "debian-12";
        location = "ash";
        server_type = "cpx11";
        backups = false;
      };
    }
  ];
}
