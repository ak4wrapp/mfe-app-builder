# MFE Platform Monorepo

## Dev URLs

- Shell: http://localhost:5173/
- MFE1: http://localhost:5001/
- MFE2: http://localhost:5002/

## Build & Run

1. **Install dependencies**

```bash
pnpm install
```

2. **Build all apps**

```bash
pnpm build
```

3. Local Production Preview

To test the "Same Domain" experience locally (simulating Vercel/Nginx):

```bash
pnpm local:preview

```

4. **Run dev servers**

```bash
pnpm dev
```

5. **Open in browser**

- Shell → http://localhost:5173/
- MFEs will load automatically inside Shell via module federation

## Production

- MFEs served under /mfe1 and /mfe2 paths
- Vercel / Nginx configuration required
  (Vercel has a limit of 100 deployments in 24 hours rolling time)
