{pkgs}:

pkgs.writeText "terminator.conf" (
  ''
default-timeout = 10000
ignore-timeout = 1
  ''
)
