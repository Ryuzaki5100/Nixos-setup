# Scripts ported from Frost-Phoenix/nixos-config (scripts/scripts.nix): every
# .sh in ./scripts is packaged as a writeScriptBin of the same (sans .sh) name.
{ pkgs, ... }:
let
  scriptDir = ./scripts;
  scriptEntries = builtins.readDir scriptDir;

  regularFiles = builtins.filter (name: scriptEntries.${name} == "regular") (
    builtins.attrNames scriptEntries
  );

  shellScripts = builtins.filter (
    name: builtins.match ".*\\.sh$" name != null
  ) regularFiles;

  mkScript = name: {
    name = name;
    value = pkgs.writeScriptBin (builtins.replaceStrings [ ".sh" ] [ "" ] name) (
      builtins.readFile (scriptDir + "/${name}")
    );
  };

  scriptsSet = builtins.listToAttrs (map mkScript shellScripts);
in
{
  home.packages = builtins.attrValues scriptsSet;
}
