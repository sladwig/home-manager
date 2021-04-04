{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    targets.genericLinux = {
      enable = true;
      extraXdgDataDirs = [ "/foo" ];
    };

    nmt.script = ''
      assertFileExists home-path/etc/profile.d/hm-session-vars.sh

      assertFileContains \
        home-path/etc/profile.d/hm-session-vars.sh \
        'export XDG_DATA_DIRS="''${NIX_STATE_DIR:-/nix/var/nix}/profiles/default/share:/home/hm-user/.nix-profile/share:/foo''${XDG_DATA_DIRS:+:}$XDG_DATA_DIRS"'
      assertFileContains \
        home-path/etc/profile.d/hm-session-vars.sh \
        '. "${pkgs.nix}/etc/profile.d/nix.sh"'

      assertFileContains \
        home-path/etc/profile.d/hm-session-vars.sh \
        'export TERMINFO_DIRS="/home/hm-user/.nix-profile/share/terminfo:$TERMINFO_DIRS''${TERMINFO_DIRS:+:}/etc/terminfo:/lib/terminfo:/usr/share/terminfo"'
      assertFileContains \
        home-path/etc/profile.d/hm-session-vars.sh \
        'export TERM="$TERM"'
    '';
  };
}
