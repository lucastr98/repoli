#!/bin/bash

# Quick start script for Repoli

echo "🍳 Starting Repoli..."
echo ""

# Start backend
echo "📦 Starting backend server..."
cd backend
cargo run &
BACKEND_PID=$!
cd ..

echo "⏳ Waiting for backend to be ready..."
sleep 3

# Start frontend
echo "🎨 Starting frontend..."
cd frontend
flutter run -d chrome &
FRONTEND_PID=$!
cd ..

echo ""
echo "✅ Repoli is running!"
echo "   Backend:  http://localhost:3000"
echo "   Frontend: Opening in browser..."
echo ""
echo "Press Ctrl+C to stop both services"

# Wait for Ctrl+C
trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT
wait
