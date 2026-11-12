# ADS Suite installers

Public download repository for ADS Suite installers. Source code remains in a
separate private repository.

## One-click installer

Download:

```text
https://github.com/g4348914-coder/ads-suite-install/raw/main/install.cmd
```

Run `install.cmd` as Administrator (it elevates itself). It will:

- stop ADS Suite and ADS scheduled tasks;
- make a backup;
- download the full fixed archive;
- install it into `C:\ADS\ADS-Suite` (or the detected existing app folder);
- preserve existing keys, databases, proxies and settings;
- start ADS Monitor;
- leave `system.log` next to `ADS Monitor.exe`.

## Direct archive

Full fixed old version:

```text
https://github.com/g4348914-coder/ads-suite-install/releases/download/v2026.11.12-log2/ADS-Suite-FIXED-20261112.zip
```

Count/clicker patch:

```text
https://github.com/g4348914-coder/ads-suite-install/releases/download/v2026.11.12-log2/ADS-Count-Fix.zip
```

Minimal Octo status hotfix (`writeProcStatus`):

```text
https://github.com/g4348914-coder/ads-suite-install/releases/download/v2026.11.12-log2/ADS-Octo-Status-Fix.zip
```

ADS Suite v2:

```text
https://github.com/g4348914-coder/ads-suite-install/releases/download/v2026.11.12-log2/ADS-Suite-v2-phase6.zip
```

SHA-256 of the full archive:

```text
7F20B93F65A424B03E07D1B57F41F506D3781946920E3757DB8F477EF2D1A5CF
```

Important: release `v2026.11.12-log` contains an older archive with a broken
`checker-server.js` (`writeProcStatus is not defined`). Use `v2026.11.12-log2`
or the minimal status hotfix above.
