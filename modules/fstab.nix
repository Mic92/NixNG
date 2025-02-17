# SPDX-FileCopyrightText:  2021 Richard Brežák and NixNG contributors
#
# SPDX-License-Identifier: MPL-2.0
#
#   This Source Code Form is subject to the terms of the Mozilla Public
#   License, v. 2.0. If a copy of the MPL was not distributed with this
#   file, You can obtain one at http://mozilla.org/MPL/2.0/.

{ pkgs, lib, config, nglib, ... }:
with lib;
let
  cfg = config.fstab;

  supportedFileSystems = flip genAttrs (const false) cfg.supportedFileSystems;
  missingFileSystems = filter
    (x: supportedFileSystems.${x} or true)
    (mapAttrsToList (_: x: x.type) cfg.entries);

  entryOption.options = {
    device = mkOption {
      type = types.str;
      description = ''
        The device to mount.
      '';
    };

    type = mkOption {
      type = types.str;
      description = ''
        Type of the filesystem to be mounted.
      '';
    };

    options = mkOption {
      type = with types;
        listOf str;
      description = ''
        Options for mounting the filesystem.
      '';
      default = [];
    };

    dump = mkOption {
      type = types.bool;
      description = ''
        Used by dump(8) to determined which filesystems need to be dumped.
      '';
      default = false;
    };

    fsck = mkOption {
      type = types.int;
      description = ''
        Used by fsck(8) to determine the order in which filesystems need to be checked. The root filesystem
        should have value 1, all the rest should have value 2. If the value is 0, fsck is disabled for that
        filesystem.
      '';
      default = 0;
    };
  };
in
{
  options.fstab = {
    supportedFileSystems = mkOption {
      type = with types;
        listOf str;
      description = ''
        List of filesystems that are supported by the system.
      '';
      default = [ "ext4" ];
    };
    entries = mkOption {
      type = with types;
        attrsOf (submodule entryOption);
      description = ''
        fstab entries to be mounted at boot.
      '';
      default = {};
    };
  };

  config = {
    assertions = [
      # check that every entry in fstab uses a supported filesystem type
      {
        assertion = missingFileSystems == [];
        message = "Unsupported filesystems ${concatStringsSep "," missingFileSystems} in `fstab.entries`";
      }
      # check that the value for the fsck field is one of [ 0, 1, 2 ]
      {
        assertion =
          foldl (acc: a: acc && (a == 0 || a == 1 || a == 2)) true (mapAttrsToList (_: v: v.fsck) cfg.entries);
        message = "Invalid fsck field value in `fstab.entries`";
      }
    ];
  };
}
