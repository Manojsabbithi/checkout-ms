# ------------------------- Builder Stage -------------------------
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# ✅ Use Build Arguments for Next.js (Bundled at build time)
ARG NEXT_PUBLIC_API_BASE_URL
ENV NEXT_PUBLIC_API_BASE_URL=$NEXT_PUBLIC_API_BASE_URL

RUN npm run build


# ------------------------- Runtime Stage -------------------------
FROM node:18-alpine

WORKDIR /app

COPY --from=builder /app ./

EXPOSE 3000
CMD ["npm", "start"]
