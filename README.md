# dankapps

A collection of Quickshell-based media viewer apps for DankMaterialShell (DMS) and standalone use.

## Apps

| App | Description | Binary |
|-----|-------------|--------|
| [dankview](./dankview/) | Image viewer with EXIF inspector, crop, zoom | `dview` |
| [dankvideo](./dankvideo/) | Video player with media inspector | `dplay` |

## Install an app

Each app is self-contained. Clone the repo and install only what you need:

```bash
git clone https://github.com/hthienloc/dankapps.git
cd dankapps

# Install dankview
cd dankview && make install-user

# Or install dankvideo
cd dankvideo && make install-user
```

## Requirements

- [Quickshell](https://quickshell.outfoxxed.me/) — QML shell framework
- Go 1.21+
- `dms` CLI (optional, for clipboard and toast notifications)

## Structure

```
dankapps/
├── dankview/      # Image viewer
├── dankvideo/     # Video player
└── go.work        # Go workspace (dev only)
```

## Credits & Acknowledgements

Special thanks to the community members who helped shape the design and conception of the apps:

- **Zurvan** (Discord) — Core design inspiration and UI concepts.
- **Stumbling** (Discord) & **bbedward** — Invaluable feedback, critique, and quality insights.
