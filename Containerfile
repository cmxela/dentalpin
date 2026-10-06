# Thinkube build of the DentalPin frontend. Same steps as
# frontend/Dockerfile.prod, on the base images the cluster registry mirrors.
# The context is the repository root: the build bakes every module layer
# from backend/app/modules.
ARG CONTAINER_REGISTRY
FROM ${CONTAINER_REGISTRY}/library/node:22-alpine AS builder

WORKDIR /app

COPY frontend/package*.json ./
RUN npm ci --no-audit --no-fund

COPY backend/app/modules /module_layers

COPY frontend/ ./

# Ship every module layer; the backend's /modules/-/active decides at run
# time which ones are visible.
RUN node scripts/modules-json.mjs /module_layers

# The build keeps each Vite stage's module graph until the end, about 3GB
# before Nitro starts; the heap fits the 8Gi build pod (buildSize: medium).
ENV NODE_OPTIONS="--max-old-space-size=6144"
RUN npm run build


ARG CONTAINER_REGISTRY
FROM ${CONTAINER_REGISTRY}/library/node:22-alpine

USER node

WORKDIR /app

COPY --from=builder /app/.output /app/.output
COPY --chmod=755 frontend/thinkube-entrypoint.sh /app/thinkube-entrypoint.sh

ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=3000

EXPOSE 3000

CMD ["/app/thinkube-entrypoint.sh"]
