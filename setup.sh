#!/bin/bash
set -e


APP_NAME="${1:-my-mfe-app}"
echo "🚀 Creating project $APP_NAME..."
mkdir -p $APP_NAME && cd $APP_NAME

# ---------------------------------------------------
# 1. Root Workspace & Turbo Configuration
# ---------------------------------------------------

cat <<EOF > package.json
{
  "name": "$APP_NAME",
  "private": true,
  "packageManager": "pnpm@10.28.0",
  "scripts": {
    "dev": "pnpm exec turbo dev",
    "build": "pnpm exec turbo build",
    "preview": "concurrently -k -n MFES,SHELL \"pnpm exec turbo preview --filter=!shell\" \"pnpm --filter shell dev\"",
    "local:preview": "concurrently -k -n MFES,SHELL \"pnpm exec turbo preview --filter=!shell\" \"pnpm --filter shell local:preview\""
  },
  "devDependencies": {
    "concurrently": "^9.2.1",
    "turbo": "^2.7.3",
    "typescript": "^5.2.2"
  }
}
EOF

cat <<EOF > pnpm-workspace.yaml
packages:
  - "apps/**"
  - "packages/**"
EOF

cat <<EOF > turbo.json
{
  "\$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },

    "dev": {
      "cache": false,
      "persistent": true
    },

    "preview": {
      "dependsOn": ["build"],
      "cache": false,
      "persistent": true,
      "outputs": []
    },

    "local:preview": { 
      "cache": false, 
      "persistent": true 
    } 
  }
}
EOF

mkdir -p apps/mfe-apps/{mfe1,mfe2}/src apps/shell/src packages/ui/src

# ---------------------------------------------------
# 2. Shared UI (@repo/ui)
# ---------------------------------------------------

cat <<EOF > packages/ui/package.json
{
  "name": "@repo/ui",
  "private": true,
  "version": "0.0.1",
  "type": "module",
  "main": "src/index.ts",
  "types": "src/index.ts",
  "dependencies": {
    "react": "^19.2.0",
    "react-dom": "^19.2.0"
  },
  "devDependencies": {
    "@eslint/js": "^9.39.1",
    "@types/node": "^24.10.1",
    "@types/react": "^19.2.5",
    "@types/react-dom": "^19.2.3",
    "@vitejs/plugin-react": "^5.1.1",
    "eslint": "^9.39.1",
    "eslint-plugin-react-hooks": "^7.0.1",
    "eslint-plugin-react-refresh": "^0.4.24",
    "globals": "^16.5.0",
    "typescript": "~5.9.3",
    "typescript-eslint": "^8.46.4"
  }
}
EOF

cat <<EOF > packages/ui/src/components/SharedButton/index.tsx
import React from "react";
export const SharedButton = ({ text }: { text: string }) => (
  <button
    style={{
      padding: "10px 20px",
      background: "#0070f3",
      color: "white",
      border: "none",
      borderRadius: 6,
      cursor: "pointer",
    }}
  >
    {text}
  </button>
);
EOF


cat <<EOF > packages/ui/src/components/index.ts
export { SharedButton } from "./SharedButton"; // <- named export
EOF

cat <<EOF > packages/ui/src/index.ts
export * from "./components";
EOF

# ---------------------------------------------------
# 3. Micro-frontend generator (updated for prod base)
# ---------------------------------------------------

create_mfe () {
  NAME=$1
  PORT=$2
  cat <<EOF > apps/mfe-apps/$NAME/package.json
{
  "name": "$NAME",
  "private": true,
  "scripts": {
    "dev": "vite --port $PORT",
    "build": "vite build",
    "preview": "vite preview --port $PORT"
  },
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "react-router-dom": "^6.22.0",
    "@repo/ui": "workspace:*"
  },
  "devDependencies": {
    "vite": "^7.2.4",
    "typescript": "~5.9.3",
    "@vitejs/plugin-react": "^5.1.1",
    "@originjs/vite-plugin-federation": "^1.3.9",
    "@types/react": "^19.2.5",
    "@types/react-dom": "^19.2.3",
    "@types/node": "^24.10.1",
    "eslint": "^9.39.1",
    "@eslint/js": "^9.39.1",
    "eslint-plugin-react-hooks": "^7.0.1",
    "eslint-plugin-react-refresh": "^0.4.24",
    "globals": "^16.5.0",
    "typescript-eslint": "^8.46.4"
  }
}
EOF

