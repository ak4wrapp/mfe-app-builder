vercel.json for mfe apps

vercel.json
{
"rewrites": [
{ "source": "/mfe2/(.*)", "destination": "/$1" }
]
}
