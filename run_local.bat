@echo off
setlocal

echo [94mStarting DataForge Development Environment[0m

:: Check if Docker is running
docker info > nul 2>&1
if errorlevel 1 (
    echo [91mDocker is not running. Please start Docker first.[0m
    exit /b 1
)

:: Create Python virtual environment if it doesn't exist
if not exist venv (
    echo [94mCreating Python virtual environment...[0m
    python -m venv venv
)

:: Activate virtual environment
call venv\Scripts\activate.bat

:: Install Python dependencies
echo [94mInstalling Python dependencies...[0m
pip install -r requirements.txt

:: Install frontend dependencies
echo [94mInstalling frontend dependencies...[0m
cd frontend
call npm install
cd ..

:: Start Docker services
echo [94mStarting Docker services...[0m
docker-compose up -d

:: Wait for services to be ready
echo [94mWaiting for services to be ready...[0m
timeout /t 10 /nobreak > nul

:: Start backend API
echo [94mStarting backend API...[0m
start /B cmd /c "venv\Scripts\uvicorn.exe dataforge.api:app --reload --host 0.0.0.0 --port 8000"

:: Start frontend development server
echo [94mStarting frontend development server...[0m
cd frontend
start /B cmd /c "npm start"
cd ..

echo [92mDataForge is running![0m
echo [92mAPI: http://localhost:8000[0m
echo [92mFrontend: http://localhost:3000[0m
echo [92mAPI Documentation: http://localhost:8000/docs[0m
echo [94mPress Ctrl+C to stop all services[0m

:: Keep the script running
pause > nul

:: Cleanup on exit
echo [94mShutting down services...[0m
docker-compose down
taskkill /F /IM "node.exe" > nul 2>&1
taskkill /F /IM "uvicorn.exe" > nul 2>&1
deactivate

echo [92mAll services stopped[0m 