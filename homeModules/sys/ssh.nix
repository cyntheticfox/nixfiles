{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sys.ssh;

  # From [home-manager](https://github.com/nix-community/home-manager):
  #
  # MIT License
  #
  # Copyright (c) 2017-2022 Home Manager contributors
  #
  # Permission is hereby granted, free of charge, to any person obtaining a copy
  # of this software and associated documentation files (the "Software"), to deal
  # in the Software without restriction, including without limitation the rights
  # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  # copies of the Software, and to permit persons to whom the Software is
  # furnished to do so, subject to the following conditions:
  #
  # The above copyright notice and this permission notice shall be included in all
  # copies or substantial portions of the Software.
  #
  # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  # SOFTWARE.
  bindOptions = {
    address = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      example = "example.org";

      description = ''
        The address where to bind the port.
      '';
    };

    port = lib.mkOption {
      type = with lib.types; nullOr port;
      default = null;
      example = 8080;

      description = ''
        Specifies port number to bind on bind address.
      '';
    };
  };

  dynamicForwardModule = lib.types.submodule { options = bindOptions; };

  forwardModule = lib.types.submodule {
    options = {
      bind = bindOptions;

      host = {
        address = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          example = "example.org";
          description = ''
            The address where to forward the traffic to.
          '';
        };

        port = lib.mkOption {
          type = with lib.types; nullOr port;
          default = null;
          example = 80;

          description = ''
            Specifies port number to forward the traffic to.
          '';
        };
      };
    };
  };

  matchBlockModule = lib.types.submodule (
    { dagName, ... }:
    {
      options = {
        host = lib.mkOption {
          type = lib.types.str;
          example = "*.example.org";

          description = ''
            The host pattern used by this conditional block.
          '';
        };

        port = lib.mkOption {
          type = with lib.types; nullOr port;
          default = null;

          description = ''
            Specifies port number to connect on remote host.
          '';
        };

        forwardAgent = lib.mkOption {
          default = null;
          type = with lib.types; nullOr bool;

          description = ''
            Whether the connection to the authentication agent (if any)
            will be forwarded to the remote machine.
          '';
        };

        forwardX11 = lib.mkOption {
          type = lib.types.bool;
          default = false;

          description = ''
            Specifies whether X11 connections will be automatically redirected
            over the secure channel and <envar>DISPLAY</envar> set.
          '';
        };

        forwardX11Trusted = lib.mkOption {
          type = lib.types.bool;
          default = false;

          description = ''
            Specifies whether remote X11 clients will have full access to the
            original X11 display.
          '';
        };

        identitiesOnly = lib.mkOption {
          type = lib.types.bool;
          default = false;

          description = ''
            Specifies that ssh should only use the authentication
            identity explicitly configured in the
            <filename>~/.ssh/config</filename> files or passed on the
            ssh command-line, even if <command>ssh-agent</command>
            offers more identities.
          '';
        };

        identityFile = lib.mkOption {
          type = with lib.types; either (listOf str) (nullOr str);
          default = [ ];

          apply =
            p:
            if p == null then
              [ ]
            else if builtins.isString p then
              [ p ]
            else
              p;

          description = ''
            Specifies files from which the user identity is read.
            Identities will be tried in the given order.
          '';
        };

        user = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;

          description = ''
            Specifies the user to log in as.
          '';
        };

        hostname = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;

          description = ''
            Specifies the real host name to log into.
          '';
        };

        serverAliveInterval = lib.mkOption {
          type = lib.types.ints.unsigned;
          default = 0;

          description = ''
            Set timeout in seconds after which response will be requested.
          '';
        };

        serverAliveCountMax = lib.mkOption {
          type = lib.types.ints.positive;
          default = 3;

          description = ''
            Sets the number of server alive messages which may be sent
            without SSH receiving any messages back from the server.
          '';
        };

        sendEnv = lib.mkOption {
          type = with lib.types; listOf str;
          default = [ ];

          description = ''
            Environment variables to send from the local host to the
            server.
          '';
        };

        compression = lib.mkOption {
          type = with lib.types; nullOr bool;
          default = null;

          description = ''
            Specifies whether to use compression. Omitted from the host
            block when <literal>null</literal>.
          '';
        };

        checkHostIP = lib.mkOption {
          type = lib.types.bool;
          default = true;

          description = ''
            Check the host IP address in the
            <filename>known_hosts</filename> file.
          '';
        };

        proxyCommand = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;

          description = "The command to use to connect to the server.";
        };

        proxyJump = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;

          description = "The proxy host to use to connect to the server.";
        };

        certificateFile = lib.mkOption {
          type = with lib.types; either (listOf str) (nullOr str);
          default = [ ];
          apply =
            p:
            if p == null then
              [ ]
            else if builtins.isString p then
              [ p ]
            else
              p;
          description = ''
            Specifies files from which the user certificate is read.
          '';
        };

        addressFamily = lib.mkOption {
          default = null;
          type =
            with lib.types;
            nullOr (enum [
              "any"
              "inet"
              "inet6"
            ]);

          description = ''
            Specifies which address family to use when connecting.
          '';
        };

        localForwards = lib.mkOption {
          type = lib.types.listOf forwardModule;
          default = [ ];

          example = lib.literalExpression ''
            [
              {
                bind.port = 8080;
                host.address = "10.0.0.13";
                host.port = 80;
              }
            ];
          '';

          description = ''
            Specify local port forwardings. See
            <citerefentry>
              <refentrytitle>ssh_config</refentrytitle>
              <manvolnum>5</manvolnum>
            </citerefentry> for <literal>LocalForward</literal>.
          '';
        };

        remoteForwards = lib.mkOption {
          type = lib.types.listOf forwardModule;
          default = [ ];

          example = lib.literalExpression ''
            [
              {
                bind.port = 8080;
                host.address = "10.0.0.13";
                host.port = 80;
              }
            ];
          '';

          description = ''
            Specify remote port forwardings. See
            <citerefentry>
              <refentrytitle>ssh_config</refentrytitle>
              <manvolnum>5</manvolnum>
            </citerefentry> for <literal>RemoteForward</literal>.
          '';
        };

        dynamicForwards = lib.mkOption {
          type = lib.types.listOf dynamicForwardModule;
          default = [ ];

          example = lib.literalExpression ''
            [ { port = 8080; } ];
          '';

          description = ''
            Specify dynamic port forwardings. See
            <citerefentry>
              <refentrytitle>ssh_config</refentrytitle>
              <manvolnum>5</manvolnum>
            </citerefentry> for <literal>DynamicForward</literal>.
          '';
        };

        extraOptions = lib.mkOption {
          type = with lib.types; attrsOf str;
          default = { };

          description = ''
            Extra configuration options for the host.
          '';
        };
      };

      config.host = lib.mkDefault dagName;
    }
  );
in
# End of home-manager part
{
  options.sys.ssh = {
    enable = lib.mkEnableOption "Manage SSH configuration";
    package = lib.mkPackageOption pkgs "openssh" { };

    extraMatchBlocks = lib.mkOption {
      type = lib.hm.types.dagOf matchBlockModule;
      default = { };

      description = ''
        Additional per-host settings. If order of rules matter, then
        use DAG functions to express dependencies.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs.ssh = {
      enable = true;

      compression = true;
      includes = [ "config.d/*" ];

      extraOptionOverrides = {
        HashKnownHosts = "true";
        SetEnv = "TERM=xterm-256color";
      };

      matchBlocks = {
        "github github.com" = {
          hostname = "github.com";
          user = "git";
          port = 22;
          identityFile = "~/.ssh/github_id_ed25519";
        };

        "gitlab gitlab.com" = {
          hostname = "gitlab.com";
          user = "git";
          port = 22;
          identityFile = "~/.ssh/gitlab_id_ed25519";
        };

        "sourcehut git.sr.ht" = {
          hostname = "git.sr.ht";
          user = "git";
          port = 22;
          identityFile = "~/.ssh/sourcehut_id_ed25519";
        };
      } // cfg.extraMatchBlocks;
    };
  };
}
