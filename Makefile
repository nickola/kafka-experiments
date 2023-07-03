# Do not print commands before executing
.SILENT:

# Targets are not files / directories ("all" - default target, invoked by simply executing "make")
.PHONY: all $(MAKECMDGOALS)

KAFKA_BOOTSTRAP_SERVER = "localhost:9092"
KAFKA_TOPIC = "test"

all: start

start:
	docker-compose up

stop:
	docker-compose down --volumes --remove-orphans

clean:
	docker-compose down --volumes --remove-orphans --rmi local

ksql-cli:
	docker-compose exec ksqldb-cli ksql http://ksqldb-server:8088

topic-list:
	kafka-topics.sh --bootstrap-server "${KAFKA_BOOTSTRAP_SERVER}" --list

topic-create:
	kafka-topics.sh --bootstrap-server "${KAFKA_BOOTSTRAP_SERVER}" --create --topic "${KAFKA_TOPIC}"

topic-delete:
	kafka-topics.sh --bootstrap-server "${KAFKA_BOOTSTRAP_SERVER}" --delete --topic "${KAFKA_TOPIC}"

topic-produce:
	echo '{"id": 1, "name": "Name 1", "price": 10}' | kafka-console-producer.sh --bootstrap-server "${KAFKA_BOOTSTRAP_SERVER}" --topic "${KAFKA_TOPIC}"
	echo '{"id": 1, "name": "Name 11", "price": 11}' | kafka-console-producer.sh --bootstrap-server "${KAFKA_BOOTSTRAP_SERVER}" --topic "${KAFKA_TOPIC}"
	echo '{"id": 2, "name": "Name 2", "price": 20}' | kafka-console-producer.sh --bootstrap-server "${KAFKA_BOOTSTRAP_SERVER}" --topic "${KAFKA_TOPIC}"
	echo '{"id": 2, "name": "Name 22", "price": 22}' | kafka-console-producer.sh --bootstrap-server "${KAFKA_BOOTSTRAP_SERVER}" --topic "${KAFKA_TOPIC}"
	echo '{"id": 3, "name": "Name 3", "price": 30}' | kafka-console-producer.sh --bootstrap-server "${KAFKA_BOOTSTRAP_SERVER}" --topic "${KAFKA_TOPIC}"

topic-consume:
	kafka-console-consumer.sh --bootstrap-server "${KAFKA_BOOTSTRAP_SERVER}" --topic "${KAFKA_TOPIC}" --from-beginning --formatter kafka.tools.DefaultMessageFormatter \
	                          --property print.timestamp=true --property print.partition=true --property print.key=true --property print.value=true
