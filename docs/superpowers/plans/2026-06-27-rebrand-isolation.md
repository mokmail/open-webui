# Rebrand Isolation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `Dockerfile.rebrand`, `docker-compose.rebrand.yaml`, and `branding/` directory so Open WebUI branding customizations survive upstream version updates.

**Architecture:** A `Dockerfile.rebrand` extends `ghcr.io/open-webui/open-webui:main` with `COPY` of local `branding/` files over the base image's static asset directories. A `docker-compose.rebrand.yaml` orchestrates building and running this custom image alongside the existing data volume.

**Tech Stack:** Docker, Docker Compose

## Global Constraints

- All new files at project root: `Dockerfile.rebrand`, `docker-compose.rebrand.yaml`, `branding/`
- `branding/frontend/` maps to `/app/build/static/` in the container (frontend assets: favicons, logos, splash, themes, fonts, custom.css, loader.js)
- `branding/backend/` maps to `/app/backend/open_webui/static/` (backend assets: PDF fonts, swagger, pdf-style.css)
- Empty `branding/` subdirectories tracked via `.gitkeep` files
- Compose file uses the same named volume `open-webui` as the original `docker-compose.yaml` for data persistence
- Port mapping: `3000:8080` (same convention as original)

---

### Task 1: Create branding directory scaffolding

**Files:**
- Create: `branding/frontend/.gitkeep`
- Create: `branding/backend/.gitkeep`

**Interfaces:**
- Consumes: nothing
- Produces: `branding/frontend/` and `branding/backend/` directories tracked in git

- [ ] **Step 1: Create directories**

```bash
mkdir -p branding/frontend branding/backend
```

- [ ] **Step 2: Add .gitkeep files**

```bash
touch branding/frontend/.gitkeep branding/backend/.gitkeep
```

- [ ] **Step 3: Verify structure**

```bash
ls -la branding/
```

Expected output (files may differ slightly):

```
total 0
drwxr-xr-x  4 user  staff  128 Jun 27 10:00 .
drwxr-xr-x  8 user  staff  256 Jun 27 10:00 ..
drwxr-xr-x  3 user  staff   96 Jun 27 10:00 backend
drwxr-xr-x  3 user  staff   96 Jun 27 10:00 frontend
```

- [ ] **Step 4: Stage and commit**

```bash
git add branding/
git commit -m "chore: add branding directory scaffolding"
```

---

### Task 2: Create Dockerfile.rebrand

**Files:**
- Create: `Dockerfile.rebrand`

**Interfaces:**
- Consumes: `branding/frontend/` and `branding/backend/` (from Task 1)
- Produces: Docker image `open-webui-rebrand:latest` (built in Task 4)

- [ ] **Step 1: Write Dockerfile.rebrand**

Write `Dockerfile.rebrand` at the project root:

```dockerfile
FROM ghcr.io/open-webui/open-webui:main

COPY branding/frontend/static /app/build/static/
COPY branding/frontend/assets /app/build/static/assets/
COPY branding/backend /app/backend/open_webui/static/
```

Note: No `ENV WEBUI_NAME` is set in the Dockerfile — the compose file (Task 3) provides it via `environment:` so the user can change it without editing Dockerfile.rebrand.

- [ ] **Step 2: Verify file exists**

```bash
cat Dockerfile.rebrand
```

Expected: contents match the Dockerfile above.

- [ ] **Step 3: Stage and commit**

```bash
git add Dockerfile.rebrand
git commit -m "feat: add Dockerfile.rebrand for custom branding overlay"
```

---

### Task 3: Create docker-compose.rebrand.yaml

**Files:**
- Create: `docker-compose.rebrand.yaml`

**Interfaces:**
- Consumes: `Dockerfile.rebrand` (from Task 2), `open-webui` Docker volume (pre-existing)
- Produces: Runnable rebranded Open WebUI instance

- [ ] **Step 1: Write docker-compose.rebrand.yaml**

Write `docker-compose.rebrand.yaml` at the project root:

```yaml
services:
  open-webui:
    build:
      context: .
      dockerfile: Dockerfile.rebrand
    image: open-webui-rebrand:latest
    container_name: open-webui-rebrand
    ports:
      - ${OPEN_WEBUI_PORT-3000}:8080
    volumes:
      - open-webui:/app/backend/data
    environment:
      - WEBUI_NAME=${WEBUI_NAME:-Open WebUI}
    extra_hosts:
      - host.docker.internal:host-gateway
    restart: unless-stopped

volumes:
  open-webui:
```

Key choices:
- **`image: open-webui-rebrand:latest`** — tags the built image separately so it doesn't interfere with `ghcr.io/open-webui/open-webui:main` pulls
- **`container_name: open-webui-rebrand`** — avoids name collision with any running `open-webui` container from the original compose file
- **`WEBUI_NAME`** uses the same `${VAR:-default}` env var pattern as the original compose file
- **`OPEN_WEBUI_PORT`** — same env var convention as the original compose file, defaults to `3000`
- Shares the same named volume `open-webui` so data (users, chats, models) is shared with the original instance. The user can change this to `open-webui-rebrand` if they want isolation.

- [ ] **Step 2: Verify file exists**

```bash
cat docker-compose.rebrand.yaml
```

Expected: contents match above.

- [ ] **Step 3: Stage and commit**

```bash
git add docker-compose.rebrand.yaml
git commit -m "feat: add docker-compose.rebrand.yaml for rebranded instance"
```

---

### Task 4: Build and verify the custom image

**Files:**
- No files created/modified (verification only)

**Interfaces:**
- Consumes: all files from Tasks 1-3

- [ ] **Step 1: Build the custom image**

```bash
docker compose -f docker-compose.rebrand.yaml build
```

Expected: Build succeeds (exit code 0). Docker output shows the build steps.

- [ ] **Step 2: Verify branding files are overlaid correctly**

Run a temporary container to confirm the overlay works:

```bash
docker run --rm open-webui-rebrand:latest ls -la /app/build/static/.gitkeep
```

Expected output shows `.gitkeep` exists in the container (proving the COPY from `branding/frontend/` worked).

```bash
docker run --rm open-webui-rebrand:latest ls -la /app/backend/open_webui/static/.gitkeep
```

Expected output shows `.gitkeep` exists in the container (proving the COPY from `branding/backend/` worked).

- [ ] **Step 3: Start the rebranded instance (optional)**

```bash
WEBUI_NAME="My Custom Name" docker compose -f docker-compose.rebrand.yaml up -d
```

Expected: Container starts, logs show no errors at startup.

```bash
docker compose -f docker-compose.rebrand.yaml ps
```

Expected: Container status is `Up`.

- [ ] **Step 4: Test HTTP access (optional)**

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/
```

Expected: `200`

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/static/favicon.png
```

Expected: `200`

- [ ] **Step 5: Stop the rebranded instance**

```bash
docker compose -f docker-compose.rebrand.yaml down
```
