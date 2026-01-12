Here is the comprehensive documentation for your **Micro-Frontend (MFE) Monorepo**. This content is designed to be pasted directly into your `README.md` to explain the architecture, design patterns, and deployment strategy to your team or stakeholders.

---

# 🏗️ MFE Platform Monorepo

This repository is a production-grade Micro-Frontend (MFE) architecture built using **React 19**, **Vite 7**, **pnpm Workspaces**, and **Turborepo**. It utilizes **Module Federation** to enable independent deployment of apps while maintaining a unified user experience on a single domain.

---

## 🚀 Quick Start

### 1. Initialize the Project

If you haven't run the setup script yet, save it as `setup.sh` and run:

```bash
# Make the script executable
chmod +x setup.sh

# Run with your custom App Name
./setup.sh "my-mfe-platform"

```

### 2. Development Workflow

```bash
# Install all dependencies (links local packages/ui)
pnpm install

# Build all apps (Required for the first federation preview)
pnpm build

# Start all apps in Dev Mode
# Shell: http://localhost:5173 | MFE1: 5001 | MFE2: 5002
pnpm dev

```

### 3. Local Production Preview

To test the "Same Domain" experience locally (simulating Vercel/Nginx):

```bash
pnpm local:preview

```

---

## 📐 Architecture & Design

### 1. Core Technologies

- **Package Manager:** `pnpm` (Workspaces) for lightning-fast installs and symlinking.
- **Build System:** `Turborepo` for remote caching and parallel execution.
- **MFE Engine:** `@originjs/vite-plugin-federation` (ESM-based federation).
- **Routing:** `react-router-dom v6` with path-based subfolder routing.

### 2. Project Structure

```text
- apps
  - mfe-apps/mfe1   # Remote App 1 (Exposes components)
  - mfe-apps/mfe2   # Remote App 2 (Exposes components)
  - shell           # Host App (Consumes Remotes)
- packages
  - ui              # Shared Design System (Internal library)
- vercel.json       # POC Routing Configuration
- Dockerfile        # Production Multi-stage Build
- nginx.conf        # Production Subpath Routing

```

### 3. The "Same Domain" Pattern

Unlike traditional MFEs that live on different subdomains (e.g., `mfe1.app.com`), this architecture hosts everything on one domain using **Subpath Routing**:

- `/` → Served by the **Shell**.
- `/mfe1/` → Served by **MFE1**.
- `/mfe2/` → Served by **MFE2**.

---

## 🌐 Deployment Strategy

### Phase 1: Vercel (POC)

The `vercel.json` utilizes **Rewrites** to act as a reverse proxy. This is critical for SPA support. We prioritize MFE subpaths before falling back to the Shell.

**Why specific rewrites?**
A standard `/(.*) -> index.html` rewrite would break MFEs. Our hardened configuration ensures that requests for `/mfe1/assets/` actually reach the MFE1 directory, while deep links (like `/mfe1/dashboard`) correctly reload the MFE1 `index.html`.

### Phase 2: AWS / Production (Docker + Nginx)

The production build uses a **Multi-stage Dockerfile**:

1. **Build Stage:** Uses `pnpm` and `turbo` to build all apps in the monorepo.
2. **Serve Stage:** An `nginx:alpine` image is created.

- The Shell is copied to the root.
- MFEs are copied to subdirectories (`/mfe1`, `/mfe2`).
- The `nginx.conf` uses the `alias` directive to ensure subpath routing works perfectly with Vite's `base` paths.

---

## 🛠️ CI/CD Pipeline (Bamboo & JFrog)

To move this to your AWS environment, configure your **Bamboo** plan as follows:

1. **Build:** Run `docker build -t <jfrog-registry>/platform:latest .` from the root.
2. **Artifact:** Push the image to **JFrog Artifactory**.
3. **Deploy:** Update your **Helm Chart** to pull the new image.

- _Note:_ Ensure your Load Balancer (ALB) or Ingress Controller passes the path header so Nginx can resolve the `/mfe1` routes.

---

## 📋 Development Standards

- **Shared UI:** Always import from `@repo/ui`. Do not duplicate common components.
- **Environment Variables:**
- Use `.env.local` for local development (pointing to ports 5001/5002).
- Use `.env.production` for cloud builds (using relative `/mfe1` paths).

- **TypeScript:** All remotes must be declared in `apps/shell/src/vite-env.d.ts` to avoid "Module Not Found" errors.

---

**Next Steps:** Would you like me to generate the **Bamboo Spec (YAML)** or a **Helm Chart** to automate the deployment of this specific architecture?
