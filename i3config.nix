{ config, pkgs, parameters }:

with pkgs;

let
  i3StatusBarConfig = ''
    general {
      colors = true
      interval = 1
      output_format = i3bar
      color_good = "#2267a5"
      color_degraded = "#8c7f22"
      color_bad = "#be2422"
    }

    order += "disk /"
  '' + (
    if (parameters.machine == "hydra") then ''
      order += "ethernet enp11s0"
    ''
    else ''
      order += "wireless wlp4s0"
      order += "path_exists VPN"
      order += "battery 0"
    ''
  ) + ''
    order += "cpu_usage"
    order += "volume master"
    order += "tztime local"

    ethernet enp11s0 {
      format_up = " LAN: %ip %speed "
      format_down = " LAN: (/) "
    }

    tztime local {
      format = " Date: %m/%d/%y  Time: %H:%M "
    }

    cpu_usage {
      format = " CPU: %usage "
    }

    disk "/" {
      format = " Disk: %free "
    }

    volume master {
      format = "♪: %volume"
      format_muted = "♪: muted"
      device = "default"
      mixer = "Master"
      mixer_idx = 0
    }
  '' + (
    if (parameters.machine == "janusX1") then ''
      wireless wlp4s0 {
        format_up = " WiFi: %ip %quality %essid %bitrate "
        format_down = " WiFi: (/) "
      }

      battery 0 {
        format = " Power: %status %percentage %remaining left "
        path = "/sys/class/power_supply/BAT0/uevent"
        low_threshold = 20
      }

      path_exists VPN {
        # path exists when a VPN tunnel launched by nmcli/nm-applet is active
        path = "/proc/sys/net/ipv4/conf/tun0"
      }
    ''
    else
    ""
  );
in

