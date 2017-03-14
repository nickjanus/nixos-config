### Background
This repo houses all of my nixos configuration for a work laptop and my home desktop, including any dotfiles that I'd like to keep consistent across environments. If you're interested in switching to nixos and have questions, I'd be happy to answer in a Github issue.

### Setup
- Install nixos
- Backup `./hardware-configuration.nix`
- Clone this repo into /etc/nixos
- Decide on a name for the machine you're setting up and enter it in `./parameters.nix` like so:
```nix
{
  machineName = "thinksad";
}
```
- Move `hardware-configuration.nix` to ./hardware-configurations/`machineName`.nix 
- Add any other machine specific config to machines/`machineName`.nix
