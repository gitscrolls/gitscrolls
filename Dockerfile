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

# Configure git to trust the /app directory
RUN git config --global --add safe.directory /app

# Default command
CMD ["npm", "run", "in_docker:test"]