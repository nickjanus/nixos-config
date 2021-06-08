{pkgs}:

pkgs.writeText "mako.conf" (
  ''
default-timeout=10000
ignore-timeout=1
  ''
)
