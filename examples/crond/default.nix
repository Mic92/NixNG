/*
  * NixNG
  * Copyright (c) 2021  GPL Magic_RB <magic_rb@redalder.org>
  *
  *  This file is free software: you may copy, redistribute and/or modify it
  *  under the terms of the GNU General Public License as published by the
  *  Free Software Foundation, either version 3 of the License, or (at your
  *  option) any later version.
  *
  *  This file is distributed in the hope that it will be useful, but
  *  WITHOUT ANY WARRANTY; without even the implied warranty of
  *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  *  General Public License for more details.
  *
  *  You should have received a copy of the GNU General Public License
  *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

nglib:
(nglib "x86_64-linux").makeSystem {
  system = "x86_64-linux";
  name = "nixng-crond";
  config = ({ pkgs, config, ... }:
    {
      config = {
        dumb-init.enable = true;
        services.crond = {
          enable = true;
          crontabs = {
            hydra = {
              environment = {
                PATH = "${pkgs.busybox}/bin";
              };
              jobs = [
                ''*/2 * * * * root echo "asd"''
              ];
            };
          };
        };
      };
    }
  );
}
