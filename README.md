# ATutor 2.2.4 Fixed Docker Image (Plug & Play)

This repository provides a patched and optimized Docker image for the **ATutor 2.2.4** LMS. It solves legacy issues with modern Docker environments, PHP 7.1 extensions, and database compatibility.

## 🚀 Key Improvements & Fixes

- **Full PHP Extension Suite**: Pre-installed `mysqli`, `pdo`, `pdo_mysql`, `mbstring`, `xml`, `gd`, and `curl`. This enables support for modern plugins (e.g., JWT, Gamification) and advanced content editors.
- **Auto-Config Writer**: No more "config.inc.php not writeable" errors. The installer has full permissions to save your configuration automatically.
- **Legacy PHP Support**: Optimized for PHP 7.1 with `short_open_tag = On` and increased `memory_limit (256M)` for heavy content processing.
- **MySQL 5.7+ Compatibility**: Specifically patched to work with modern MySQL strict modes and UTF-8 requirements.
- **Debug Toggle**: Control system debug info via a simple constant in your configuration.


## 📦 Quick Start with Docker Compose

Create a `docker-compose.yml` file in your project directory:

```yaml
version: '3.8'

services:
  db:
    image: mysql:5.7
    container_name: atutor_db
    # CRITICAL: Disable strict mode for legacy query compatibility
    command: --character-set-server=utf8 --collation-server=utf8_general_ci --sql-mode="NO_ENGINE_SUBSTITUTION"
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: your_root_password
      MYSQL_DATABASE: atutor
      MYSQL_USER: atutor_user
      MYSQL_PASSWORD: your_password
    volumes:
      - ./mysql_data:/var/lib/mysql

  atutor:
    image: hryhorko/atutor-fixed:2.2.4
    container_name: atutor_lms
    restart: always
    ports:
      - "8080:80"
    depends_on:
      - db
    volumes:
      - ./atutor_content:/var/www/html/content
```

### Installation Steps

1. Run `docker compose up -d`.
2. Open `http://your-ip:8080/install/install.php` in your browser.
3. **Important**: Use `db` as the **Database Host** (do not use `localhost`).
4. After successful installation, for security reasons, remove the install folder:
   ```bash
   docker exec -u root <container_id> rm -rf /var/www/html/install
   ```

### ⚠️ Important: Database SQL Mode
ATutor 2.2.4 uses legacy SQL queries that are incompatible with modern MySQL "Strict Mode". Ensure your database service includes the following command:
--sql-mode="NO_ENGINE_SUBSTITUTION"
Without this, you will encounter HTTP 500 errors or "Could not find driver" messages when saving content.

### ⚠️ Important: Directory Permissions
Before running the containers, ensure the content directory on your host machine is writable by the webserver (user ID 33 in Debian):
```bash
mkdir -p ./atutor_content
sudo chown -R 33:33 ./atutor_content
sudo chmod -R 775 ./atutor_content
```

## 🛠 Post-Installation Tweaks

### Manage Debug Information (System Messages)
If you see technical data (Session/Configuration arrays) in the footer, you can toggle it in your `include/config.inc.php`:

1. Open your `config.inc.php` file.
2. Add or modify the following line:
   - `define('AT_DEBUG', 0);` — **Production mode** (hides all debug info).
   - `define('AT_DEBUG', 1);` — **Development mode** (shows detailed system info).
3. Clear the ATutor cache to apply changes:
   ```bash
   docker exec -u root <container_id> rm -rf /var/www/html/content/cache/*
   ```

## 🏗 Manual Build

If you prefer to build the image yourself from the source:
```bash
docker build -t hryhorko/atutor-fixed:2.2.4 .
```
