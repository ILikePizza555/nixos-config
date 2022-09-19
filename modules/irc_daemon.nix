/* All-in-once hosted IRC with TheLounge and ergo */
{config, pkgs, ...}:

{
  services = {
    thelounge = {
      enable = true;
    };
  };
}
