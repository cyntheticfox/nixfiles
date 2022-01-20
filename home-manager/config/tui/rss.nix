{ config, pkgs, ... }: {
  programs.newsboat = {
    enable = true;
    autoReload = true;
    urls = [
      {
        url = "https://phoronix.com/rss.php";
        tags = [ "news" "linux" ];
        title = "Phoronix Linux News";
      }
      {
        url = "https://feeds.arstechnica.com/arstechnica/technology-lab";
        tags = [ "news" "tech" "arstechnica" ];
        title = "arstechnica - Technology Lab";
      }
      {
        url = "https://feeds.arstechnica.com/arstechnica/gadgets";
        tags = [ "news" "products" "arstechnica" ];
        title = "arstechnica - Gear & Gadgets";
      }
      {
        url = "https://feeds.arstechnica.com/arstechnica/gaming";
        tags = [ "news" "gaming" "arstechnica" ];
        title = "arstechnica - Opposable Thumbs";
      }
      {
        url = "https://www.darkreading.com/rss.xml";
        tags = [ "news" "security" ];
        title = "Dark Reading - Protect the Business";
      }
      {
        url = "https://krebsonsecurity.com/feed/";
        tags = [ "news" "security" ];
        title = "Krebs on Security - In-depth Security News and Investigation";
      }
      {
        url = "https://christine.website/blog.rss";
        tags = [ "blogs" "people" "NixOS" ];
        title = "Xe's Blog";
      }
      {
        url = "https://www.copetti.org/index.xml";
        tags = [ "blogs" "people" "gaming" ];
        title = "Rodrigo's Stuff";
      }
      {
        url = "https://fasterthanli.me/index.xml";
        tags = [ "blogs" "people" "rust" ];
        title = "FasterThanLime Blog";
      }
      {
        url = "https://this-week-in-rust.org/rss.xml";
        tags = [ "blogs" "projects" "rust" ];
        title = "This Week in Rust";
      }
      {
        url = "http://feeds.feedburner.com/PythonInsider";
        tags = [ "blogs" "projects" "python" ];
        title = "Python Insider";
      }
      {
        url = "https://matrix.org/blog/feed";
        tags = [ "blogs" "companies" "matrix" ];
        title = "Matrix.org Blog";
      }
      {
        url = "https://www.pine64.org/feed/";
        tags = [ "blogs" "companies" "pine64" ];
        title = "PINE64 Blog";
      }
      {
        url = "https://blog.cloudflare.com/rss/";
        tags = [ "blogs" "companies" "cloudflare" ];
        title = "The Cloudflare Blog";
      }
      {
        url = "https://www.linode.com/blog/feed/";
        tags = [ "blogs" "companies" "linode" ];
        title = "Linode Blog";
      }
    ];

    extraConfig = ''
      # Start with a refresh
      refresh-on-startup yes

      # Change keybindings
      unbind-key j
      unbind-key J
      unbind-key k
      unbind-key K

      bind-key j next
      bind-key k prev
      bind-key J next-feed
      bind-key K prev-feed
      bind-key d prev-dialog

      # Set the colors to be less jarring
      color background          white   default
      color listnormal          white   default
      color listfocus           white   blue     bold
      color listnormal_unread   red     default
      color listfocus_unread    red     blue     bold
      color title               white   color240 bold
      color info                white   color240 bold
      color hint-key            yellow  color240 bold
      color hint-keys-delimiter yellow  black
      color hint-separator      yellow  color240 bold
      color hint-description    yellow  color240
      color article             white   default
      color end-of-text-marker  white   default  invis

      # Set up confirmations
      confirm-exit yes

      # Set up notifications
      notify-program ${config.xdg.configHome}/newsboat/notify.sh
      notify-format "%d new articles (%n unread articles, %f unread feeds)"
    '';
  };

  xdg.configFile."newsboat/notify.sh" = {
    executable = true;
    text = ''
      #!${pkgs.bashInteractive}/bin/bash
      ${pkgs.libnotify}/bin/notify-send --icon=network-wireless -- 'NewsBoat RSS' "$1"
    '';
  };
}
