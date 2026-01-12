#!/bin/bash
set -e

APP_NAME="${1:-my-mfe-app}"

if [[ ! -d "$APP_NAME" ]]; then
  echo ""
  echo "❌ Setup not found for '$APP_NAME'"
  echo "ℹ️  Please run the setup first:"
  echo "   ./setup.sh $APP_NAME"
  echo ""
  exit 1
fi

echo ""
echo "✅ Found setup for '$APP_NAME'"
echo "🚀 Setting up Vercel..."
echo ""

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
  "rewrites": [{ "source": "/$NAME/(.*)", "destination": "/\$1" }]
}
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