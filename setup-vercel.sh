#!/bin/bash
set -e

APP_NAME="${1:-my-mfe-app}"
echo "🚀 Settin up vercel for $APP_NAME..."

cd $APP_NAME
# ---------------------------------------------------
# 1. Shell Vercel Configuration
# ---------------------------------------------------
cat <<EOF > apps/shell/vercel.json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
EOF

# ---------------------------------------------------
# 2. Micro-frontend applications Vercel Configuration
# ---------------------------------------------------

versel_for_mfe () {
  NAME=$1

cat <<EOF > apps/mfe-apps/$NAME/vercel.json
{
"rewrites": [{ "source": "/$NAME/(.*)", "destination": "/index.html"}]}
EOF
}

versel_for_mfe mfe1
versel_for_mfe mfe2

# ---------------------------------------------------
# 3. Completion
# ---------------------------------------------------

cat <<'EOF'

✅  Vercel Setup Complete!

☁️  Deployment Instructions:
────────────────────────────
• Push your code to GitHub
• Create Vercel projects for:
  - shell
  - each MFE application
• Make sure to select the correct root folder for each project

Happy deploying 🚀

EOF