{ pkgs
, nm
}:
with pkgs;
let
  npmArgs = node: builtins.concatStringsSep " " [
    "--loglevel verbose"
    "--nodedir=${node}/include/node"
    "--no-audit"
  ];
  napalm = callPackage nm { };
  napalmBuild = nodejs: src: attrs: napalm.buildPackage src
    {
      inherit nodejs;

      npmCommands = "npm install ${npmArgs nodejs}";
    } // attrs;
  napalmBuildLatest = napalmBuild nodejs_latest;
in
{
  wrangler2 =
    let
      src = fetchFromGitHub {
        owner = "cloudflare";
        repo = "wrangler2";
        rev = "wrangler@2.0.7";
        hash = "sha256-+kuAmmLe3JWhWw0V4MoZjbNoPs5JBUHpqi5sRQa50ws=";
      };
    in
    napalmBuildLatest src {
      buildInputs = [ esbuild ];
    };
}
