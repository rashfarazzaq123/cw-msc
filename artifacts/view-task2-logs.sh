#!/bin/bash

# =============================================================================
# Task 2 - Log Viewing Script
# View logs for Task 2 Docker containers with various options
# =============================================================================

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMPOSE_FILE="task2-docker-compose.yaml"

# Display usage
usage() {
    echo "Task 2 - Log Viewing Tool"
    echo ""
    echo "Usage: $0 [OPTIONS] [CONTAINER]"
    echo ""
    echo "Options:"
    echo "  -f, --follow         Follow log output (live tail)"
    echo "  -n, --tail NUM       Show last NUM lines (default: 100)"
    echo "  -t, --timestamps     Show timestamps"
    echo "  -a, --all            Show logs for all containers"
    echo "  --hdfs               Show logs for HDFS containers (namenode, datanode)"
    echo "  --hive               Show logs for Hive containers"
    echo "  --spark              Show logs for Spark containers"
    echo "  --since TIME         Show logs since timestamp (e.g. 2023-01-01, 10m, 1h)"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Containers:"
    echo "  namenode                 HDFS NameNode"
    echo "  datanode                 HDFS DataNode"
    echo "  hive-metastore-postgresql  PostgreSQL for Hive"
    echo "  hive-metastore-init      Hive metastore initialization"
    echo "  hive-metastore           Hive Metastore Service"
    echo "  hive-server              HiveServer2"
    echo "  spark-master             Spark Master"
    echo "  spark-worker-1           Spark Worker 1"
    echo "  spark-worker-2           Spark Worker 2"
    echo ""
    echo "Examples:"
    echo "  $0 namenode              # Show last 100 lines of namenode logs"
    echo "  $0 -f namenode           # Follow namenode logs"
    echo "  $0 -n 50 hive-server     # Show last 50 lines of hive-server"
    echo "  $0 --hdfs                # Show logs for all HDFS containers"
    echo "  $0 -a                    # Show logs for all containers"
    echo "  $0 --since 10m spark-master  # Show spark-master logs from last 10 minutes"
}

# Check if docker-compose file exists
if [ ! -f "$COMPOSE_FILE" ]; then
    echo -e "${YELLOW}Error: $COMPOSE_FILE not found${NC}"
    echo "Please run this script from the directory containing $COMPOSE_FILE"
    exit 1
fi

# Parse arguments
FOLLOW=""
TAIL="--tail=100"
TIMESTAMPS=""
CONTAINERS=""
SINCE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--follow)
            FOLLOW="-f"
            shift
            ;;
        -n|--tail)
            TAIL="--tail=$2"
            shift 2
            ;;
        -t|--timestamps)
            TIMESTAMPS="-t"
            shift
            ;;
        -a|--all)
            CONTAINERS=""
            shift
            ;;
        --hdfs)
            CONTAINERS="namenode datanode"
            shift
            ;;
        --hive)
            CONTAINERS="hive-metastore-postgresql hive-metastore-init hive-metastore hive-server"
            shift
            ;;
        --spark)
            CONTAINERS="spark-master spark-worker-1 spark-worker-2"
            shift
            ;;
        --since)
            SINCE="--since=$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            CONTAINERS="$CONTAINERS $1"
            shift
            ;;
    esac
done

# Build docker compose command
CMD="docker compose -f $COMPOSE_FILE logs $TIMESTAMPS $TAIL $SINCE $FOLLOW $CONTAINERS"

# Show what we're doing
if [ -z "$CONTAINERS" ]; then
    echo -e "${BLUE}Showing logs for all containers${NC}"
else
    echo -e "${BLUE}Showing logs for: $CONTAINERS${NC}"
fi

if [ -n "$FOLLOW" ]; then
    echo -e "${GREEN}Following logs (Ctrl+C to exit)${NC}"
fi

echo ""

# Execute command
$CMD