writeText "i3-config" (
  ''
    set $mod Mod4

    # Font for window title bars
    font pango:Fira Mono 8

    # Use Mouse+$mod to drag floating windows to their wanted position
    floating_modifier $mod

    # start a terminal
    bindsym $mod+Return exec ${i3}/bin/i3-sensible-terminal

    # kill focused window
    bindsym $mod+Shift+q kill

    # start dmenu (a program launcher)
    bindsym $mod+d exec ${dmenu}/bin/dmenu_run -i

    # There also is the (new) i3-dmenu-desktop which only displays applications
    # shipping a .desktop file. It is a wrapper around dmenu, so you need that
    # installed.
    # bindsym $mod+d exec --no-startup-id ${i3}/bin/i3-dmenu-desktop

    # change focus
    bindsym $mod+h focus left
    bindsym $mod+j focus down
    bindsym $mod+k focus up
    bindsym $mod+l focus right

    # alternatively, you can use the cursor keys:
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

    # move focused window
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right

    # move focused workspace
    bindsym $mod+Shift+h move workspace to output left
    bindsym $mod+Shift+j move workspace to output down
    bindsym $mod+Shift+k move workspace to output up
    bindsym $mod+Shift+l move workspace to output right

    # toggle between horizontal/vertical splitting
    bindsym $mod+v split toggle

    # enter fullscreen mode for the focused container
    bindsym $mod+f fullscreen toggle

    # change container layout (stacked, tabbed, toggle split)
    bindsym $mod+s layout stacking
    bindsym $mod+w layout tabbed
    bindsym $mod+e layout toggle split

    # toggle tiling / floating
    bindsym $mod+Shift+space floating toggle

    # change focus between tiling / floating windows
    bindsym $mod+space focus mode_toggle

    # focus the parent container
    bindsym $mod+a focus parent

    # focus the child container
    #bindsym $mod+d focus child

    # switch to workspace
    bindsym $mod+1 workspace 1
    bindsym $mod+2 workspace 2
    bindsym $mod+3 workspace 3
    bindsym $mod+4 workspace 4
    bindsym $mod+5 workspace 5
    bindsym $mod+6 workspace 6
    bindsym $mod+7 workspace 7
    bindsym $mod+8 workspace 8
    bindsym $mod+9 workspace 9
    bindsym $mod+0 workspace 10

    # move focused container to workspace
    bindsym $mod+Shift+1 move container to workspace 1
    bindsym $mod+Shift+2 move container to workspace 2
    bindsym $mod+Shift+3 move container to workspace 3
    bindsym $mod+Shift+4 move container to workspace 4
    bindsym $mod+Shift+5 move container to workspace 5
    bindsym $mod+Shift+6 move container to workspace 6
    bindsym $mod+Shift+7 move container to workspace 7
    bindsym $mod+Shift+8 move container to workspace 8
    bindsym $mod+Shift+9 move container to workspace 9
    bindsym $mod+Shift+0 move container to workspace 10
    '' + (
      if (parameters.machine == "janusX1") then ''
        # Pulse Audio controls
        # run pactl list sinks
        bindsym XF86AudioRaiseVolume exec --no-startup-id ${config.hardware.pulseaudio.package}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5% #increase sound volume
        bindsym XF86AudioLowerVolume exec --no-startup-id ${config.hardware.pulseaudio.package}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5% #decrease sound volume
        bindsym XF86AudioMute exec --no-startup-id ${config.hardware.pulseaudio.package}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle # mute sound

        # Sreen brightness controls
        bindsym XF86MonBrightnessUp exec ${light}/bin/light -s sysfs/backlight/intel_backlight -A 5 # increase screen brightness 5%
        bindsym XF86MonBrightnessDown exec ${light}/bin/light -s sysfs/backlight/intel_backlight -U 5 # decrease screen brightness by 5%

        # Start nm-applet
        exec --no-startup-id nm-applet --sm-disable
      ''
      else ''
        # Pulse Audio controls
        # run pactl list sinks
        bindcode 123 exec --no-startup-id ${config.hardware.pulseaudio.package}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5% #increase sound volume
        bindcode 122 exec --no-startup-id ${config.hardware.pulseaudio.package}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5% #decrease sound volume
        bindcode 121 exec --no-startup-id ${config.hardware.pulseaudio.package}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle # mute sound
      ''
    ) + ''

    # multimedia keys
    #bindsym XF86AudioPlay  exec "mpc toggle"
    #bindsym XF86AudioStop  exec "mpc stop"
    #bindsym XF86AudioNext  exec "mpc next"
    #bindsym XF86AudioPrev  exec "mpc prev"
    #bindsym XF86AudioPause exec "mpc pause"

    # reload the configuration file
    bindsym $mod+Shift+c reload
    # restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
    bindsym $mod+Shift+r restart
    # exit i3 (logs you out of your X session)
    bindsym $mod+Shift+e exec "${i3}/bin/i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'"

    # resize window (you can also use the mouse for that)
    mode "resize" {
            # These bindings trigger as soon as you enter the resize mode

            # Pressing left will shrink the window’s width.
            # Pressing right will grow the window’s width.
            # Pressing up will shrink the window’s height.
            # Pressing down will grow the window’s height.
            bindsym j resize shrink width 10 px or 10 ppt
            bindsym k resize grow height 10 px or 10 ppt
            bindsym l resize shrink height 10 px or 10 ppt
            bindsym semicolon resize grow width 10 px or 10 ppt

            # same bindings, but for the arrow keys
            bindsym Left resize shrink width 10 px or 10 ppt
            bindsym Down resize grow height 10 px or 10 ppt
            bindsym Up resize shrink height 10 px or 10 ppt
            bindsym Right resize grow width 10 px or 10 ppt

            # back to normal: Enter or Escape
            bindsym Return mode "default"
            bindsym Escape mode "default"
    }

    bindsym $mod+r mode "resize"

    # Start i3bar to display a workspace bar (plus the system information i3status
    # finds out, if available)
    bar {
            font pango:Fira Mono 9
            status_command ${i3status}/bin/i3status -c ${
              writeText "i3status-config" i3StatusBarConfig
            }
    }
  ''
)
