import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import federation from '@originjs/vite-plugin-federation'

export default defineConfig(({ mode }) => ({
  // Use '/' for dev, '/mfe1/' or '/mfe2/' for production
  base: mode === 'production' ? '/mfe1/' : '/',
  plugins: [
    react(),
    federation({
      name: 'mfe1',
      filename: 'remoteEntry.js',
      exposes: { './App': './src/App.tsx' },
      shared: ['react', 'react-dom']
    })
  ],
  build: { target: 'esnext', minify: false, cssCodeSplit: false }
}))
