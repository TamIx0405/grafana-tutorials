### 1. **Install Loki**

Loki is a log aggregation system designed to work well with Prometheus and Grafana. You can install Loki on the same server as your Grafana instance or on a separate machine.

#### Steps to install Loki:

- **Download the Loki binary** from [Loki's releases page](https://github.com/grafana/loki/releases). For example, you can use:

    ```bash
    wget https://github.com/grafana/loki/releases/download/v2.9.0/loki-linux-amd64.zip
    unzip loki-linux-amd64.zip
    sudo mv loki-linux-amd64 /usr/local/bin/loki
    ```

- **Create a configuration file** for Loki. Here's a basic configuration (`loki-config.yaml`):

    ```yaml
    auth_enabled: false

    server:
      http_listen_port: 3100

    distributor:
      ring:
        kvstore:
          store: inmemory
        replication_factor: 1

    ingester:
      chunk_idle_period: 5m
      chunk_block_size: 5000000
      max_chunk_age: 1h
      throughput_limit: 1048576

    storage_config:
      boltdb_shipper:
        active_index_directory: /tmp/loki/index
        cache_location: /tmp/loki/cache
        shared_store: filesystem
      filesystem:
        directory: /tmp/loki/chunks

    limits_config:
      max_entries_limit: 500
      max_line_size: 4096
    ```

    This configuration is using the local filesystem for storage.

- **Start Loki**:

    ```bash
    nohup loki -config.file=loki-config.yaml &
    ```

    Make sure Loki starts without errors. You can check the logs to verify.

### 2. **Install Promtail**

Promtail is an agent that collects logs and ships them to Loki. You can install Promtail on the server that produces logs (in this case, your Nginx server).

#### Steps to install Promtail:

- **Download the Promtail binary** from [Promtail's releases page](https://github.com/grafana/loki/releases).

    ```bash
    wget https://github.com/grafana/loki/releases/download/v2.9.0/promtail-linux-amd64.zip
    unzip promtail-linux-amd64.zip
    sudo mv promtail-linux-amd64 /usr/local/bin/promtail
    ```

- **Create a configuration file** (`promtail-config.yaml`). A basic config might look like this:

    ```yaml
    server:
      http_listen_port: 9080
      grpc_listen_port: 0

    positions:
      filename: /tmp/positions.yaml

    clients:
      - url: http://<LOKI_SERVER_IP>:3100/loki/api/v1/push

    scrape_configs:
      - job_name: nginx
        static_configs:
          - targets:
              - localhost
            labels:
              job: nginx
              __path__: /var/log/nginx/*.log
    ```

    Replace `<LOKI_SERVER_IP>` with the IP address of the machine where Loki is running.

- **Start Promtail**:

    ```bash
    nohup promtail -config.file=promtail-config.yaml &
    ```

    Promtail will start shipping logs from `/var/log/nginx/*.log` (adjust the path if your Nginx logs are in a different location) to Loki.

### 3. **Configure Grafana**

Now that Loki and Promtail are set up, you can configure Grafana to visualize the logs.

#### Steps to configure Grafana:

- **Add Loki as a data source** in Grafana:
    1. Open your Grafana dashboard (`http://<grafana-ip>:3000`).
    2. Go to **Configuration** (the gear icon) > **Data Sources**.
    3. Click **Add data source** and choose **Loki**.
    4. In the **URL** field, enter the address of your Loki server, for example: `http://<LOKI_SERVER_IP>:3100`.
    5. Save and test the connection.

- **Create a Log Dashboard**:
    1. After adding Loki as a data source, go to **Create** > **Dashboard**.
    2. Add a **Panel** and select **Loki** as the data source.
    3. You can now use queries to retrieve logs, for example:

        ```text
        {job="nginx"}
        ```

        This will return all logs labeled with `job="nginx"` from your Promtail instance.

- **Configure your Nginx logs** to be parsed correctly:
    Make sure that your Nginx logs are structured in a way that they can be easily queried by Loki. You might want to make sure that your Nginx log format includes fields like `timestamp`, `log level`, `message`, etc.

    For example, set your Nginx log format in `nginx.conf`:

    ```nginx
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    ```

    This will create logs that contain relevant information for querying later.

### 4. **Verify the Setup**

- Once everything is running, you should be able to see logs in Grafana’s Explore section under **Loki** as the data source.
- You can use log queries like:

    ```text
    {job="nginx"}
    ```

    To filter logs from your Nginx server.

### 5. **Optional: Set Up Alerts**

You can set up alerts in Grafana for certain log patterns (e.g., errors, warnings, or specific status codes) to notify you of potential issues in your logs.

- Go to the panel where your logs are visualized.
- Set up an **Alert** using the **Thresholds** and **Conditions** based on the log values.

---

With this setup, you now have an Nginx server shipping logs to Loki via Promtail, and Grafana is visualizing these logs.
