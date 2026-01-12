1. create vercel.json for mfe apps

vercel.json
{
"rewrites": [
{ "source": "/mfe2/(.*)", "destination": "/$1" }
]
}

2. create shell/microfrontends.json
3. update shell.version.json
