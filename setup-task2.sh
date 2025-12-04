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

# Create sample directories for organization
echo "Creating sample directory structure..."
mkdir -p hive-scripts/task2
mkdir -p spark-scripts/task2
mkdir -p mapreduce-jars/task2

echo "✓ Sample structure created"
echo ""

# Display next steps
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Place your weather dataset CSV files in the 'data/' directory"
echo "2. Place MapReduce JAR files in 'mapreduce-jars/' directory"
echo "3. Place Hive scripts in 'hive-scripts/' directory"
echo "4. Place Spark scripts in 'spark-scripts/' directory"
echo ""
echo "To start the environment:"
echo "  docker-compose -f task2-docker-compose.yaml up -d"
echo ""
echo "To view service status:"
echo "  docker-compose -f task2-docker-compose.yaml ps"
echo ""
echo "For more information, see TASK2-README.md"
echo ""