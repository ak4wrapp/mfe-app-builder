export default function getRemotes(env: Record<string, string>) {
  const mfe1: string = env.VITE_MFE1_URL;
  const mfe2: string = env.VITE_MFE2_URL;

  console.log("Configured Remotes - mfe1:", mfe1);
  console.log("Configured Remotes - mfe2:", mfe2);
  return {
    mfe1: mfe1,
    mfe2: mfe2,
  };
}
