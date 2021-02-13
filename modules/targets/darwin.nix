{ config, lib, pkgs, ... }:

let cfg = config.darwin;

in {
  options.darwin = {
    installApps = lib.mkOption {
      default = false;
      example = true;
      description = ''
        Install packages as Apps into ~/Applications/Home Manager Apps/

        Note: Disabled by default due to conflicting behavior with nix-darwin. See https://github.com/nix-community/home-manager/issues/1341#issuecomment-687286866
      '';
      type = lib.types.bool;
    };
    fullCopies = lib.mkOption {
      default = false;
      example = true;
      description = ''
        Make full copies of the .app dirs instead of symlinking them. This is the only known way of making them show up in vanilla Finder.
      '';
      type = lib.types.bool;
    };
  };

  config = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && cfg.installApps)
    if cfg.fullCopies then {
      home.activation.darwinApps = let
        apps = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages;
          pathsToLink = "/Applications";
        };
      in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Install MacOS applications to the user environment.
        HM_APPS="$HOME/Applications/Home Manager Apps"

        # Reset current state
        [ -e "$HM_APPS" ] && $DRY_RUN_CMD rm -r "$HM_APPS"
        $DRY_RUN_CMD mkdir -p "$HM_APPS"

        # .app dirs need to be actual directories for Finder to detect them as Apps.
        # In the env of Apps we build, the .apps are symlinks. We pass all of them as
        # arguments to cp and make it dereference those using -H
        $DRY_RUN_CMD cp -a -H ${apps}/Applications/* "$HM_APPS"
        $DRY_RUN_CMD chmod +w -R "$HM_APPS"
      '';
  } else {
    # Install MacOS applications to the user environment.
    home.file."Applications/Home Manager Apps".source = "${apps}/Applications";
  };
}
