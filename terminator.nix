{pkgs}:

pkgs.writeText "terminator.conf" (
  ''
[global_config]
  title_font = Inconsolata 10
  title_use_system_font = False
[keybindings]
[layouts]
  [[default]]
    [[[child1]]]
      parent = window0
      type = Terminal
    [[[window0]]]
      parent = ""
      type = Window
[plugins]
[profiles]
  [[default]]
    background_color = "#002b36"
    cursor_color = "#aaaaaa"
    cursor_shape = ibeam
    font = Inconsolata 10
    foreground_color = "#839496"
    palette = "#073642:#dc322f:#859900:#b58900:#268bd2:#d33682:#2aa198:#eee8d5:#002b36:#cb4b16:#586e75:#657b83:#839496:#6c71c4:#93a1a1:#fdf6e3"
    use_system_font = False
  ''
)
