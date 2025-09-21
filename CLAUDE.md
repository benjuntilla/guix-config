# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Guix Configuration Repository

This is a personal Guix system and home configuration repository that manages both system-level (Guix System) and user-level (Guix Home) settings in a declarative manner.

### Key Commands

- **Apply user configuration changes**: `guix-home-reconfigure`
  - This custom script removes Emacs config cache, runs the Guix home reconfiguration, and updates Fish shell plugins
  - Located at: `home/dotfiles/.local/bin/guix-home-reconfigure`

- **Apply system configuration changes**: `sudo guix system reconfigure ./systems/$SYSTEM_NAME.scm`
  - Replace `$SYSTEM_NAME` with the specific system configuration (e.g., `benslab`, `chimaera`)

- **Update channels**: `guix pull`

- **Search for packages**: `guix search PACKAGE_NAME`

### Architecture

The codebase is organized into two main areas:

1. **User Configuration (`home/`)**
   - `home.scm`: Main home environment configuration defining services, environment variables, and shell setup
   - `packages.scm`: User-level packages specification
   - `dotfiles/`: All user configuration files managed via `home-dotfiles-service-type`
   - `services/`: Custom service definitions (e.g., Maestral for Dropbox)

2. **System Configuration (`systems/`)**
   - Individual `.scm` files for each machine (e.g., `benslab.scm`, `chimaera.scm`)
   - Contains hardware-specific settings, kernel configuration, system services, and user accounts

### Dotfiles Management

- Dotfiles are stored in `home/dotfiles/` and symlinked to their proper locations
- The `home-dotfiles-service-type` with `'plain` layout is used for this purpose
- After modifying any dotfile, run `guix-home-reconfigure` to apply changes
- Current dotfiles include configurations for:
  - Shells (Zsh, Fish)
  - Editors (Helix, Neovim, Emacs)
  - Terminal emulators (Ghostty, Wezterm)
  - Window managers (Niri)
  - Various applications (Rofi, Dunst, Zathura, etc.)

### Package Management

- User packages are declared in `home/packages.scm`
- System packages are included in the system configuration files
- Uses Nonguix channel for proprietary software support
- To add a package: Edit the appropriate file and reconfigure

### Theme Management

The repository includes infrastructure for dark/light mode switching:
- Scripts in `.local/share/dark-mode.d/` and `.local/share/light-mode.d/`
- Integration with `darkman` for automatic theme switching

### Development Notes

- When modifying shell configurations, changes take effect after running `guix-home-reconfigure`
- Custom services can be defined in `home/services/` using standard Guix service patterns
- Environment variables are set in `home.scm` under `home-environment-variables-service-type`
- The repository uses the functional approach - all changes are declarative and reproducible