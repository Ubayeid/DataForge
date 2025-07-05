#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Starting DataForge Development Environment${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

# Create Python virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo -e "${BLUE}Creating Python virtual environment...${NC}"
    python -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install Python dependencies
echo -e "${BLUE}Installing Python dependencies...${NC}"
pip install -r requirements.txt

# Install frontend dependencies
echo -e "${BLUE}Installing frontend dependencies...${NC}"
cd frontend
npm install
cd ..

# Start Docker services
echo -e "${BLUE}Starting Docker services...${NC}"
docker-compose up -d

# Wait for services to be ready
echo -e "${BLUE}Waiting for services to be ready...${NC}"
sleep 10

# Start backend API (in background)
echo -e "${BLUE}Starting backend API...${NC}"
uvicorn dataforge.api:app --reload --host 0.0.0.0 --port 8000 &
API_PID=$!

# Start frontend development server (in background)
echo -e "${BLUE}Starting frontend development server...${NC}"
cd frontend
npm start &
FRONTEND_PID=$!
cd ..

# Function to cleanup processes on exit
cleanup() {
    echo -e "${BLUE}Shutting down services...${NC}"
    kill $API_PID
    kill $FRONTEND_PID
    docker-compose down
    deactivate
    echo -e "${GREEN}All services stopped${NC}"
}

# Register cleanup function
trap cleanup EXIT

echo -e "${GREEN}DataForge is running!${NC}"
echo -e "${GREEN}API: http://localhost:8000${NC}"
echo -e "${GREEN}Frontend: http://localhost:3000${NC}"
echo -e "${GREEN}API Documentation: http://localhost:8000/docs${NC}"
echo -e "${BLUE}Press Ctrl+C to stop all services${NC}"

# Wait for user input
read -r 