# SPDX-FileCopyrightText:  2021 Richard Brežák and NixNG contributors
#
# SPDX-License-Identifier: MPL-2.0
#
#   This Source Code Form is subject to the terms of the Mozilla Public
#   License, v. 2.0. If a copy of the MPL was not distributed with this
#   file, You can obtain one at http://mozilla.org/MPL/2.0/.

{ pkgs, lib, nglib, config, ... }:
with lib;
let
  inherit (pkgs)
    runCommandNoCC
    writeReferencesToFile;
in
{
  options.system.build = {
    bundle = mkOption {
      description = ''
        The full system bundle, including all dependencies.
      '';
      type = types.path;
    };
  };

  config.system.build.bundle =
    runCommandNoCC (config.system.name + "-bundle")
      { }
      ''
        set -o pipefail
        mkdir -p $out
        xargs tar c < ${writeReferencesToFile config.system.build.toplevel} | tar -xC $out/
      '';
}
