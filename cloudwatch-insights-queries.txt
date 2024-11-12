# Sample Query
// return get requests by hour
fields @timestamp, @message 
| parse @message "GET * HTTP/1.1" as method, url 
| stats count(*) as cnt by bin(1h)

# Other queries
Count of Requests by Status Code
Average Response Time (Latency)
Top 10 URLs by Traffic Volume
Requests Over Time (Hourly Breakdown)
Count of Requests by HTTP Method
Top 5 IPs Making the Most Requests
Requests with Response Time Over 2 Seconds
Requests with 5xx Status Code
Average Response Time by HTTP Method
Top 5 User Agents by Request Count
Top 10 URLs by Response Time
Requests per Minute
Count of Successful Requests (2xx Status Codes)
Count of Failed Requests (4xx Status Codes)
Top 10 IPs with 4xx Status Codes
Requests with Specific HTTP Status Code (e.g., 404 Not Found)
Request Count by Response Size
Average Response Time by URL
Top 10 Most Frequent Referrers
Requests with Slow Response Time (e.g., > 5 seconds)
