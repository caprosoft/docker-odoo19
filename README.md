# Odoo 19 (Docker) installation script

## 🧩 Prerequisites

Make sure you have:

* **GNU/Linux** (any recent distribution)
* **Docker** installed and running.
  You can check by running:
  
  ```bash
  sudo docker --version
  ```
* **Git** installed
  You can check by running:

  ```bash
  sudo git --version
  ```
---

## 🚀 Run the Script

Follow these steps to clone the repository and run the script:

1. Download the project from GitHub
```bash
git clone https://github.com/caprosoft/docker-odoo19 
```

2. Enter the project folder
```bash
cd docker-odoo19
```

3. Make the script executable
```bash
sudo chmod +x odoo19.sh
```

4. Run the script
```bash
sudo ./odoo19.sh
```
After running, Odoo will be available at **[http://localhost:8069](http://localhost:8069)**

---

### 🐳 Script Reference (`odoo19.sh`)

The script runs two Docker containers:
one for the **PostgreSQL database** and one for **Odoo**.

```bash
#!/bin/sh

sudo docker run -d -v odoo-db:/var/lib/postgresql/data \
  -e POSTGRES_USER=odoo \
  -e POSTGRES_PASSWORD=odoo \
  -e POSTGRES_DB=postgres \
  --name db postgres:15

sudo docker run -d -v odoo-data:/var/lib/odoo \
  -p 8069:8069 \
  --name odoo \
  --link db:db \
  -t odoo
```

---

### 💾 About Docker Volumes

* `odoo-db` stores the **PostgreSQL data**, keeping it persistent even if the container is removed.
* `odoo-data` stores the **Odoo application data**, ensuring that your configurations and files are preserved.

---

### ♻️ Restart Containers

If the containers already exist (e.g. after a system reboot or a manual stop), **do not run the script again** — just restart them.

> ⚠️ **Important:** Always start `db` first, before `odoo`. If Odoo starts before the database is ready, it will fail to connect and throw an error.

```bash
# Restart containers (always db first!)
sudo docker start db odoo
```
To stop them again:

```bash
sudo docker stop odoo db
```

---

### 🧹 Stop, Remove, and Re-run Containers

If you need to stop or remove the containers and volumes, use:

```bash
# Stop containers
sudo docker stop odoo db

# Remove containers
sudo docker rm odoo db

# (Optional) Remove volumes
sudo docker volume rm odoo-data odoo-db
```

To **recreate and re-run** everything after cleanup, simply execute again:

```bash
sudo ./odoo19.sh
```

This will rebuild the containers and restart your Odoo environment from scratch.

---
 
### 🔧 Auto-start with systemd
 
To have the containers **start automatically at boot**, you can create a systemd service.
 
> ✅ **Requirement:** The containers must already exist (i.e. the script `odoo19.sh` must have been run at least once).
 
**1. Create the service file**
 
```bash
sudo nano /etc/systemd/system/odoo19.service
```
 
**2. Paste the following content**
 
```ini
[Unit]
Description=Odoo 19 Docker Containers
Requires=docker.service
After=docker.service
 
[Service]
Type=oneshot
RemainAfterExit=yes
 
ExecStart=/bin/sh -c 'docker start db && sleep 5 && docker start odoo'
ExecStop=/bin/sh -c 'docker stop odoo && docker stop db'
 
[Install]
WantedBy=multi-user.target
```
 
> 💡 The `sleep 5` gives PostgreSQL a few seconds to initialize before Odoo tries to connect.
 
**3. Reload systemd and enable the service**
 
```bash
# Reload systemd to pick up the new unit file
sudo systemctl daemon-reload
 
# Enable the service to start at boot
sudo systemctl enable odoo19.service
```
 
**4. Start / Stop / Check the service manually**
 
```bash
# Start
sudo systemctl start odoo19.service
 
# Stop
sudo systemctl stop odoo19.service
 
# Check status
sudo systemctl status odoo19.service
```
 
**5. View logs**
 
```bash
sudo journalctl -u odoo19.service
```
 
---

