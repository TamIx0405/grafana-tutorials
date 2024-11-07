1. **Set up a simple Express server**.
2. **Simulate some time-series data**.
3. **Expose an endpoint to expose the data** (as a Prometheus-compatible format).
4. **Configure Grafana** to visualize this data.

### Step 1: Set up Express and Install Required Packages

First, make sure you have Node.js installed. Then, initialize a new project and install the required dependencies:

```bash
mkdir express-grafana
cd express-grafana
npm init -y
npm install express prom-client
```

- **express**: For the web server.
- **prom-client**: For exposing metrics in a Prometheus-compatible format.

### Step 2: Create the Express Server

Now, let's create a simple `index.js` file for the Express server.

#### `index.js`

```javascript
const express = require('express');
const promClient = require('prom-client');

const app = express();
const port = 3000;

// Create a registry to collect metrics
const register = new promClient.Registry();

// Define a metric to track a simple counter
const counter = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
});

// Define a metric for simulating a random temperature reading (as a gauge)
const temperatureGauge = new promClient.Gauge({
  name: 'random_temperature_celsius',
  help: 'Simulated random temperature reading in Celsius',
});

// Register the metrics
register.registerMetric(counter);
register.registerMetric(temperatureGauge);

// Simulate random temperature readings every 5 seconds
setInterval(() => {
  const temperature = (Math.random() * 10) + 20; // Random temp between 20 and 30 degrees
  temperatureGauge.set(temperature);
}, 5000);

// Simulate incoming HTTP requests to increment the counter
app.use((req, res, next) => {
  counter.inc(); // Increment the counter on every request
  next();
});

// Expose the metrics at the /metrics endpoint (Prometheus scrape endpoint)
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.send(await register.metrics());
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
```

### What this code does:
- **Metrics**: We are creating two metrics: one is a counter (`http_requests_total`) that increments every time the server is hit, and the other is a gauge (`random_temperature_celsius`) that simulates random temperature readings.
- **Prometheus Exposure**: The `/metrics` endpoint will expose these metrics in a format that Prometheus (and Grafana) can read.
- **Simulated Data**: Every 5 seconds, we generate a random temperature reading between 20-30°C.

### Step 3: Run the Express Server

Now, run the server:

```bash
node index.js
```

This will start your server at `http://localhost:3000`, and the metrics will be available at `http://localhost:3000/metrics`.

### Step 4: Set Up Grafana

To visualize this data with Grafana, you'll need to have **Prometheus** running as the data source for Grafana.

#### 4.1: Install Prometheus

If you don't have Prometheus installed, you can download it from [here](https://prometheus.io/download/). 

After installing Prometheus, create a `prometheus.yml` configuration file:

```yaml
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: 'nodejs-metrics'
    static_configs:
      - targets: ['localhost:3000'] # The Express app exposing metrics
```

Then run Prometheus with the configuration file:

```bash
prometheus --config.file=prometheus.yml
```

Prometheus will now scrape the metrics from your Express app every 10 seconds.

#### 4.2: Set Up Grafana

If you don't have Grafana installed, download it from [here](https://grafana.com/get). Once installed, you can start Grafana:

```bash
# Start Grafana (this might vary depending on your installation method)
grafana-server web
```

By default, Grafana will be available at `http://localhost:3000`. Log in with the default credentials (username: `admin`, password: `admin`).

#### 4.3: Configure Prometheus as a Data Source in Grafana

1. Open Grafana in your browser (`http://localhost:3000`).
2. Go to **Configuration** (the gear icon) > **Data Sources**.
3. Click **Add Data Source** and select **Prometheus**.
4. In the **URL** field, enter `http://localhost:9090` (this is where Prometheus is running by default).
5. Click **Save & Test**.

#### 4.4: Create a Dashboard in Grafana

1. Go to **Create** (the plus icon) > **Dashboard**.
2. Click **Add new panel**.
3. In the **Query** section, choose **Prometheus** as the data source.
4. To visualize the HTTP requests counter, use the query `http_requests_total` (or type it and Grafana will suggest it).
5. To visualize the simulated temperature gauge, use the query `random_temperature_celsius`.
6. Customize the visualization settings to your preference.
7. Click **Apply** to save the panel.

Now, you should see a graph that visualizes the data from your Node.js app!

### Step 5: View the Results

- **Prometheus** is scraping the data every 10 seconds from your Express app.
- **Grafana** will display this data as a graph, updating in real-time.

### Example Queries for Grafana:

- **HTTP requests total**: `http_requests_total`
- **Simulated temperature**: `random_temperature_celsius`

### Conclusion

In this example, you’ve set up:
- A simple **Express app** exposing Prometheus-compatible metrics.
- **Prometheus** scraping those metrics.
- **Grafana** visualizing the data in real-time.

This is a simple introduction to using Grafana with an Express app. You can expand this by adding more metrics, creating more complex dashboards, and integrating alerts in Grafana.
