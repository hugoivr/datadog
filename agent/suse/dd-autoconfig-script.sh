sudo zypper install -y acl
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=<INSERT API KEY> DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
sudo sed -i 's/^# env:.*/env: prod/' /etc/datadog-agent/datadog.yaml
sudo sed -i 's/^# process_config:.*/process_config:/' /etc/datadog-agent/datadog.yaml
sudo sed -i 's/^  # process_collection:.*/  process_collection:\n    enabled: true/' /etc/datadog-agent/datadog.yaml
sudo sed -i 's/^# logs_enabled:.*/logs_enabled: true/' /etc/datadog-agent/datadog.yaml
sudo mkdir /etc/datadog-agent/conf.d/system_logs.d/
sudo touch /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo chgrp -R dd-agent /etc/datadog-agent/conf.d/system_logs.d/
sudo chown -R dd-agent /etc/datadog-agent/conf.d/system_logs.d/
sudo echo "logs:" >> /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo echo "  - type: file" >> /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo echo "    path: /var/log/messages" >> /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo echo "    service: system" >> /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo echo "    source: suse" >> /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo echo "  - type: file" >> /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo echo "    path: /var/log/audit/audit.log" >> /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo echo "    service: audit" >> /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo echo "    source: suse" >> /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo echo "  - type: file" >> /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo echo "    path: /var/log/datadog/zypper-updates.log" >> /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo echo "    service: zypper-updates" >> /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo echo "    source: suse" >> /etc/datadog-agent/conf.d/system_logs.d/conf.yaml
sudo setfacl -m u:dd-agent:rx /var/log/messages
sudo setfacl -R -m u:dd-agent:rx /var/log/audit
sudo -u dd-agent cp /etc/datadog-agent/system-probe.yaml.example /etc/datadog-agent/system-probe.yaml
sudo sed -i 's/^# network_config:.*/network_config:\n  enabled: true/' /etc/datadog-agent/system-probe.yaml
sudo echo "runtime_security_config.enabled: true" >> /etc/datadog-agent/security-agent.yaml
sudo echo "runtime_security_config.enabled: true" >> /etc/datadog-agent/system-probe.yaml
sudo chgrp dd-agent /etc/datadog-agent/security-agent.yaml
sudo chown dd-agent /etc/datadog-agent/security-agent.yaml

sudo systemctl restart datadog-agent
sudo systemctl status datadog-agent