# **Tutorial: Setting up Grafana to Visualize Data from SQLite**

In this tutorial, we will:

1. Set up SQLite and populate it with sample data.
2. Configure Grafana to connect to the SQLite database.
3. Visualize the data in Grafana.

## **Step 1: Set Up SQLite and Load Sample Data**

### 1.1. Install SQLite (If Not Installed)
First, ensure that you have SQLite installed on your system.

- **For Windows:**
  Download the precompiled binaries from the official site: [SQLite Downloads](https://www.sqlite.org/download.html).

- **For Linux:**
  You can install it using your package manager, for example:
  ```bash
  sudo apt-get install sqlite3
  ```

- **For macOS:**
  You can install SQLite via Homebrew:
  ```bash
  brew install sqlite
  ```

### 1.2. Create a Sample Database and Table
Now, let's create a simple SQLite database and a table with some sample data.

1. Open the SQLite command-line tool:
   ```bash
   sqlite3 sample.db
   ```

2. Create a sample table for visualization:
   ```sql
   CREATE TABLE sales (
     id INTEGER PRIMARY KEY,
     product TEXT,
     amount INTEGER,
     date TEXT
   );
   ```

3. Insert some sample data:
   ```sql
   INSERT INTO sales (product, amount, date) VALUES
     ('Product A', 10, '2024-01-01'),
     ('Product B', 15, '2024-01-02'),
     ('Product A', 20, '2024-01-03'),
     ('Product C', 25, '2024-01-04'),
     ('Product B', 30, '2024-01-05');
   ```

4. Verify that the data is inserted correctly:
   ```sql
   SELECT * FROM sales;
   ```

5. Exit SQLite:
   ```sql
   .quit
   ```

You now have a database (`sample.db`) with a `sales` table containing sample sales data.

## **Step 2: Install Grafana and Configure SQLite Plugin**

### 2.1. Install Grafana (If Not Installed)
Follow the installation instructions for Grafana based on your platform.

- **For Windows:** Download the installer from [Grafana Downloads](https://grafana.com/grafana/download).
- **For Linux:** Install using the package manager, for example:
  ```bash
  sudo apt-get install grafana
  ```

- **For macOS:** Use Homebrew:
  ```bash
  brew install grafana
  ```

### 2.2. Install the SQLite Data Source Plugin for Grafana
Grafana doesn’t include a native SQLite plugin, so we need to install a third-party SQLite plugin. Here’s how to do it:

1. **Install the SQLite plugin:**
   Open a terminal and run the following command to install the SQLite plugin:
   ```bash
   grafana-cli plugins install frser-sqlite-datasource
   ```

2. **Restart Grafana:**
   After installation, restart Grafana to apply the changes:
   ```bash
   sudo systemctl restart grafana-server
   ```

3. **Access Grafana:**
   Open your web browser and go to `http://localhost:3000`. The default login is:
   - Username: `admin`
   - Password: `admin` (you’ll be prompted to change it upon first login).

### 2.3. Configure SQLite Data Source in Grafana

1. **Add Data Source:**
   - In Grafana, click on the **gear icon** (⚙️) in the sidebar to go to **Configuration**.
   - Click on **Data Sources**.
   - Click on **Add data source**.
   - Select **SQLite** from the list of available data sources.

2. **Configure Data Source Settings:**
   - **Name:** Enter a name for the data source (e.g., `SQLite Sales Data`).
   - **Database File:** Enter the path to your SQLite database file. For example, if you created the `sample.db` file in your home directory:
     ```
     /path/to/sample.db
     ```
   - **SQLite Version:** Choose the appropriate version (if unsure, the default is fine).
   - Click on **Save & Test** to ensure Grafana can connect to your SQLite database. You should see a "Data source is working" message if the connection is successful.

## **Step 3: Create a Dashboard and Visualize Data**

### 3.1. Create a New Dashboard

1. **Create a New Dashboard:**
   - From the Grafana sidebar, click on the **+** icon and select **Dashboard**.
   - Click **Add New Panel**.

2. **Configure the Panel:**
   - In the **Query** section of the panel, select the **SQLite** data source that you created earlier.
   - In the query editor, enter a SQL query to retrieve data from the `sales` table. For example:
     ```sql
     SELECT date, product, amount
     FROM sales
     ORDER BY date;
     ```

3. **Select Visualization Type:**
   - Choose a visualization type from the panel options. For example, select a **Time series** or **Bar chart** to visualize the sales data.
   - Grafana will automatically use the `date` field as the time axis if you're using a time-based visualization.

4. **Customize Panel (Optional):**
   - You can adjust settings like axes, legends, thresholds, and more to make the visualization more informative.

5. **Save the Panel:**
   - Click on **Apply** to save the panel to the dashboard.

### 3.2. Visualize the Data

You should now see your sales data visualized in Grafana. You can create additional panels to display the data in different formats, such as a bar chart to show the total sales per product or a table to display the raw sales data.
