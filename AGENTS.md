# AGENTS.md instructions for /etc/nixos

<INSTRUCTIONS>
## Overview
- This repo is a flake-based NixOS config for host `falcon`.
- The active flake output is `nixosConfigurations.falcon`.
- Main entry is `hosts/falcon/default.nix`.

## Public-safe layout
- `flake.nix` / `flake.lock`: flake inputs and NixOS outputs.
- `hosts/falcon/default.nix`: host entry point, imports host files, base modules, service modules, and third-party flake modules.
- `hosts/falcon/hardware-configuration.nix`: generated hardware config. Do not edit directly.
- `hosts/falcon/networking.nix`: static networking, firewall, LAN-only rules, resolved, and SSH.
- `hosts/falcon/storage.nix`: host storage mounts, including NAS/NFS media mount.
- `modules/nixos/base/users.nix`: local user declaration.
- `modules/nixos/base/packages.nix`: system-level packages, including the SOPS CLI for editing encrypted secrets.
- `modules/nixos/base/auto-upgrade.nix`: automatic flake upgrades, GC, and store optimization.
- `home/zx/default.nix`: Home Manager user packages, Git settings, shell basics, Starship prompt, Zellij config/web service, and Nix-managed tmux plugins.
- `modules/nixos/services/*.nix`: service modules.
- `vars.example.nix`: tracked placeholder schema for site-specific non-secret values.
- `vars.nix`: ignored real local values used by the flake.
- `.sops.yaml`: tracked SOPS recipient/rule configuration.
- `secrets/falcon.yaml`: tracked encrypted SOPS secrets for this host.
- `secrets/README.md`: public-safe secret key documentation and SOPS editing notes.
- `cloudflare-token.nix`: ignored legacy plaintext token file retained only as a pre-SOPS migration fallback.
- `secrets/legacy.nix`: ignored legacy plaintext values retained only as a pre-SOPS migration fallback.

## Current service modules
- `adguard.nix`: AdGuard Home.
- `arr-stack.nix`: Native Sonarr, Radarr, Prowlarr, and Bazarr services for TV, movie, anime, and subtitle automation, bound locally and routed through Traefik; Sonarr/Radarr/Bazarr share the NAS media mount with Deluge/Jellyfin.
- `audiobookshelf.nix`: Audiobookshelf on the NAS media mount.
- `copyparty.nix`: Copyparty bound locally and served through Traefik.
- `ddclient.nix`: Cloudflare dynamic DNS updater.
- `deluge.nix`: Deluge daemon and web UI.
- `homepage.nix`: Homepage dashboard, info widgets, service cards, and custom AMOLED-black CSS with green accents.
- `immich.nix`: Immich with NAS media storage and hardware acceleration access.
- `jellyfin.nix`: Jellyfin with Intel VA-API support.
- `minecraft.nix`: Paper Minecraft via `nix-minecraft`.
- `teamspeak.nix`: TeamSpeak server with ports managed by the host firewall.
- `traefik.nix`: Traefik routing, TLS, and basic-auth middlewares.
- `tt-rss.nix`: Tiny Tiny RSS behind local nginx and Traefik.
- `wireguard.nix`: WireGuard VPN.
- `zellij.nix`: Enables lingering for the primary user so the Home Manager Zellij web service can run at boot.

## Change workflow
- Prefer adding new system-wide modules under `modules/nixos/base/`.
- Prefer adding service-specific modules under `modules/nixos/services/` and import them from `hosts/falcon/default.nix`.
- Put host-specific non-secret values, including Git identity, in `vars.nix` and mirror the schema with fake placeholders in `vars.example.nix`.
- Because this is a Git-backed flake with ignored local vars, local evaluation must use `--impure`; `flake.nix` reads `NIXOS_VARS` if set, otherwise `/etc/nixos/vars.nix`.
- Do not add real domains, public IPs, private LAN addresses, usernames, API keys, password hashes, or tokens to tracked files.
- When changing LAN/WAN exposure, update both Traefik routers and firewall rules.
- Local web dashboards should use configured local wildcard hostnames from `vars.nix` where a route exists; keep raw IPs mainly for health pings or devices without DNS names.
- Keep Arr stack services LAN/local-only. Sonarr/Radarr should use the NAS mount for both downloads and final libraries so completed torrents can be hardlinked while Deluge keeps seeding. Anime series use a separate Sonarr root folder and Deluge category under the same mount; anime movies stay in the regular movie flow. Bazarr handles general subtitle automation for Sonarr/Radarr libraries and needs write access to the final media folders.
- Homepage layout is intentionally compact: prefer grouped cards and credential-free info widgets before adding new sparse sections.
- Keep changes flake-compatible and use packages from flake inputs.

## Secrets policy
- SOPS is enabled through `sops-nix`.
- Host secrets live in tracked encrypted `secrets/falcon.yaml`.
- The SOPS age key is expected at `/home/zx/.config/sops/age/keys.txt`; keep it out of the repo.
- Traefik, ddclient, Homepage widget API keys, and Copyparty password are sourced from SOPS.
- GitHub PATs should be stored in SOPS when they need to be reused on the host; use the `github_pat_push_to_falcon` key documented in `secrets/README.md`.
- `cloudflare-token.nix` and `secrets/legacy.nix` are ignored legacy fallback files only; do not add new consumers.
- Do not move secrets into `vars.nix`; it is private but intended only for non-secret site inventory.
- Future work may migrate the WireGuard server private key to SOPS if desired.

## Backup and restore
- A protected backup was created under `/var/backups/nixos-config`.
- Backup archives are root-owned tarballs with a `SHA256SUMS` file in the same directory.
- To restore, inspect/list the archive first, then extract only the needed files or restore the full `/etc/nixos` tree from a root shell.
- Do not store backups inside this repo.

## Apply/rebuild
- Preferred validation target:
  `sudo nixos-rebuild dry-run --impure --flake path:/etc/nixos#falcon`
- Standard switch command after validation:
  `sudo nixos-rebuild switch --impure --flake path:/etc/nixos#falcon`
- Automatic upgrades use `path:/etc/nixos#falcon`, `--impure`, auto-update `flake.lock`, and `allowReboot = false`.
- Codex cannot run `sudo`. If a task needs root-only commands, stop before that step and tell the user exactly what to run.

## Git hygiene
- `.gitignore` excludes local/private files: `vars.nix`, `inventory.nix`, `cloudflare-token.nix`, plaintext legacy secret files, `.claude/`, `.codex`, and local server data.
- Encrypted `secrets/falcon.yaml` is intentionally trackable.
- This repo uses tracked Git hooks from `hooks/`; local Git config should set `core.hooksPath = hooks`.
- The pre-commit hook runs `nix flake check --impure --no-write-lock-file`.
- Before committing, verify ignored files are not staged.
- Public tracked files should be usable as a template with `vars.example.nix`, but this host's live flake evaluation depends on ignored local files.

## Keeping this file up to date
- If any significant config change is made, update the relevant section in this file in the same session.
- Keep this file public-safe. Summarize services and patterns without copying live private inventory values.
</INSTRUCTIONS>
