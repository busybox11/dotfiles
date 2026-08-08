{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;

    settings = {
      include = "colors.conf";

      background_opacity = 0.75;
      font_size = 10.5;
      repaint_delay = 5;
      cursor_trail = 1;
      disable_ligatures = "always";
      scrollback_lines = 5000;
      scrollbar_gap = 0.3;
      scrollbar_track_hover_opacity = 0.05;
      notify_on_cmd_finish = "unfocused";
    };

    extraConfig = ''
      font_family      family='Cascadia Code NF' variable_name=CascadiaCodeNFRoman features=+calt
      bold_font        auto
      italic_font      auto
      bold_italic_font auto
    '';
  };
}
