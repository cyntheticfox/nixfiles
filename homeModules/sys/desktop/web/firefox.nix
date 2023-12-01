{ config, lib, pkgs, ... }:

let
  cfg = config.sys.desktop.web.firefox;
in
{
  options.sys.desktop.web.firefox = {
    enable = lib.mkEnableOption "Mozilla Firefox";
    package = lib.mkPackageOption pkgs "firefox" { };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."tridactyl/tridactylrc".text = ''
      " General Settings
      set update.lastchecktime 1652120990699
      set update.lastnaggedversion 1.22.1
      set update.nag true
      set update.nagwait 7
      set update.checkintervalsecs 86400
      set configversion 2.0
      set theme dark
      set completions.Bmark.autoselect false
      set completions.Goto.autoselect true
      set completions.Tab.autoselect true
      set completions.TabAll.autoselect true
      set completions.Rss.autoselect true
      set completions.Sessions.autoselect true
      set modeindicatorshowkeys true
      set incsearch true
      set Ss viewconfig
      set allowautofocus false

      " Search Engines
      set searchengine startpage
      set searchurls.startpage https://www.startpage.com/do/dsearch?query=%s
      set searchurls.duckduckgo https://duckduckgo.com/?q=

      set searchurls.google https://www.google.com/search?q=
      set searchurls.bing https://www.bing.com/search?q=
      set searchurls.yahoo https://search.yahoo.com/search?p=

      set searchurls.github https://github.com/search?utf8=✓&q=
      set searchurls.mdn https://developer.mozilla.org/en-US/search?q=

      set searchurls.nixpkgs https://search.nixos.org/packages?channel=22.05&from=0&size=50&sort=relevance&type=packages&query=

      set searchurls.wikipedia https://en.wikipedia.org/wiki/Special:Search/
      set searchurls.scholar https://scholar.google.com/scholar?q=

      set searchurls.osm https://www.openstreetmap.org/search?query=
      set searchurls.gmaps https://www.google.com/maps/search/

      set searchurls.twitter https://twitter.com/search?q=
      set searchurls.youtube https://www.youtube.com/results?search_query=

      set searchurls.amazon https://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords=

      set searchurls.arch_wiki https://wiki.archlinux.org/index.php?search=
      set searchurls.nixos_wiki https://nixos.wiki/index.php?search=

      set searchurls.searx https://searx.me/?category_general=on&q=
      set searchurls.cnrtl http://www.cnrtl.fr/lexicographie/
      set searchurls.qwant https://www.qwant.com/?q=

      " Default bindings
      bind $ scrollto 100 x
      bind . repeat
      bind : fillcmdline_notrail
      bind ;# hint -#
      bind ;; hint -; *
      bind ;A hint -A
      bind ;I hint -I
      bind ;K hint -K
      bind ;M composite hint -Jpipe img src | tabopen images.google.com/searchbyimage?image_url=
      bind ;O hint -W fillcmdline_notrail open
      bind ;P hint -P
      bind ;S hint -S
      bind ;T hint -W fillcmdline_notrail tabopen
      bind ;V hint -V
      bind ;W hint -W fillcmdline_notrail winopen
      bind ;X hint -F e => { const pos = tri.dom.getAbsoluteCentre(e); tri.excmds.exclaim_quiet("xdotool mousemove --sync " + window.devicePixelRatio * pos.x + " " + window.devicePixelRatio * pos.y + "; xdotool keydown ctrl+shift; xdotool click 1; xdotool keyup ctrl+shift")}
      bind ;Y hint -cF img i => tri.excmds.yankimage(tri.urlutils.getAbsoluteURL(i.src))
      bind ;a hint -a
      bind ;b hint -b
      bind ;g# hint -q#
      bind ;g; hint -q;
      bind ;gA hint -qA
      bind ;gF hint -qb
      bind ;gI hint -qI
      bind ;gP hint -qP
      bind ;gS hint -qS
      bind ;ga hint -qa
      bind ;gb hint -qb
      bind ;gf hint -q
      bind ;gi hint -qi
      bind ;gk hint -qk
      bind ;gp hint -qp
      bind ;gr hint -qr
      bind ;gs hint -qs
      bind ;gv hint -qW mpvsafe
      bind ;gw hint -qw
      bind ;gy hint -qy
      bind ;h hint -h
      bind ;i hint -i
      bind ;k hint -k
      bind ;m composite hint -Jpipe img src | open images.google.com/searchbyimage?image_url=
      bind ;o hint
      bind ;p hint -p
      bind ;r hint -r
      bind ;s hint -s
      bind ;t hint -W tabopen
      bind ;v hint -W mpvsafe
      bind ;w hint -w
      bind ;x hint -F e => { const pos = tri.dom.getAbsoluteCentre(e); tri.excmds.exclaim_quiet("xdotool mousemove --sync " + window.devicePixelRatio * pos.x + " " + window.devicePixelRatio * pos.y + "; xdotool click 1")}
      bind ;y hint -y
      bind ;z hint -z
      bind << tabmove -1
      bind <A-m> mute toggle
      bind <A-p> pin
      bind <AC-Escape> mode ignore
      bind <AC-`> mode ignore
      bind <C-[> composite mode normal ; hidecmdline
      bind <C-a> urlincrement 1
      bind <C-b> scrollpage -1
      bind <C-d> scrollpage 0.5
      bind <C-e> scrollline 10
      bind <C-f> scrollpage 1
      bind <C-i> jumpnext
      bind <C-o> jumpprev
      bind <C-u> scrollpage -0.5
      bind <C-v> nmode ignore 1 mode normal
      bind <C-x> urlincrement -1
      bind <C-y> scrollline -10
      bind <Escape> composite mode normal ; hidecmdline
      bind <F1> help
      bind <S-Escape> mode ignore
      bind <S-Insert> mode ignore
      bind >> tabmove +1
      bind D composite tabprev; tabclose #
      bind F hint -b
      bind G scrollto 100
      bind H back
      bind J tabprev
      bind K tabnext
      bind L forward
      bind P clipboard tabopen
      bind R reloadhard
      bind U undo window
      bind [[ followpage prev
      bind [c urlincrement -1
      bind ]] followpage next
      bind ]c urlincrement 1
      bind ^ scrollto 0 x
      bind d tabclose
      bind f hint
      bind g! jumble
      bind g$ tablast
      bind g0 tabfirst
      bind g; changelistjump -1
      bind g? rot13
      bind gF hint -qb
      bind gH home true
      bind gT tabprev
      bind g^ tabfirst
      bind ga tabaudio
      bind gf viewsource
      bind gg scrollto 0
      bind gh home
      bind gi focusinput -l
      bind gr reader
      bind gt tabnext_gt
      bind gu urlparent
      bind gx$ tabclosealltoright
      bind gx0 tabclosealltoleft
      bind h scrollpx -50
      bind j scrollline 10
      bind k scrollline -10
      bind l scrollpx 50
      bind p clipboard open
      bind r reload
      bind u undo
      bind yc clipboard yankcanon
      bind ym clipboard yankmd
      bind yo clipboard yankorg
      bind ys clipboard yankshort
      bind yt clipboard yanktitle
      bind yy clipboard yank
      bind zI zoom 3
      bind zM zoom 0.5 true
      bind zO zoom 0.3
      bind zR zoom -0.5 true
      bind zi zoom 0.1 true
      bind zm zoom 0.5 true
      bind zo zoom -0.1 true
      bind zr zoom -0.5 true
      bind zz zoom 1

      " Remove Non-Qutebrowser-style keybinds
      unbind A
      unbind Pp
      unbind S
      unbind W
      unbind ZZ
      unbind a
      unbind pp
      unbind s
      unbind t
      unbind w
      unbind x

      " Add Qutebrowser-styel keybinds
      bind ,<Space> nohlsearch
      bind / fillcmdline find
      bind <C-h> home
      bind <C-q> qall
      bind <C-s> stop
      bind ? fillcmdline find -?
      bind B fillcmdline bmarks -t
      bind M bmark
      bind N findnext -? 1
      bind O fillcmdline tabopen
      bind T fillcmdline tab
      bind b fillcmdline bmarks
      bind co tabonly
      bind gC tabduplicate
      bind gD tabdetach
      bind gJ tabmove -1
      bind gK tabmove +1
      bind gO current_url tabopen
      bind gU composite tabduplicate; urlparent
      bind gd fillcmdline saveas
      bind gm tabmove
      bind go current_url open
      bind n findnext 1
      bind o fillcmdline open
      bind sf fillcmdline mkt
      bind sk fillcmdline bind
      bind ss fillcmdline set
      bind v mode visual
      bind wi viewsource
      bind wo fillcmdline winopen
      bind wp clipboard winopen
      bind xO current_url tabopen -b
      bind xo fillcmdline tabopen -b
      bind yY clipboard yank
      bind yp clipboard yank

      " Aliases
      command alias command
      alias save mktridactylrc
      alias ! exclaim
      alias !js fillcmdline_tmp 3000 !js is deprecated. Please use js instead
      alias !jsb fillcmdline_tmp 3000 !jsb is deprecated. Please use jsb instead
      alias !s exclaim_quiet
      alias au autocmd
      alias aucon autocontain
      alias audel autocmddelete
      alias audelete autocmddelete
      alias authors credits
      alias b tab
      alias bN tabprev
      alias bd tabclose
      alias bdelete tabclose
      alias bfirst tabfirst
      alias blacklistremove autocmddelete DocStart
      alias blast tablast
      alias bn tabnext_gt
      alias bnext tabnext_gt
      alias bp tabprev
      alias bprev tabprev
      alias buffer tab
      alias bufferall taball
      alias clsh clearsearchhighlight
      alias colors colourscheme
      alias colorscheme colourscheme
      alias colours colourscheme
      alias containerremove containerdelete
      alias current_url composite get_current_url | fillcmdline_notrail
      alias drawingstop no_mouse_mode
      alias exto extoptions
      alias extp extpreferences
      alias extpreferences extoptions
      alias get_current_url js document.location.href
      alias h help
      alias installnative nativeinstall
      alias man help
      alias mkt mktridactylrc
      alias mkt! mktridactylrc -f
      alias mktridactylrc! mktridactylrc -f
      alias mpvsafe js -p tri.excmds.shellescape(JS_ARG).then(url => tri.excmds.exclaim_quiet('mpv --no-terminal ' + url))
      alias nativeupdate updatenative
      alias noh clearsearchhighlight
      alias nohlsearch clearsearchhighlight
      alias o open
      alias openwith hint -W
      alias prefremove removepref
      alias prefset setpref
      alias q tabclose
      alias qa qall
      alias quit tabclose
      alias reibadailty jumble
      alias sanitize sanitise
      alias saveas! saveas --cleanup --overwrite
      alias stop js window.stop()
      alias t tabopen
      alias tN tabprev
      alias tabclosealltoleft tabcloseallto left
      alias tabclosealltoright tabcloseallto right
      alias tabfirst tab 1
      alias tablast tab 0
      alias tabm tabmove
      alias tabnew tabopen
      alias tabo tabonly
      alias tfirst tabfirst
      alias tlast tablast
      alias tn tabnext_gt
      alias tnext tabnext_gt
      alias tp tabprev
      alias tprev tabprev
      alias tutorial tutor
      alias unmute mute unmute
      alias w winopen
      alias zo zoom

      " For syntax highlighting see https://github.com/tridactyl/vim-tridactyl
      " vim: set filetype=tridactyl
    '';

    programs.firefox = {
      inherit (cfg) enable;

      package = cfg.package.override {
        cfg.nativeMessagingHosts.packages = with pkgs; [ tridactyl-native ];
      };
    };
  };
}