cat <<EOF > apps/mfe-apps/$NAME/vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import federation from '@originjs/vite-plugin-federation'

export default defineConfig(({ mode }) => ({
  // Use '/' for dev, '/mfe1/' or '/mfe2/' for production
  base: mode === 'production' ? '/$NAME/' : '/',
  plugins: [
    react(),
    federation({
      name: '$NAME',
      filename: 'remoteEntry.js',
      exposes: { './App': './src/App.tsx' },
      shared: ['react', 'react-dom']
    })
  ],
  build: { target: 'esnext', minify: false, cssCodeSplit: false }
}))
EOF

cat <<EOF > apps/mfe-apps/$NAME/src/App.tsx
import React from 'react';
export default () => (
  <div style={{padding: '20px', border: '2px solid red', borderRadius: '8px'}}>
    <h2>Micro-frontend: $NAME</h2>
    <p>This is a remote component.</p>
  </div>
)
EOF

  # ----------------------------
  # src/main.tsx
  # ----------------------------
cat <<EOF > apps/mfe-apps/$NAME/src/main.tsx
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";

  ReactDOM.createRoot(document.getElementById("root")!).render(<App />);
EOF

  # ----------------------------
  # index.html
  # ----------------------------
cat <<EOF > apps/mfe-apps/$NAME/index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>$NAME</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

  # ----------------------------
  # vite-env.d.ts
  # ----------------------------
cat <<EOF > apps/mfe-apps/$NAME/vite-env.d.ts
/// <reference types="vite/client" />
EOF

}

create_mfe mfe1 5001
create_mfe mfe2 5002

# ---------------------------------------------------
# 4. Shell App
# ---------------------------------------------------

cat <<EOF > apps/shell/package.json
{
  "name": "shell",
  "private": true,
  "scripts": { 
    "dev": "vite",
    "local:preview": "vite --mode localpreview",
    "build": "vite build"
  },
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "react-router-dom": "^6.22.0",
    "@repo/ui": "workspace:*"
  },
  "devDependencies": {
    "vite": "^7.2.4",
    "typescript": "~5.9.3",
    "@vitejs/plugin-react": "^5.1.1",
    "@originjs/vite-plugin-federation": "^1.3.9",
    "@types/react": "^19.2.5",
    "@types/react-dom": "^19.2.3",
    "@types/node": "^24.10.1",
    "eslint": "^9.39.1",
    "@eslint/js": "^9.39.1",
    "eslint-plugin-react-hooks": "^7.0.1",
    "eslint-plugin-react-refresh": "^0.4.24",
    "globals": "^16.5.0",
    "typescript-eslint": "^8.46.4"
  }
}
EOF

# Local Dev URLs (root path)
cat <<EOF > apps/shell/.env.local
VITE_MFE1_URL=http://localhost:5001/mfe1/assets/remoteEntry.js
VITE_MFE2_URL=http://localhost:5002/mfe2/assets/remoteEntry.js
EOF

# Development URLs (subfolder)
cat <<EOF > apps/shell/.env.production
VITE_MFE1_URL=http://dev.com/mfe1/assets/remoteEntry.js
VITE_MFE2_URL=http://dev.com/mfe1/assets/remoteEntry.js
EOF

# Production URLs (subfolder)
cat <<EOF > apps/shell/.env.production
VITE_MFE1_URL=/mfe1/assets/remoteEntry.js
VITE_MFE2_URL=/mfe2/assets/remoteEntry.js
EOF

