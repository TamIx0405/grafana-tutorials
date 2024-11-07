# **Tutorial: Setting up Grafana on EC2 and Loki on Another EC2 Instance**

### **Overview**
We’ll deploy the following:
1. **Grafana** on one EC2 instance to visualize logs.
2. **Loki** on another EC2 instance to collect logs.
3. Configure Loki to send logs to Grafana for visualization.

---

### **Step 1: Set Up Grafana on EC2 Instance**

#### 1.1. Launch an EC2 Instance for Grafana
1. Go to your **AWS Management Console** and navigate to **EC2**.
2. Click on **Launch Instance**.
3. Select an **Amazon Linux 2 AMI** or a **Ubuntu** instance.
4. Choose an instance type (e.g., `t2.micro` for testing).
5. Configure your security group to allow:
   - **SSH (port 22)** from your IP for SSH access.
   - **HTTP (port 80)** and **HTTPS (port 443)** for accessing Grafana.
6. Review and launch the instance.

#### 1.2. SSH into Your EC2 Instance
Once the instance is running, SSH into it using the public IP address:

```bash
ssh -i /path/to/your-key.pem ec2-user@<EC2_PUBLIC_IP>
```

#### 1.3. Install Grafana on EC2

1. **Install Grafana:**
   For **Amazon Linux 2** (or **RHEL/CentOS**):
   ```bash
   sudo yum install -y https://dl.grafana.com/oss/release/grafana-8.7.3-1.x86_64.rpm
   ```

   For **Ubuntu**:
   ```bash
   sudo apt-get install -y software-properties-common
   sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
   sudo apt-get update
   sudo apt-get install grafana
   ```

2. **Start and Enable Grafana Service:**
   - Start Grafana:
     ```bash
     sudo systemctl start grafana-server
     ```
   - Enable Grafana to start on boot:
     ```bash
     sudo systemctl enable grafana-server
     ```

3. **Access Grafana:**
   Open your web browser and navigate to `http://<EC2_PUBLIC_IP>:3000`.
   - Default username: `admin`
   - Default password: `admin` (you will be prompted to change it on the first login).

---

### **Step 2: Set Up Loki on Another EC2 Instance**

#### 2.1. Launch Another EC2 Instance for Loki
1. Go to **EC2 Dashboard** and launch another EC2 instance for Loki (you can use an **Amazon Linux 2** or **Ubuntu** instance).
2. Allow SSH access from your IP and ensure **TCP port 3100** is open for Loki's HTTP API (you’ll configure Grafana to access Loki on this port).

#### 2.2. SSH into Your Loki EC2 Instance

SSH into the Loki instance:
```bash
ssh -i /path/to/your-key.pem ec2-user@<LOKI_EC2_PUBLIC_IP>
```

#### 2.3. Install Loki

1. **Install Loki:**
   Run the following commands to download and install Loki.
   
   For **Amazon Linux 2** (or **RHEL/CentOS**):
   ```bash
   sudo yum install -y wget
   wget https://github.com/grafana/loki/releases/download/v2.7.1/loki-linux-amd64.zip
   unzip loki-linux-amd64.zip
   sudo mv loki-linux-amd64 /usr/local/bin/loki
   ```

   For **Ubuntu**:
   ```bash
   wget https://github.com/grafana/loki/releases/download/v2.7.1/loki-linux-amd64.zip
   sudo apt-get install unzip
   unzip loki-linux-amd64.zip
   sudo mv loki-linux-amd64 /usr/local/bin/loki
   ```

2. **Create a Loki Configuration File:**
   You can use the default configuration or modify it as needed. For a basic setup, create a config file:
   ```bash
   sudo nano /etc/loki-config.yaml
   ```

   Add the following basic configuration (you can adjust the paths and settings as needed):
   ```yaml
   server:
     http_listen_port: 3100
   ingester:
     chunk_idle_period: 5m
     chunk_retain_period: 1h
     max_chunk_age: 1h
   storage_config:
     boltdb_shipper:
       active_index_directory: /tmp/loki/index
       cache_location: /tmp/loki/cache
     filesystem:
       directory: /tmp/loki/chunks
   ```

3. **Run Loki:**
   Start Loki using the following command:
   ```bash
   loki -config.file=/etc/loki-config.yaml
   ```

   Loki will start listening on port **3100**.

---

### **Step 3: Configure Grafana to Access Loki**

#### 3.1. Add Loki Data Source to Grafana

1. **Open Grafana** in your browser: `http://<GRAFANA_EC2_PUBLIC_IP>:3000`.
2. **Log in** with your credentials.
3. **Add Data Source:**
   - Click on the gear icon (⚙️) in the left sidebar and select **Data Sources**.
   - Click **Add data source**.
   - Select **Loki** from the list of available data sources.

4. **Configure Loki Data Source:**
   - **Name:** `Loki`
   - **URL:** `http://<LOKI_EC2_PUBLIC_IP>:3100` (Replace with the public IP of your Loki EC2 instance).
   - Click **Save & Test** to verify the connection.

#### 3.2. Verify Connection
Grafana will test the connection to Loki, and you should see a **"Data source is working"** message.

---

### **Step 4: Visualize Logs in Grafana**

#### 4.1. Create a Dashboard for Logs

1. **Create a New Dashboard:**
   - In Grafana, click the **+** icon in the sidebar and select **Dashboard**.
   - Click **Add Panel**.

2. **Configure the Panel for Logs:**
   - In the **Query** section, select **Loki** as the data source.
   - Use a simple query like `{job="varlogs"}` to view the logs. If you're using a different job or labels, adjust the query accordingly.
   
3. **Visualize Logs:**
   - Set the panel type to **Logs** to visualize the logs.

4. **Save the Dashboard:**
   - Click **Apply** to save the panel, then **Save Dashboard** with a name.

---

### **Step 5: Sending Logs to Loki from EC2 Instances**

To send logs from your EC2 instances to Loki, you'll need to use **Promtail**, an agent that ships logs to Loki. You can run Promtail on each EC2 instance to collect logs and send them to the Loki instance.

#### 5.1. Install Promtail

On each EC2 instance (including the Grafana instance if you want logs from it), do the following:

1. **Download Promtail**:
   ```bash
   wget https://github.com/grafana/loki/releases/download/v2.7.1/promtail-linux-amd64.zip
   unzip promtail-linux-amd64.zip
   sudo mv promtail-linux-amd64 /usr/local/bin/promtail
   ```

2. **Create a Promtail Configuration File**:
   Create a configuration file `/etc/promtail-config.yaml` with the following basic settings:
   ```yaml
   server:
     http_listen_port: 9080
   clients:
     - url: http://<LOKI_EC2_PUBLIC_IP>:3100/loki/api/v1/push
   positions:
     filename: /tmp/positions.yaml
   scrape_configs:
     - job_name: varlogs
       static_configs:
         - targets:
             - localhost
           labels:
             job: varlogs
             __path__: /var/log/*.log
   ```

3. **Run Promtail**:
   Start Promtail using the following command:
   ```bash
   promtail -config.file=/etc/promtail-config.yaml
   ```

   This will start sending logs from `/var/log/*.log` on your EC2 instance to Loki.

#### 5.2. Verify Logs in Grafana
Once Promtail is running and sending logs to Loki, return to Grafana and refresh the dashboard. You should start seeing logs from your EC2 instance!

---

### **Conclusion**

- **Grafana** is running on one EC2 instance, visualizing logs from Loki.
- **Loki** collects logs and sends them to Grafana.
- **Promtail** is used to ship logs to Loki from your EC2 instances.
