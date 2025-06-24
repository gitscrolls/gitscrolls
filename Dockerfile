FROM node:20-alpine

WORKDIR /app

# Install bash and git (needed for GitScrolls validation scripts)
RUN apk add --no-cache bash git

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --frozen-lockfile

# Copy test files
COPY . .

# Default command
CMD ["npm", "run", "in_docker:test"]