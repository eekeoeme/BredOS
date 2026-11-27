# BredOS architecture
- Base: Debian 13 (trixie), x86_64, APT/.deb
- ISO: Debian live-build, built in GitHub Actions (iso/build.sh)
- Installer: Calamares (phase 1), bread-slice GTK4 installer front-end (phase 2)
- Desktop: Rust + GTK4 shell, Rust + Smithay compositor (phase 2)
- Phase 1 desktop is a placeholder: labwc + waybar + fuzzel + foot + pcmanfm
