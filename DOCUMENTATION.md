# 📚 Laravel Permission Auto Fix - Complete Documentation

## 📖 Table of Contents

1. [Architecture Overview](#-architecture-overview)
2. [Detailed Installation Guide](#-detailed-installation-guide)
3. [Command Reference](#-command-reference)
4. [Configuration Details](#-configuration-details)
5. [Technical Implementation](#-technical-implementation)
6. [Troubleshooting Guide](#-troubleshooting-guide)
7. [Advanced Usage](#-advanced-usage)
8. [Development & Customization](#-development--customization)

## 🏗️ Architecture Overview

### Script Components

```
laravel-ultimate-fix-v2.sh
├── Detection Functions
│   ├── detect_real_user()          # Detects actual user behind sudo
│   ├── detect_laravel_root()       # Finds Laravel project root
│   ├── detect_web_server_user()    # Auto-detects web server user
│   └── detect_operating_system()   # OS and distribution detection
├── Permission Functions
│   ├── create_required_directories() # Creates Laravel directories
│   ├── clean_problematic_files()     # Removes cache conflicts
│   ├── set_basic_permissions()       # Sets standard permissions
│   └── setup_acl_permissions()       # Configures ACL for persistence
├── Wrapper Functions
│   ├── create_wrapper_commands()     # Creates permission-safe commands
│   ├── setup_safe_sudoers()         # Configures sudoers (optional)
│   └── create_aliases()             # Adds convenient shell aliases
└── Utility Functions
    ├── create_permission_backup()   # Backup before changes
    ├── test_permissions()           # Validation and testing
    └── clear_laravel_caches()       # Laravel cache cleanup
```

### File Structure After Installation

```
/usr/local/bin/
├── laravel-artisan              # Permission-safe artisan wrapper
├── laravel-composer             # Permission-safe composer wrapper
├── laravel-fix-now              # Quick permission fix command
└── laravel-fix-permissions      # Core permission helper

/etc/sudoers.d/
└── laravel-safe-fix             # Sudoers configuration (optional)

$HOME/.bashrc                    # Shell aliases (appended)

$LARAVEL_ROOT/.permission-backup/
├── permissions_YYYYMMDD_HHMMSS.txt.ownership
└── latest_backup.txt
```

## 🚀 Detailed Installation Guide

### System Requirements

#### Supported Operating Systems
- **Ubuntu**: 18.04, 20.04, 22.04, 24.04
- **Debian**: 9, 10, 11, 12
- **CentOS**: 7, 8, 9
- **RHEL**: 7, 8, 9
- **Other**: Most modern Linux distributions

#### Required Packages
- `bash` (version 4.0+)
- `sudo` with proper configuration
- `find`, `chown`, `chmod` (standard utilities)
- `php` (for Laravel testing)

#### Optional Packages (Auto-installed if needed)
- `acl` (for Access Control Lists)
- `setfacl` and `getfacl` utilities

### Installation Methods

#### Method 1: Quick Install (Recommended)
```bash
# Download and run in one command
curl -fsSL https://raw.githubusercontent.com/abdillahmubarok/laravel-permission-auto-fix-for-aapanel/main/laravel-ultimate-fix-v2.sh | sudo bash
```

#### Method 2: Download and Inspect
```bash
# Download script
wget https://raw.githubusercontent.com/abdillahmubarok/laravel-permission-auto-fix-for-aapanel/main/laravel-ultimate-fix-v2.sh

# Inspect the script (recommended for security)
less laravel-ultimate-fix-v2.sh

# Make executable and run
chmod +x laravel-ultimate-fix-v2.sh
sudo ./laravel-ultimate-fix-v2.sh
```

#### Method 3: Git Clone
```bash
# Clone repository
git clone https://github.com/abdillahmubarok/laravel-permission-auto-fix-for-aapanel.git
cd laravel-permission-auto-fix-for-aapanel

# Navigate to Laravel project and run
cd /path/to/your/laravel/project
sudo /path/to/laravel-ultimate-fix-v2.sh
```

## 📋 Command Reference

### Main Script Options

```bash
sudo ./laravel-ultimate-fix-v2.sh [OPTIONS]
```

#### Core Options
| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--help` | `-h` | Show help message and exit | |
| `--basic` | `-b` | Basic permission fix only | |
| `--full` | `-f` | Full persistent solution | ✅ |
| `--test-only` | `-t` | Test permissions without changes | |

#### Safety Options
| Option | Description | Impact |
|--------|-------------|--------|
| `--backup` | Create backup before changes | Recommended for production |
| `--force` | Skip confirmation prompts | Use with caution |
| `--no-sudoers` | Skip sudoers configuration | Safer for shared servers |
| `--no-wrappers` | Skip wrapper command creation | Limited functionality |
| `--no-aliases` | Skip alias creation | No shell shortcuts |

### Installed Commands

#### Core Commands
```bash
laravel-fix-permissions <laravel_root_path>
# Core permission helper script
# Usage: sudo laravel-fix-permissions /www/wwwroot/my-project

laravel-fix-now
# Quick permission fix for current Laravel project
# Auto-detects Laravel root from current directory

laravel-artisan [artisan_arguments]
# Permission-safe artisan wrapper
# Automatically fixes permissions after command execution

laravel-composer [composer_arguments]
# Permission-safe composer wrapper
# Automatically fixes permissions after command execution
```

#### Alias Commands (after shell reload)
```bash
la [arguments]          # Alias for laravel-artisan
lart [arguments]        # Alias for laravel-artisan
lcomp [arguments]       # Alias for laravel-composer
lfix                    # Alias for laravel-fix-now

# Laravel-specific shortcuts
la-clear                # laravel-artisan optimize:clear
la-cache                # Config and route caching
la-migrate              # laravel-artisan migrate
la-seed                 # laravel-artisan db:seed
la-fresh                # laravel-artisan migrate:fresh --seed
```

## ⚙️ Configuration Details

### Permission Structure

#### Directory Permissions
```bash
Laravel Root:           755 (rwxr-xr-x)
├── app/               755 (rwxr-xr-x)
├── bootstrap/         755 (rwxr-xr-x)
│   └── cache/         775 (rwxrwxr-x) # Writable
├── config/            755 (rwxr-xr-x)
├── database/          755 (rwxr-xr-x)
├── public/            755 (rwxr-xr-x)
├── resources/         755 (rwxr-xr-x)
├── routes/            755 (rwxr-xr-x)
├── storage/           775 (rwxrwxr-x) # Writable
│   ├── app/           775 (rwxrwxr-x)
│   ├── framework/     775 (rwxrwxr-x)
│   └── logs/          775 (rwxrwxr-x)
├── tests/             755 (rwxr-xr-x)
└── vendor/            755 (rwxr-xr-x)
```

#### File Permissions
```bash
Regular files:          644 (rw-r--r--)
Executable files:       755 (rwxr-xr-x)
├── artisan            755 (rwxr-xr-x)
Sensitive files:        600 (rw-------)
├── .env               600 (rw-------)
├── .env.example       600 (rw-------)
Cache files:            664 (rw-rw-r--)
├── storage/*          664 (rw-rw-r--)
├── bootstrap/cache/*  664 (rw-rw-r--)
```

#### Ownership Structure
```bash
Owner: www-data (web server user)
Group: www-data (web server group)
ACL:   user:youruser:rwx (CLI user access)
       user:www-data:rwx (web server access)
```

### Auto-Detection Logic

#### Web Server User Detection Priority
1. **PHP-FPM Process User**
   ```bash
   ps aux | grep -E "php-fpm.*pool" | grep -v grep | head -1 | awk '{print $1}'
   ```

2. **Nginx Worker Process User**
   ```bash
   ps aux | grep "nginx: worker" | grep -v grep | head -1 | awk '{print $1}'
   ```

3. **Apache Process User**
   ```bash
   ps aux | grep -E "(apache2|httpd)" | grep -v grep | grep -v root | head -1 | awk '{print $1}'
   ```

4. **Common User Check**
   ```bash
   # Checks existence: www-data, www, apache, nginx, httpd, web
   ```

5. **Configuration File Check**
   ```bash
   # PHP-FPM pool configuration
   grep "^user = " /etc/php/*/fpm/pool.d/www.conf
   ```

6. **OS-based Fallback**
   ```bash
   # Debian-based: www-data
   # RHEL-based: apache
   ```

#### Laravel Root Detection
```bash
# Current directory check
[ -f "artisan" ] && [ -f "composer.json" ]

# Parent directory traversal (up to 3 levels)
for i in {1..3}; do
    [ -f "../artisan" ] && [ -f "../composer.json" ]
    cd ..
done
```

## 🔧 Technical Implementation

### ACL (Access Control Lists) Setup

#### What ACL Provides
- **Persistent Permissions**: Survive file operations
- **Multi-User Access**: Both CLI user and web server can read/write
- **Fine-Grained Control**: Per-file and per-directory permissions

#### ACL Commands Used
```bash
# Set recursive ACL
setfacl -R -m u:$REAL_USER:rwx $LARAVEL_ROOT
setfacl -R -m u:$WEB_USER:rwx $LARAVEL_ROOT

# Set default ACL for new files
setfacl -R -d -m u:$REAL_USER:rwx $LARAVEL_ROOT
setfacl -R -d -m u:$WEB_USER:rwx $LARAVEL_ROOT
```

#### Checking ACL Status
```bash
# View ACL for directory
getfacl storage/

# View ACL for file
getfacl storage/logs/laravel.log
```

### Sudoers Configuration (Safe Version)

#### Generated Sudoers File
```bash
# /etc/sudoers.d/laravel-safe-fix
yourusername ALL=(ALL) NOPASSWD: /usr/local/bin/laravel-fix-permissions
```

#### Safety Measures
- **Single Command**: Only one specific script allowed
- **Syntax Validation**: Checked with `visudo -c` before applying
- **Auto-Cleanup**: Removed if syntax errors detected
- **Optional**: Can be skipped with `--no-sudoers`

### Wrapper Command Implementation

#### laravel-artisan Wrapper
```bash
#!/bin/bash
# Find Laravel root automatically
find_laravel_root() {
    local dir=$(pwd)
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/artisan" ] && [ -f "$dir/composer.json" ]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

LARAVEL_ROOT=$(find_laravel_root)
cd "$LARAVEL_ROOT"
php artisan "$@"
RESULT=$?

# Auto-fix permissions after successful operation
if [ $RESULT -eq 0 ]; then
    sudo laravel-fix-permissions "$LARAVEL_ROOT"
fi

exit $RESULT
```

## 🐛 Troubleshooting Guide

### Common Issues and Solutions

#### 1. **Permission Denied Errors Continue**

**Symptoms:**
```bash
file_put_contents(): failed to open stream: Permission denied
```

**Diagnosis:**
```bash
# Check current permissions
ls -la storage/logs/
ls -la bootstrap/cache/

# Check ownership
ls -la storage/ | head -5

# Check ACL status
getfacl storage/logs/
```

**Solutions:**
```bash
# Option 1: Re-run full fix
sudo ./laravel-ultimate-fix-v2.sh --force

# Option 2: Quick fix
lfix

# Option 3: Manual permission fix
sudo chown -R www-data:www-data storage/ bootstrap/cache/
sudo chmod -R 775 storage/ bootstrap/cache/
```

#### 2. **Web Server User Not Detected**

**Symptoms:**
```bash
[WARNING] Could not auto-detect web server user
[INFO] Will proceed with manual configuration
```

**Diagnosis:**
```bash
# Check running web server processes
ps aux | grep -E "apache|nginx|php"

# Check PHP-FPM configuration
sudo find /etc -name "*.conf" -path "*/php*" -exec grep -l "user.*=" {} \;

# Check web server configuration
sudo nginx -T | grep user
sudo apache2ctl -S | grep user
```

**Solutions:**
```bash
# Option 1: Install and start web server properly
sudo systemctl start nginx
sudo systemctl start php7.4-fpm  # or your PHP version

# Option 2: Manual configuration
# Edit the script and set WEB_USER manually
WEB_USER="www-data"  # or your web server user
```

#### 3. **Aliases Not Working**

**Symptoms:**
```bash
bash: la: command not found
bash: lfix: command not found
```

**Diagnosis:**
```bash
# Check if aliases were added
tail ~/.bashrc | grep -A 10 "Laravel Ultimate Fix"

# Check current shell
echo $SHELL
echo $0
```

**Solutions:**
```bash
# Option 1: Reload shell configuration
source ~/.bashrc

# Option 2: Open new terminal session
exit  # then reconnect

# Option 3: Manual alias check
grep -n "Laravel Ultimate Fix" ~/.bashrc

# Option 4: Re-run alias creation
sudo ./laravel-ultimate-fix-v2.sh --no-sudoers --no-wrappers
```

#### 4. **Wrapper Commands Not Found**

**Symptoms:**
```bash
bash: laravel-artisan: command not found
bash: laravel-fix-now: command not found
```

**Diagnosis:**
```bash
# Check if commands exist
ls -la /usr/local/bin/laravel-*

# Check PATH
echo $PATH | grep -o "/usr/local/bin"

# Check command permissions
ls -la /usr/local/bin/laravel-artisan
```

**Solutions:**
```bash
# Option 1: Re-run wrapper creation
sudo ./laravel-ultimate-fix-v2.sh --force

# Option 2: Fix PATH issue
export PATH="/usr/local/bin:$PATH"
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc

# Option 3: Manual wrapper check
sudo chmod +x /usr/local/bin/laravel-*
```

#### 5. **Laravel Project Not Detected**

**Symptoms:**
```bash
[ERROR] Could not find Laravel root directory
[INFO] Please run this script from Laravel project root directory
```

**Diagnosis:**
```bash
# Check current directory
pwd
ls -la

# Look for Laravel files
find . -name "artisan" -o -name "composer.json" | head -5

# Check if in subdirectory
find /www/wwwroot -name "artisan" 2>/dev/null | head -5
```

**Solutions:**
```bash
# Option 1: Navigate to Laravel root
cd /www/wwwroot/your-domain.com
sudo /path/to/laravel-ultimate-fix-v2.sh

# Option 2: Find Laravel projects
find /www -name "artisan" -type f 2>/dev/null

# Option 3: Verify Laravel project structure
ls -la artisan composer.json
```

### Emergency Recovery

#### If Sudoers Configuration Breaks

**Symptoms:**
```bash
sudo: parse error in /etc/sudoers.d/laravel-safe-fix near line 1
sudo: no valid sudoers sources found, quitting
```

**Recovery Steps:**
```bash
# Step 1: Boot into recovery mode or use root access

# Step 2: Remove problematic sudoers files
rm -f /etc/sudoers.d/laravel-*

# Step 3: Verify sudoers syntax
visudo -c

# Step 4: Test sudo functionality
sudo whoami

# Step 5: Re-run script without sudoers
sudo ./laravel-ultimate-fix-v2.sh --no-sudoers
```

#### If Permissions Get Completely Messed Up

**Recovery Steps:**
```bash
# Step 1: Reset to basic Laravel permissions
cd /path/to/laravel/project
sudo chown -R www-data:www-data ./
sudo find . -type d -exec chmod 755 {} \;
sudo find . -type f -exec chmod 644 {} \;

# Step 2: Fix critical directories
sudo chmod -R 775 storage/ bootstrap/cache/
sudo chmod 755 artisan

# Step 3: Fix sensitive files
sudo chmod 600 .env

# Step 4: Re-run the script
sudo ./laravel-ultimate-fix-v2.sh --backup --force
```

## 🚀 Advanced Usage

### Custom Web Server User

```bash
# If auto-detection fails, you can modify the script
# Edit the detect_web_server_user function or set manually:

# Open script in editor
nano laravel-ultimate-fix-v2.sh

# Find and modify this line:
WEB_USER="your-custom-user"

# Or export before running
export CUSTOM_WEB_USER="your-user"
sudo -E ./laravel-ultimate-fix-v2.sh
```

### Multiple Laravel Projects

```bash
# Script for multiple projects
for project in /www/wwwroot/*/; do
    if [ -f "$project/artisan" ]; then
        echo "Fixing permissions for: $project"
        cd "$project"
        sudo laravel-fix-permissions "$project"
    fi
done
```

### Integration with CI/CD

```bash
# Add to deployment script
#!/bin/bash
DEPLOY_PATH="/www/wwwroot/your-domain.com"

# Deploy code
git pull origin main
composer install --no-dev --optimize-autoloader

# Fix permissions automatically
sudo laravel-fix-permissions "$DEPLOY_PATH"

# Laravel optimizations
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Fix permissions again after cache generation
sudo laravel-fix-permissions "$DEPLOY_PATH"
```

### Monitoring Script

```bash
#!/bin/bash
# Laravel permission monitor script

LARAVEL_ROOT="/www/wwwroot/your-domain.com"

check_permissions() {
    # Check if storage is writable
    if ! touch "$LARAVEL_ROOT/storage/logs/test.tmp" 2>/dev/null; then
        echo "$(date): Storage not writable, fixing permissions..."
        sudo laravel-fix-permissions "$LARAVEL_ROOT"
    else
        rm -f "$LARAVEL_ROOT/storage/logs/test.tmp"
    fi
}

# Run every 5 minutes
while true; do
    check_permissions
    sleep 300
done
```

## 🔨 Development & Customization

### Script Structure for Developers

```bash
# Main sections of the script:

# 1. Global Configuration
VERSION="4.1.0"
SCRIPT_NAME="Laravel Ultimate Permission Fixer v2"

# 2. Utility Functions (colors, logging)
print_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# 3. Detection Functions
detect_real_user()
detect_laravel_root()
detect_web_server_user()
detect_operating_system()

# 4. Core Permission Functions
create_required_directories()
clean_problematic_files()
set_basic_permissions()

# 5. Persistent Solution Functions
setup_acl_permissions()
create_wrapper_commands()
setup_safe_sudoers()

# 6. Main Execution
main() {
    check_prerequisites
    # ... execution logic
}
```

### Adding Custom Functions

```bash
# Add custom function after existing functions
custom_laravel_optimization() {
    print_step "Running custom Laravel optimizations..."
    
    cd "$LARAVEL_ROOT"
    
    # Your custom logic here
    php artisan config:cache
    php artisan route:cache
    php artisan view:cache
    
    print_success "Custom optimizations completed"
}

# Add to main() function
if [ "$mode" = "full" ]; then
    # ... existing code
    custom_laravel_optimization
fi
```

### Contributing Guidelines

#### Code Style
- Use 4 spaces for indentation
- Follow bash best practices
- Add comments for complex logic
- Use descriptive function names

#### Testing
```bash
# Test on different systems
vagrant up ubuntu20
vagrant ssh ubuntu20 -c "cd /vagrant && sudo ./laravel-ultimate-fix-v2.sh --test-only"

# Test edge cases
sudo ./laravel-ultimate-fix-v2.sh --basic --no-sudoers --force
sudo ./laravel-ultimate-fix-v2.sh --test-only
```

#### Pull Request Process
1. Fork the repository
2. Create feature branch
3. Add tests for new functionality
4. Update documentation
5. Submit pull request

### Customization Examples

#### Custom Directory Structure
```bash
# If your Laravel structure is different
custom_create_directories() {
    local directories=(
        "storage/logs"
        "storage/custom-cache"
        "storage/uploads"
        "custom-bootstrap/cache"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "${LARAVEL_ROOT}/${dir}"
        chmod 775 "${LARAVEL_ROOT}/${dir}"
    done
}
```

#### Custom Web Server Detection
```bash
# For custom web servers
detect_custom_web_server() {
    if pgrep -x "custom-server" >/dev/null 2>&1; then
        WEB_USER=$(ps aux | grep "custom-server" | grep -v grep | head -1 | awk '{print $1}')
        return 0
    fi
    return 1
}
```

This completes the comprehensive documentation for the Laravel Permission Auto Fix script. The documentation covers all aspects from basic usage to advanced customization for developers and system administrators.
