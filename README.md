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
https://github.com/g4348914-coder/ads-suite-install/releases/download/v2026.11.12-log/ADS-Suite-FIXED-20261112.zip
```

Count/clicker patch:

```text
https://github.com/g4348914-coder/ads-suite-install/releases/download/v2026.11.12-log/ADS-Count-Fix.zip
```

ADS Suite v2:

```text
https://github.com/g4348914-coder/ads-suite-install/releases/download/v2026.11.12-log/ADS-Suite-v2-phase6.zip
```

SHA-256 of the full archive:

```text
727D3282A4A64EEE21A138A12BD80B8B3BEE5CECCD41360CBB2466BCDA8DB904
```
