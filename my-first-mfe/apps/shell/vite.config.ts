import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";
import federation from "@originjs/vite-plugin-federation";

export default defineConfig(({ mode }) => {
  console.log("Vite mode:", mode);
  const env = loadEnv(mode, process.cwd(), "");
  console.log("Loaded env variables:");
  console.log(`VITE_MFE1_URL: ${env.VITE_MFE1_URL || "Not found"}`);
  console.log(`VITE_MFE2_URL: ${env.VITE_MFE2_URL || "Not found"}`);

  return {
    plugins: [
      react(),
      federation({
        name: "shell",
        remotes: {
          mfe1: `${env.VITE_MFE1_URL}`,
          mfe2: `${env.VITE_MFE2_URL}`,
        },
        shared: ["react", "react-dom"],
      }),
    ],
  };
});
