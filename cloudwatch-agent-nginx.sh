# create a role and attach it to a ec2 instance

cd ~/
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
sudo apt-get update && apt-get install collectd
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard # run wizard to create a configuration file
# add additional log file for tracking from /var/log/nginx/access.log
# !!!important you need to give chmod r+x to /var/log/nginx/access.log so cwagent can read the logs
# skip statsd (network metrics) and collectd (system-level performance monitoring)
cat /opt/aws/amazon-cloudwatch-agent/bin/config.json # this is the configuration file
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
# or use sudo systemctl start amazon-cloudwatch-agent
# sudo systemctl stop amazon-cloudwatch-agent
# sudo systemctl restart amazon-cloudwatch-agent


# source: https://gauravguptacloud.medium.com/aws-cloudwatch-agent-installation-for-memory-metric-integrate-with-grafana-365404154
