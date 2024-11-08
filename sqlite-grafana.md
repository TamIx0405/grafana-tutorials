## Plugin
Datasource Plugin: https://grafana.com/grafana/plugins/frser-sqlite-datasource/

Great to hear that you found a plugin that works for SQLite in Grafana! If you're looking for some **sample data** to seed your SQLite database for a demo, here's a simple process you can follow to generate and load data into your SQLite database:

### 1. **Create a Sample SQLite Database**

First, you’ll need to create a SQLite database (if you haven't already) and set up a table. Below is a basic example of how to create a table for storing time-series data:

```sql
-- Create a database (e.g., `demo.db`)
sqlite3 demo.db

-- Create a table to store time-series data
CREATE TABLE metrics (
    timestamp INTEGER PRIMARY KEY,
    metric_name TEXT,
    value REAL
);

-- Insert some sample data into the table
INSERT INTO metrics (timestamp, metric_name, value) VALUES
(1637280000, 'cpu_usage', 45.6),
(1637283600, 'cpu_usage', 48.2),
(1637287200, 'cpu_usage', 50.1),
(1637290800, 'cpu_usage', 55.3),
(1637294400, 'cpu_usage', 53.4),
(1637298000, 'cpu_usage', 47.0),
(1637301600, 'memory_usage', 65.2),
(1637305200, 'memory_usage', 63.8),
(1637308800, 'memory_usage', 60.5),
(1637312400, 'memory_usage', 62.1);

-- Check the data
SELECT * FROM metrics;
```

This will create a table `metrics` with a timestamp (UNIX epoch format), a metric name (`cpu_usage` or `memory_usage`), and the value associated with that metric.

### 2. **Generating More Data for the Demo**

To populate your SQLite database with more data, you can create a script that inserts data with varying timestamps. Below is a simple Python script that can generate more data for demo purposes:

```python
import sqlite3
import random
import time

# Connect to SQLite database
conn = sqlite3.connect('demo.db')
cursor = conn.cursor()

# Insert synthetic data
for i in range(1000):
    timestamp = int(time.time()) - (i * 3600)  # Subtract hours to generate past timestamps
    metric_name = random.choice(['cpu_usage', 'memory_usage', 'disk_io'])
    value = random.uniform(30.0, 90.0)  # Random value between 30 and 90
    cursor.execute("INSERT INTO metrics (timestamp, metric_name, value) VALUES (?, ?, ?)", 
                   (timestamp, metric_name, value))

# Commit and close connection
conn.commit()
conn.close()

print("Data seeding complete!")
```

This script will insert 1,000 data points with random values and timestamps spread across the last 1,000 hours. You can adjust the values and frequency to suit your demo needs.

### 3. **Use the Data in Grafana**

Once you’ve populated your SQLite database with data:

1. **Configure the SQLite Plugin** in Grafana as a data source.
2. **Create a New Dashboard** in Grafana and start adding panels.
3. For example, if you want to visualize the `cpu_usage` over time, you can create a query like this:

```sql
SELECT timestamp, value FROM metrics WHERE metric_name = 'cpu_usage' ORDER BY timestamp DESC LIMIT 100
```

You can then use Grafana's panel options to configure the visualization (e.g., time series graph, bar chart, etc.).

### 4. **Additional Example Data**

If you need more complex data, such as different types of metrics or variations over time, here’s another example you can use to seed a `sensor_data` table with different sensor types and values:

```sql
-- Create a table for sensor data
CREATE TABLE sensor_data (
    timestamp INTEGER PRIMARY KEY,
    sensor_id TEXT,
    temperature REAL,
    humidity REAL
);

-- Insert sample data
INSERT INTO sensor_data (timestamp, sensor_id, temperature, humidity) VALUES
(1637280000, 'sensor_1', 22.5, 45.0),
(1637283600, 'sensor_1', 23.0, 46.2),
(1637287200, 'sensor_2', 19.5, 50.0),
(1637290800, 'sensor_2', 20.3, 48.9),
(1637294400, 'sensor_3', 25.0, 40.3);
```

This will create a table `sensor_data` where each row contains a timestamp, a sensor ID, temperature, and humidity readings.

### 5. **Viewing in Grafana**

With this structure, you can create Grafana queries like:

```sql
SELECT timestamp, temperature FROM sensor_data WHERE sensor_id = 'sensor_1' ORDER BY timestamp DESC LIMIT 100
```

This will show you a temperature trend for `sensor_1`. Similarly, you can query for humidity or other metrics.

---

Feel free to modify the example data as needed. This should provide you with enough data to create various types of visualizations in Grafana!
