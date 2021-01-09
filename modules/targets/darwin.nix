{ config, lib, pkgs, ... }:

let
  cfg = config.darwin;
in

{
  options.darwin.installApps = lib.mkOption {
    default = false;
    example = true;
    description = ''
      Install packages as Apps into ~/Applications/Home Manager Apps/

      Note: Disabled by default due to conflicting behavior with nix-darwin. See https://github.com/nix-community/home-manager/issues/1341#issuecomment-687286866
      '';
    type = lib.types.bool;
  };

  config = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && cfg.installApps) {
    home.activation.darwinApps = let
      apps = pkgs.buildEnv {
        name = "home-manager-applications";
        paths = config.home.packages;
        pathsToLink = "/Applications";
      };
    in lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Install MacOS applications to the user environment.
      HM_APPS="$HOME/Applications/Home Manager Apps"

      # Reset current state
      [ -e "$HM_APPS" ] && $DRY_RUN_CMD rm -r "$HM_APPS"
      $DRY_RUN_CMD mkdir -p "$HM_APPS"

      # .app dirs need to be actual directories for Finder to detect them as Apps.
      # The files inside them can be symlinks though.
      $DRY_RUN_CMD cp --recursive --symbolic-link --no-preserve=mode -H ${apps}/Applications/* "$HM_APPS"
      # Modes need to be stripped because otherwise the dirs wouldn't have +w,
      # preventing us from deleting them again
      # In the env of Apps we build, the .apps are symlinks. We pass all of them as
      # arguments to cp and make it dereference those using -H
      '';
  };
}
