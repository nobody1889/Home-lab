apt-get autoremove -y
apt-get autoclean -y

rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Clean cloud-init so every new VM gets fresh instance data
cloud-init clean --logs --seed

# Clear bash history
rm -f /root/.bash_history /home/debian/.bash_history || true

echo "✅ Cleanup completed"