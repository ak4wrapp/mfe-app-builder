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
