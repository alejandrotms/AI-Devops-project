FROM node:18-alpine AS deps
WORKDIR /app

# Copy package files and install production dependencies reproducibly
COPY package*.json ./
RUN npm ci --omit=dev

FROM node:18-alpine
WORKDIR /app

# Copy only production node_modules from the deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy application files
COPY . .

ENV NODE_ENV=production
EXPOSE 3000

USER node

CMD ["node", "index.js"]