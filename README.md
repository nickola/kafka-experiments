# Kafka Experiments

Different Kafka experiments.

# ksqlDB Streams and Tables

Start Kafka with ksqlDB in Docker Compose:

```shell
docker-compose up
```

In a new shell window create `test` topic in Kafka:

```shell
docker-compose exec kafka kafka-topics --bootstrap-server kafka:19092 --create --topic test
docker-compose exec kafka kafka-topics --bootstrap-server kafka:19092 --list
...
test
```

Connect to the ksqlDB CLI:

```shell
docker-compose exec ksqldb-cli ksql http://ksqldb-server:8088
ksql>
```

Create a stream from `test` topic:

```sql
ksql> CREATE STREAM test_stream (id BIGINT, name VARCHAR, price DOUBLE) WITH (KAFKA_TOPIC='test', VALUE_FORMAT='JSON');
...
Stream created

ksql> SHOW STREAMS;

 Stream Name | Kafka Topic | Key Format | Value Format | Windowed
------------------------------------------------------------------
 ...         | ...         | ...        | ...          | ...
 TEST_STREAM | test        | KAFKA      | JSON         | false
```

Create a table from `test_stream` stream with `GROUP BY` and `LATEST_BY_OFFSET`:

```sql
ksql> CREATE TABLE test_table AS SELECT id, LATEST_BY_OFFSET(name) AS name, LATEST_BY_OFFSET(price) AS price FROM test_stream GROUP BY id;
...
Created query with ID ...

ksql> SHOW TABLES;

 Table Name | Kafka Topic | Key Format | Value Format | Windowed
-----------------------------------------------------------------
 ...        | ...         | ...        | ...          | ...
 TEST_TABLE | TEST_TABLE  | KAFKA      | JSON         | false
```

Produce some messages (in `JSON` format):

```sql
docker-compose exec kafka kafka-console-producer --bootstrap-server kafka:19092 --topic test

>{"id": 1, "name": "Name 1", "price": 10}
>{"id": 1, "name": "Name 11", "price": 11}
>{"id": 2, "name": "Name 2", "price": 20}
>{"id": 2, "name": "Name 22", "price": 22}
>{"id": 3, "name": "Name 3", "price": 30}
```

Select data from the `test_stream` stream (you will see all messages):

```sql
ksql> SELECT * FROM test_stream;

+----+---------+-------+
| ID | NAME    | PRICE |
+----+---------+-------+
| 1  | Name 1  | 10.0  |
| 1  | Name 11 | 11.0  |
| 2  | Name 2  | 20.0  |
| 2  | Name 22 | 22.0  |
| 3  | Name 3  | 30.0  |
```

Select data from `test_table` table (you will see `LATEST_BY_OFFSET` messages):

```sql
ksql> SELECT * FROM test_table;

+----+---------+-------+
| ID | NAME    | PRICE |
+----+---------+-------+
| 1  | Name 11 | 11.0  |
| 2  | Name 22 | 22.0  |
| 3  | Name 3  | 30.0  |
```
