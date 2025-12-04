# View all logs
docker compose -f task2-docker-compose.yaml logs

# Follow all logs in real-time
docker compose -f task2-docker-compose.yaml logs -f

# View specific container logs
docker compose -f task2-docker-compose.yaml logs namenode
docker compose -f task2-docker-compose.yaml logs hive-server
docker compose -f task2-docker-compose.yaml logs spark-master

# Follow specific container logs
docker compose -f task2-docker-compose.yaml logs -f namenode

# View last N lines
docker compose -f task2-docker-compose.yaml logs --tail=100 namenode

# View multiple specific containers
docker compose -f task2-docker-compose.yaml logs namenode datanode

# View logs with timestamps
docker compose -f task2-docker-compose.yaml logs -t namenode