{pkgs}:

pkgs.writeText "kitty.conf" (
  ''
# credit to this wonderful repo: https://github.com/dexpota/kitty-themes/blob/master/themes/Solarized_Dark.conf

background #001e26
foreground #708183
cuhttps://github.com/dexpota/kitty-themes/blob/master/themes/Solarized_Dark.confrsor #708183
selection_background #002731
color0 #002731
color8 #001e26
color1 #d01b24
color9 #bd3612
color2 #728905
color10 #465a61
color3 #a57705
color11 #52676f
color4 #2075c7
color12 #708183
color5 #c61b6e
color13 #5856b9
color6 #259185
color14 #81908f
color7 #e9e2cb
color15 #fcf4dc
selection_foreground #001e26
  ''
)