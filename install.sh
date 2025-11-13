#!/bin/bash
# Official Ghost-CLI installer optimized 
set -e

echo "🚀 Installing Ghost via Official CLI on ..."
echo "📊 Checking system resources..."

# Check available resources
MEM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_GB=$((MEM_KB / 1024 / 1024))

#if [ $MEM_GB -lt 0.5 ]; then
#    echo "⚠️  Low memory detected (${MEM_GB}GB). Consider Docker method for better performance."
#    read -p "Continue with Ghost-CLI? (y/n): " -n 1 -r
#    if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi
#fi

# Update system
sudo apt update && sudo apt upgrade -y

# Install prerequisites
sudo apt install -y mysql-server nginx curl ufw

# Configure firewall
sudo ufw allow 'Nginx Full'
sudo ufw allow 'OpenSSH'
sudo ufw --force enable

# Install Node.js 20.x (previous version deprecated)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installations
echo "✅ Node.js version: $(node --version)"
echo "✅ npm version: $(npm --version)"

# Install Ghost CLI globally
sudo npm install -g ghost-cli@latest

# Create Ghost installation directory
sudo mkdir -p /var/www/ghost
sudo chown $USER:$USER /var/www/ghost
sudo chmod 755 /var/www/ghost
cd /var/www/ghost

# Get server IP for configuration
SERVER_IP=$(curl -s ifconfig.me)

echo "🌐 Your server IP is: $SERVER_IP"
echo "💡 You can use this IP or configure a domain later"

# Interactive setup
read -p "Enter domain (or press Enter to use IP $SERVER_IP): " DOMAIN
DOMAIN=${DOMAIN:-$SERVER_IP}

# Check if domain is IP or actual domain
if [[ $DOMAIN =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    URL="http://$DOMAIN"
else
    URL="https://$DOMAIN"
    echo "🌍 Domain detected: $DOMAIN"
    echo "📝 Make sure your domain points to: $SERVER_IP"
fi

# Install Ghost with auto-setup
echo "🎯 Installing Ghost. This may take 5-10 minutes..."
ghost install \
    --auto \
    --url "$URL" \
    --admin-url "$URL/ghost" \
    --db mysql \
    --dbhost localhost \
    --dbuser root \
    --dbname ghost_blog \
    --dbpass "$(openssl rand -base64 32)" \
    --start

echo "✅ Ghost installation completed successfully!"
echo ""
echo "📊 INSTALLATION SUMMARY:"
echo "🌐 Blog URL: $URL"
echo "🔐 Admin panel: $URL/ghost"
echo "💾 Database: MySQL"
echo "🖥️  Web server: Nginx"
echo "🔒 SSL: Auto-configured (if using domain)"
echo ""
echo "🎯 NEXT STEPS:"
echo "1. Visit $URL/ghost to complete setup"
echo "2. Create your admin account"
echo "3. Start writing your first post!"
echo ""
echo "🛠️  MANAGEMENT COMMANDS:"
echo "   ghost stop          # Stop Ghost"
echo "   ghost start         # Start Ghost"
echo "   ghost restart       # Restart Ghost"
echo "   ghost update        # Update Ghost"
echo "   ghost log           # View logs"
echo "   ghost backup        # Create backup"
