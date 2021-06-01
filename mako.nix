{pkgs}:

pkgs.writeText "terminator.conf" (
  ''
default-timeout = 10000
  ''
)
