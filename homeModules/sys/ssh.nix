{ config, lib, ... }:

with lib;

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
    address = mkOption {
      type = types.str;
      default = "localhost";
      example = "example.org";
      description = "The address where to bind the port.";
    };

    port = mkOption {
      type = types.nullOr types.port;
      default = null;
      example = 8080;
      description = "Specifies port number to bind on bind address.";
    };
  };

  dynamicForwardModule = types.submodule {
    options = bindOptions;
  };

  forwardModule = types.submodule {
    options = {
      bind = bindOptions;

      host = {
        address = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "example.org";
          description = "The address where to forward the traffic to.";
        };

        port = mkOption {
          type = types.nullOr types.port;
          default = null;
          example = 80;
          description = "Specifies port number to forward the traffic to.";
        };
      };
    };
  };

  matchBlockModule = types.submodule ({ dagName, ... }: {
    options = {
      host = mkOption {
        type = types.str;
        example = "*.example.org";
        description = ''
          The host pattern used by this conditional block.
        '';
      };

      port = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = "Specifies port number to connect on remote host.";
      };

      forwardAgent = mkOption {
        default = null;
        type = types.nullOr types.bool;
        description = ''
          Whether the connection to the authentication agent (if any)
          will be forwarded to the remote machine.
        '';
      };

      forwardX11 = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Specifies whether X11 connections will be automatically redirected
          over the secure channel and <envar>DISPLAY</envar> set.
        '';
      };

      forwardX11Trusted = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Specifies whether remote X11 clients will have full access to the
          original X11 display.
        '';
      };

      identitiesOnly = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Specifies that ssh should only use the authentication
          identity explicitly configured in the
          <filename>~/.ssh/config</filename> files or passed on the
          ssh command-line, even if <command>ssh-agent</command>
          offers more identities.
        '';
      };

      identityFile = mkOption {
        type = with types; either (listOf str) (nullOr str);
        default = [ ];
        apply = p:
          if p == null then [ ]
          else if isString p then [ p ]
          else p;
        description = ''
          Specifies files from which the user identity is read.
          Identities will be tried in the given order.
        '';
      };

      user = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Specifies the user to log in as.";
      };

      hostname = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Specifies the real host name to log into.";
      };

      serverAliveInterval = mkOption {
        type = types.int;
        default = 0;
        description =
          "Set timeout in seconds after which response will be requested.";
      };

      serverAliveCountMax = mkOption {
        type = types.ints.positive;
        default = 3;
        description = ''
          Sets the number of server alive messages which may be sent
          without SSH receiving any messages back from the server.
        '';
      };

      sendEnv = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Environment variables to send from the local host to the
          server.
        '';
      };

      compression = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = ''
          Specifies whether to use compression. Omitted from the host
          block when <literal>null</literal>.
        '';
      };

      checkHostIP = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Check the host IP address in the
          <filename>known_hosts</filename> file.
        '';
      };

      proxyCommand = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The command to use to connect to the server.";
      };

      proxyJump = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The proxy host to use to connect to the server.";
      };

      certificateFile = mkOption {
        type = with types; either (listOf str) (nullOr str);
        default = [ ];
        apply = p:
          if p == null then [ ]
          else if isString p then [ p ]
          else p;
        description = ''
          Specifies files from which the user certificate is read.
        '';
      };

      addressFamily = mkOption {
        default = null;
        type = types.nullOr (types.enum [ "any" "inet" "inet6" ]);
        description = ''
          Specifies which address family to use when connecting.
        '';
      };

      localForwards = mkOption {
        type = types.listOf forwardModule;
        default = [ ];
        example = literalExpression ''
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

      remoteForwards = mkOption {
        type = types.listOf forwardModule;
        default = [ ];
        example = literalExpression ''
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

      dynamicForwards = mkOption {
        type = types.listOf dynamicForwardModule;
        default = [ ];
        example = literalExpression ''
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

      extraOptions = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Extra configuration options for the host.";
      };
    };

    config.host = mkDefault dagName;
  });
  # End of home-manager part
in
{
  options.sys.ssh = {
    enable = mkEnableOption "Manage SSH configuration";

    extraMatchBlocks = mkOption {
      type = hm.types.listOrDagOf matchBlockModule;
      default = { };
      description = ''
        Additional per-host settings. If order of rules matter, then
        use DAG functions to express dependencies.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;

      compression = true;
      forwardAgent = false;
      hashKnownHosts = true;
      extraOptionOverrides.IdentityFile = "~/.ssh/id_ed25519";

      includes = [ "config.d/*" ];

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
      } // cfg.extraMatchBlocks;
    };
  };
}
