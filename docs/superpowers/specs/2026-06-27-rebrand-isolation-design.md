# Rebrand Isolation for Open WebUI

## Problem

Open WebUI's static assets (logos, favicons, theme CSS, fonts, splash screens, PWA manifest) are baked into the Docker image at build time via the SvelteKit build process and backend static directory. When a user customizes these files and later pulls a newer upstream image version, their customizations are lost because the new image overwrites them.

The user needs a way to persist branding customizations across upstream version updates, without forking the repo or maintaining patch files.

## Solution Overview

Create a custom Docker image that extends the upstream `ghcr.io/open-webui/open-webui` image and overlays local branding files. A dedicated `docker-compose.rebrand.yaml` orchestrates this.

The branding files live in a local `branding/` directory under the project root, tracked in the user's own git repo (or not, as they prefer). When a new upstream version is released, the user rebuilds with `--pull` and their branding files are reapplied during the build.

## Files to Create

### `Dockerfile.rebrand`

```dockerfile
FROM ghcr.io/open-webui/open-webui:main

COPY branding/frontend/static /app/build/static/
COPY branding/frontend/assets /app/build/static/assets/
COPY branding/backend /app/backend/open_webui/static/
```

Build context is the project root, so `branding/frontend` resolves to `<project-root>/branding/frontend`.

### `docker-compose.rebrand.yaml`

```yaml
services:
  open-webui:
    build:
      context: .
      dockerfile: Dockerfile.rebrand
    image: open-webui-rebrand:latest
    ports:
      - 3000:8080
    volumes:
      - open-webui:/app/backend/data
    environment:
      - WEBUI_NAME=My Custom Name
    extra_hosts:
      - host.docker.internal:host-gateway

volumes:
  open-webui:
```

### `branding/` directory layout

```
branding/
├── frontend/               # Mapped to /app/build/static/ in the image
│   ├── favicon.png          # Browser tab icon
│   ├── favicon-dark.png     # Dark mode variant
│   ├── favicon.svg          # Vector favicon
│   ├── favicon.ico          # Legacy favicon
│   ├── favicon-96x96.png    # PWA icon
│   ├── apple-touch-icon.png # iOS home screen icon
│   ├── logo.png             # Sidebar/header logo
│   ├── splash.png           # Loading screen (light)
│   ├── splash-dark.png      # Loading screen (dark)
│   ├── custom.css           # CSS overrides (empty by default, user fills)
│   ├── loader.js            # JS overrides (empty by default, user fills)
│   ├── site.webmanifest     # PWA manifest
│   ├── web-app-manifest-192x192.png
│   ├── web-app-manifest-512x512.png
│   ├── user.png             # Default user avatar
│   ├── user-import.csv      # User import template
│   ├── themes/*.css         # Custom theme files
│   │   └── my-brand.css
│   ├── assets/
│   │   ├── fonts/*          # Custom fonts
│   │   │   └── MyBrand-Variable.ttf
│   │   ├── images/*         # Custom images
│   │   │   └── hero-bg.jpg
│   │   └── emojis/          # Custom emoji SVGs
│   ├── audio/
│   │   ├── notification.mp3
│   │   └── greeting.mp3
│   ├── sql.js/
│   │   └── sql-wasm.wasm
│   └── pyodide/
│       └── pyodide-lock.json
│
└── backend/                 # Mapped to /app/backend/open_webui/static/ in the image
    ├── fonts/               # PDF/report fonts
    │   ├── NotoSans-Regular.ttf
    │   ├── NotoSans-Bold.ttf
    │   └── ...
    └── assets/
        └── pdf-style.css    # PDF export styling
```

Only files that need customization must be present. Files not present fall through to the base image.

## How Static Files Are Served (Background)

Two static file mounts exist in the FastAPI application:

| URL path | Filesystem path | Env var override |
|---|---|---|
| `/static/*` | `/app/backend/open_webui/static/` | `STATIC_DIR` |
| `/*` (SPA) | `/app/build/` | `FRONTEND_BUILD_DIR` |

The frontend SvelteKit app (`/app/build/`) has a `static/` subdirectory copied from the project's `static/` directory at build time. This subdirectory contains favicons, logos, splash screens, themes, fonts, and asset files.

The `COPY branding/frontend /app/build/static/` in `Dockerfile.rebrand` overlays custom versions of these files onto the base image's build output.

## Edge Cases

- **New upstream files:** If a future upstream version adds a new file (e.g., `favicon-dark.svg`), the user will not automatically have a branded version. They must add it to their `branding/frontend/`. This is an explicit trade-off — the user controls what gets overridden.
- **Deleted upstream files:** Unlikely, but if upstream removes a file the user's branding overrides, the `COPY` still succeeds (the file just won't be served). No crash.
- **Empty `branding/frontend/`:** The `COPY` succeeds and no files are overridden. The app runs identically to upstream.
- **File in wrong directory:** If a user puts `favicon.png` in `branding/backend/` instead of `branding/frontend/`, it won't be picked up. Clear docs mitigate this.

## Usage

### Initial setup

```bash
# Create directory structure
mkdir -p branding/frontend/{themes,assets/fonts,assets/images,audio,sql.js,pyodide}
mkdir -p branding/backend/{fonts,assets}

# Extract originals you want to customize (example: favicon + logo)
docker run --rm -v ./branding/frontend:/out ghcr.io/open-webui/open-webui:main \
  sh -c "cp /app/build/static/favicon.png /out/ && cp /app/build/static/logo.png /out/"

# Build and run the rebranded instance
docker compose -f docker-compose.rebrand.yaml up -d
```

### Upgrading upstream

```bash
docker compose -f docker-compose.rebrand.yaml build --pull
docker compose -f docker-compose.rebrand.yaml up -d
```

### Adding a new branded file

```bash
# Extract the original from the current image
docker run --rm -v ./branding/frontend:/out ghcr.io/open-webui/open-webui:main \
  sh -c "cp /app/build/static/new-asset.png /out/"

# Edit branding/frontend/new-asset.png, then rebuild
docker compose -f docker-compose.rebrand.yaml build
docker compose -f docker-compose.rebrand.yaml up -d
```

## Rationale

**Why a custom image instead of volume mounts?** Docker bind mounts replace the entire contents of a directory — they cannot overlay individual files within an existing directory. A volume mount at `/app/build/static/` would hide all original files, requiring the user to maintain a complete copy of every static file. The `COPY` approach in a Dockerfile overlays only the files you provide.

**Why not use `custom.css` / `loader.js` alone?** These hooks only support CSS and JS injections. They cannot replace images, fonts, favicons, or PWA assets.

**Why not fork the repo?** Forks require ongoing merge work to stay in sync. The custom image approach is a 2-file setup (Dockerfile + compose override) with zero fork maintenance.

## Non-Goals

- Hot-reloading branding files (requires rebuild/restart)
- Managing branded configurations across multiple instances (out of scope)
- Providing a UI for branding changes
- Hot-reloading branding changes without rebuild or restart
