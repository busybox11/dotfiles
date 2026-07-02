{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;

    settings = {
      background_opacity = 0.75;
      font_size = 10.5;
      repaint_delay = 5;
      cursor_trail = 1;
      disable_ligatures = "always";
      scrollback_lines = 5000;
      scrollbar_gap = 0.3;
      scrollbar_track_hover_opacity = 0.05;
      notify_on_cmd_finish = "unfocused";

      cursor = "#e8e2d5";
      cursor_text_color = "#ccc6b5";
      foreground = "#e8e2d5";
      background = "#090801";
      selection_foreground = "#353117";
      selection_background = "#cfc7a2";
      url_color = "#d6c870";

      color0 = "#35301f";
      color1 = "#ff8678";
      color2 = "#beb380";
      color3 = "#bbb488";
      color4 = "#cbb948";
      color5 = "#86be9a";
      color6 = "#84bf9f";
      color7 = "#d6cbb4";
      color8 = "#ccc6b5";
      color9 = "#ffe2de";
      color10 = "#e0dbc4";
      color11 = "#8d8450";
      color12 = "#e1d798";
      color13 = "#c8e2d2";
      color14 = "#4c916c";
      color15 = "#faf9f6";
    };

    extraConfig = ''
      font_family      family='Cascadia Code NF' variable_name=CascadiaCodeNFRoman features=+calt
      bold_font        auto
      italic_font      auto
      bold_italic_font auto
    '';
  };
}
