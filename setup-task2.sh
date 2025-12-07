#!/bin/bash

# =============================================================================
# Task 2 Environment Setup Script
# =============================================================================

echo "=========================================="
echo "Task 2 - Data Analysis Environment Setup"
echo "=========================================="
echo ""

# Create required directories
echo "Creating required directories..."
mkdir -p data
mkdir -p resources
mkdir -p mapreduce-jars
mkdir -p hive-scripts
mkdir -p spark-scripts

echo "✓ Directories created successfully"
echo ""

# Check if Docker is running
echo "Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
    echo "✗ Docker is not running. Please start Docker Desktop first."
    exit 1
fi
echo "✓ Docker is running"
echo ""

# Copy data files from artifacts
echo "Copying data files..."
if [ -f "artifacts/locationData.csv" ] && [ -f "artifacts/weatherData.csv" ]; then
    cp artifacts/locationData.csv data/
    cp artifacts/weatherData.csv data/
    echo "✓ Data files copied successfully"
else
    echo "⚠ Warning: Data files not found in artifacts/ directory"
fi
echo ""

# Copy Hive scripts from task2
echo "Copying Hive scripts..."
if [ -d "task2" ]; then
    cp task2/*.hql hive-scripts/ 2>/dev/null
    echo "✓ Hive scripts copied successfully"
else
    echo "⚠ Warning: task2/ directory not found"
fi
echo ""

# Copy Spark scripts from task3
echo "Copying Spark scripts..."
if [ -d "task3" ]; then
    cp task3/*.py spark-scripts/ 2>/dev/null
    echo "✓ Spark scripts copied successfully"
else
    echo "⚠ Warning: task3/ directory not found"
fi
echo ""

# Copy MapReduce JARs from task1 (if available)
echo "Checking for MapReduce JARs..."
if [ -f "task1/BigDataProject-1.0-SNAPSHOT.jar" ]; then
    cp task1/*.jar mapreduce-jars/ 2>/dev/null
    echo "✓ MapReduce JARs copied successfully"
else
    echo "⚠ Warning: MapReduce JAR not found in task1/"
    echo "  Place JAR files manually in mapreduce-jars/ if needed"
fi
echo ""

# Display next steps
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Files copied:"
echo "  - CSV data files → data/"
echo "  - Hive scripts → hive-scripts/"
echo "  - Spark scripts → spark-scripts/"
echo "  - MapReduce JARs → mapreduce-jars/ (if available)"
echo ""
echo "To start the environment:"
echo "  docker-compose -f task2-docker-compose.yaml up -d"
echo ""
echo "To view service status:"
echo "  docker-compose -f task2-docker-compose.yaml ps"
echo ""
echo "For more information, see TASK2-README.md"
echo ""