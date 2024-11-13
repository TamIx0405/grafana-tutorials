### Overview of Components:
1. **Express app** will generate logs.
2. **Promtail** will collect logs from the Express app and send them to **Loki**.
3. **Loki** will store the logs, and **Grafana** will be used to query and visualize them.

### Step 1: Set up the Express app

We will use a simple Express app that generates logs, and Promtail will collect these logs.

First, make sure you have `express` installed:

```bash
mkdir express-logs
cd express-logs
npm init -y
npm install express morgan
```

- **express**: Web framework for the Node.js app.
- **morgan**: HTTP request logger middleware for Node.js.

Now, create the `index.js` file for the Express app.

#### `index.js`

```javascript
const express = require('express');
const morgan = require('morgan');
const path = require('path');
const fs = require('fs');

const app = express();
const port = 3000;

const accessLogStream = fs.createWriteStream(
  path.join(__dirname, 'logs', 'access.log'), 
  { flags: 'a' });

// Set up morgan to log requests in 'combined' format (common log format)
app.use(morgan('combined', { stream: accessLogStream }));

app.get('/', (req, res) => {
  res.send('Hello, world!');
});

app.get('/error', (req, res) => {
  throw new Error('Something went wrong!');
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});

```

### What this does:
- We use **morgan** middleware to log incoming HTTP requests in the **combined** format. This format includes information such as the request method, URL, status code, and response time.
- There’s also a route `/error` that throws an error to test logging of error messages.

### Step 2: Set Up Promtail to Ship Logs

Promtail is an agent that reads log files and ships them to Loki. It’s very useful for tailing log files in real-time.

#### 2.1 Install Promtail

You can download **Promtail** from the [Loki GitHub releases](https://github.com/grafana/loki/releases). Choose the appropriate version for your operating system.

#### 2.2 Configure Promtail

Create a configuration file for **Promtail**. Let’s call it `promtail-config.yml`:

#### `promtail-config.yml`

```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

clients:
  - url: "http://localhost:3100/loki/api/v1/push"  # Loki endpoint

positions:
  filename: /tmp/positions.yaml  # Position file to track log reading state

scrape_configs:
  - job_name: 'express-logs'
    static_configs:
      - targets:
          - localhost
        labels:
          job: "express-logs"
          __path__: /path/to/your/logs/*.log  # Path to logs
```

#### Explanation:
- **server**: Defines the ports Promtail uses.
- **clients**: Specifies where to push the logs to (in this case, a local Loki instance running on port `3100`).
- **positions**: A file where Promtail stores the positions of logs that have been read to ensure it can continue where it left off.
- **scrape_configs**: Defines how Promtail will find and ship the logs. It’s configured to scrape the logs from files that match `/path/to/your/logs/*.log`.

Now, we need to tell Promtail where your logs are located. In our case, the logs are coming from **morgan** in the Express app, and they can be piped into a file.

To do this, modify the `index.js` to log to a file.

#### Modify `index.js` to Log to a File:

Install **winston** or **fs** to log to a file:

```bash
npm install winston
```

Modify `index.js` to log to a file:

#### Updated `index.js`

```javascript
const express = require('express');
const morgan = require('morgan');
const winston = require('winston');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;

// Create a log file stream
const logStream = fs.createWriteStream(path.join(__dirname, 'app.log'), { flags: 'a' });

// Set up morgan to log requests to a file
app.use(morgan('combined', { stream: logStream }));

app.get('/', (req, res) => {
  res.send('Hello, world!');
});

app.get('/error', (req, res) => {
  throw new Error('Something went wrong!');
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
```

In this case, we're logging HTTP requests to a file called `app.log` in the root directory of the app.

### Step 3: Install and Run Loki

#### 3.1: Install Loki

Download the latest release of **Loki** from [here](https://github.com/grafana/loki/releases) and start it by running:

```bash
loki -config.file=loki-config.yml
```

You'll need a configuration file for Loki as well. Here’s a simple `loki-config.yml` file:

#### `loki-config.yml`

```yaml
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

ingester:
  wal:
    dir: /tmp/wal

storage_config:
  boltdb_shipper:
    active_index_directory: /tmp/loki/index
    cache_location: /tmp/loki/cache

chunk_store_config:
  boltdb_shipper:
    active_index_directory: /tmp/loki/index
    cache_location: /tmp/loki/cache

compactor:
  compaction_retention_enabled: true

limits_config:
  max_log_line_size: 1048576
```

#### 3.2: Start Loki

Start **Loki** using this config file:

```bash
loki -config.file=loki-config.yml
```

### Step 4: Install and Run Grafana

If you don’t have Grafana installed yet, download it from [Grafana's website](https://grafana.com/get) and install it.

Start Grafana:

```bash
# Start Grafana (default port 3000)
grafana-server web
```

### Step 5: Configure Grafana to Use Loki

1. Open **Grafana** at `http://localhost:3000` (default credentials are `admin/admin`).
2. Click on the gear icon in the left menu and go to **Data Sources**.
3. Click **Add data source** and select **Loki**.
4. Set the URL to `http://localhost:3100` (where Loki is running).
5. Click **Save & Test** to verify the connection.

### Step 6: Create a Dashboard in Grafana to View Logs

1. Go to **Create** (the plus icon) > **Dashboard**.
2. Click **Add new panel**.
3. In the **Query** section, select **Loki** as the data source.
4. Use a simple query to view logs, e.g., `{job="express-logs"}`.
5. You can further filter by log level, error messages, or any other labels you define.

### Step 7: View Logs in Grafana

You should now see the logs being displayed in the panel. Grafana will show the logs coming from Loki, and you can filter, query, and visualize them in various ways.

### Conclusion

This setup involves:
- **Express app**: Generates logs using **morgan**, which are written to `app.log`.
- **Promtail**: Ships these logs to **Loki**.
- **Loki**: Stores the logs.
- **Grafana**: Displays the logs in real-time.

You can now view and query logs in Grafana, filter by labels, and use Grafana's powerful dashboarding features to monitor logs over time.