cat <<EOF > apps/shell/vite.config.ts
import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'
import federation from '@originjs/vite-plugin-federation'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  return {
    plugins: [
      react(),
      federation({
        name: 'shell',
        remotes: {
          mfe1: \`\${env.VITE_MFE1_URL}\`,
          mfe2: \`\${env.VITE_MFE2_URL}\`
        },
        shared: ['react', 'react-dom']
      })
    ]
  }
})

EOF

cat <<EOF > apps/shell/src/App.tsx
import React, { Suspense, lazy } from 'react'
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom'
import { SharedButton } from '@repo/ui'

// @ts-ignore
const Mfe1 = lazy(() => import('mfe1/App'))
// @ts-ignore
const Mfe2 = lazy(() => import('mfe2/App'))

export default () => (
  <BrowserRouter>
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h1>Host Shell</h1>
      <nav style={{ display: 'flex', gap: 15, marginBottom: '30px', background: '#f4f4f4', padding: '15px', borderRadius: '8px' }}>
        <Link to="/" style={{ textDecoration: 'none' }}><SharedButton text="Home" /></Link>
        <Link to="/mfe1" style={{ textDecoration: 'none' }}><SharedButton text="MFE 1" /></Link>
        <Link to="/mfe2" style={{ textDecoration: 'none' }}><SharedButton text="MFE 2" /></Link>
      </nav>
      <div style={{ border: '2px solid #0070f3', padding: '20px', borderRadius: '10px' }}>
        <Routes>
          <Route path="/" element={<div><h2>Welcome to the Shell</h2><p>Select an MFE above to load it at runtime.</p></div>} />
          <Route path="/mfe1" element={<Suspense fallback="Loading MFE1..."><Mfe1 /></Suspense>} />
          <Route path="/mfe2" element={<Suspense fallback="Loading MFE2..."><Mfe2 /></Suspense>} />
        </Routes>
      </div>
    </div>
  </BrowserRouter>
)
EOF

cat <<EOF > apps/shell/src/vite-env.d.ts
/// <reference types="vite/client" />
EOF

cat <<EOF > apps/shell/src/mfe.d.ts
declare module "mfe1/App" {
  import { ComponentType } from "react";
  const mfe1: ComponentType;
  export default mfe1;
}

declare module "mfe2/App" {
  import { ComponentType } from "react";
  const mfe2: ComponentType;
  export default mfe2;
}
EOF
# ---------------------------------------------------
# 5. .gitignore
# ---------------------------------------------------

cat <<EOF > .gitignore
# Node dependencies
node_modules/

# Build outputs
dist/
build/

# OS files
.DS_Store
Thumbs.db

# Editor directories and files
.vscode/
.idea/
*.suo
*.ntvs*
*.njsproj
*.sln

# Turbo cache
.turbo/

# Log files
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Optional: coverage reports
coverage/

EOF

# ---------------------------------------------------
# 6. README.md
# ---------------------------------------------------

cat <<EOF > README.md
# MFE Platform Monorepo

## Dev URLs
- Shell: http://localhost:5173/
- MFE1:  http://localhost:5001/
- MFE2:  http://localhost:5002/

## Build & Run

1. **Install dependencies**
\`\`\`bash
pnpm install
\`\`\`

2. **Build all apps**
\`\`\`bash
pnpm build
\`\`\`

3. **Run dev servers**
\`\`\`bash
pnpm dev
\`\`\`

4. **Open in browser**
- Shell → http://localhost:5173/
- MFEs will load automatically inside Shell via module federation

## Production
- MFEs served under /mfe1 and /mfe2 paths
- Vercel / Nginx configuration required
EOF

# ---------------------------------------------------
# 7. TSConfig
# ---------------------------------------------------

# ---------------------------------------------------
# 7.A. Root TSConfig
# ---------------------------------------------------

cat <<EOF > tsconfig.json
{
  "compilerOptions": {
    "target": "ESNext",
    "lib": [
      "DOM",
      "ESNext"
    ],
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "jsx": "react-jsx",
    "strict": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true
  }
}
EOF

# ---------------------------------------------------
# 7.B. App TSConfig
# ---------------------------------------------------
create_app_tsconfig() {
  APP_PATH=$1
  PREFIX=$2
  cat <<EOF > "$APP_PATH/tsconfig.json"
{
  "extends": "${PREFIX}tsconfig.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"]
}
EOF
}

# Usage
create_app_tsconfig apps/mfe-apps/mfe1 ../../../
create_app_tsconfig apps/mfe-apps/mfe2 ../../../
create_app_tsconfig apps/shell ../../


# ---------------------------------------------------
# 7.B. Packag-ui TSConfig
# ---------------------------------------------------
cat <<EOF > packages/ui/tsconfig.json
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"]
}
EOF

# ---------------------------------------------------
# 8. Shell main.tsx & index.html
# ---------------------------------------------------

cat <<EOF > apps/shell/index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Shell</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

cat <<EOF > apps/shell/src/main.tsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'

ReactDOM.createRoot(document.getElementById('root')!).render(<App />)
EOF

# ---------------------------------------------------
# 9. Vercel Configuration (POC)
# ---------------------------------------------------
# This routes domain.com/mfe1 to the correct index.html for SPA support
cat <<EOF > apps/shell/vercel.json
{
  "rewrites": [
    { "source": "/mfe1/:path*", "destination": "/apps/mfe-apps/mfe1/dist/:path*" },
    { "source": "/mfe2/:path*", "destination": "/apps/mfe-apps/mfe2/dist/:path*" },
    { "source": "/mfe1", "destination": "/apps/mfe-apps/mfe1/dist/index.html" },
    { "source": "/mfe2", "destination": "/apps/mfe-apps/mfe2/dist/index.html" },
    { "source": "/(.*)", "destination": "/apps/shell/dist/\$1" },
    { "source": "/", "destination": "/apps/shell/dist/index.html" }
  ]
}
EOF

# ---------------------------------------------------
# 10. Docker & Nginx (AWS / Bamboo / JFrog)
# ---------------------------------------------------

# Create a separate folder for deployment artifacts
mkdir -p deployment
cat <<EOF > deployment/nginx.conf
server {
    listen 80;
    
    # Standard SPA Shell
    location / {
        root /usr/share/nginx/html/shell;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }

    # MFE1 Subpath
    location /mfe1/ {
        alias /usr/share/nginx/html/mfe1/;
        index index.html;
        try_files \$uri \$uri/ /mfe1/index.html;
    }

    # MFE2 Subpath
    location /mfe2/ {
        alias /usr/share/nginx/html/mfe2/;
        index index.html;
        try_files \$uri \$uri/ /mfe2/index.html;
    }
}
EOF

cat <<EOF > Dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
RUN npm install -g pnpm@10.28.0
WORKDIR /app
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm build

# Stage 2: Serve
FROM nginx:stable-alpine
# Copy Shell
COPY --from=builder /app/apps/shell/dist /usr/share/nginx/html/shell
# Copy MFEs
COPY --from=builder /app/apps/mfe-apps/mfe1/dist /usr/share/nginx/html/mfe1
COPY --from=builder /app/apps/mfe-apps/mfe2/dist /usr/share/nginx/html/mfe2
# Custom Nginx Config
COPY deployment/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# ---------------------------------------------------
# 11. Completion
# ---------------------------------------------------

pnpm install
echo "✅ Hardened Setup Complete!"
echo "🐳 For AWS: Run 'docker build -t mfe-app .'"
echo "☁️ For Vercel: Just push to GitHub; vercel.json will handle the rest."

# ---------------------------------------------------
# 12. Install dependencies
# ---------------------------------------------------

echo "✅ Setup complete!"
echo "🚀 To start your app preview, run:"
echo "cd $APP_NAME && pnpm run local:preview"

