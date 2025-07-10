# 🚀 Laravel Permission Auto Fix for aaPanel

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Laravel](https://img.shields.io/badge/Laravel-8.x--12.x-red.svg)](https://laravel.com)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![aaPanel Compatible](https://img.shields.io/badge/aaPanel-Compatible-blue.svg)](https://www.aapanel.com/)

Complete solution for Laravel permission issues on **aaPanel** and other hosting control panels that lack automatic permission management.

## 🎯 Problem Statement

Unlike cPanel or CyberPanel, **aaPanel doesn't provide automatic Laravel permission management**. This leads to common issues:

- ❌ `Permission denied` errors when Laravel tries to write to storage
- ❌ Cache and log files not writable by web server
- ❌ Manual permission fixes get reset after composer/artisan operations  
- ❌ Different file owners between CLI user and web server user

## ✨ Features

### 🛡️ **Safe & Production Ready**
- ✅ **Fixed v2**: Won't break `sudo su -` functionality
- ✅ Auto-detects web server user (Apache, Nginx, PHP-FPM)
- ✅ Backup creation before making changes
- ✅ Syntax validation for sudoers configuration

### 🔧 **Smart Permission Management**
- ✅ Automatically sets correct Laravel directory permissions
- ✅ Creates ACL (Access Control Lists) for persistent permissions
- ✅ Handles multiple users (CLI user + web server user)
- ✅ Safe cleanup of problematic cache files

### 🚀 **Productivity Tools**
- ✅ **Permission-safe wrappers**: `laravel-artisan`, `laravel-composer`
- ✅ **Quick fix command**: `laravel-fix-now`
- ✅ **Convenient aliases**: `la`, `lart`, `lcomp`, `lfix`
- ✅ **Auto-fix**: Permissions automatically fixed after operations

### 📦 **Wide Compatibility**
- ✅ Laravel 8.x - 12.x
- ✅ Ubuntu, Debian, CentOS, RHEL
- ✅ Apache, Nginx, PHP-FPM
- ✅ aaPanel, Direct VPS, Other control panels

## 📋 Requirements

- **Linux** (Ubuntu/Debian/CentOS/RHEL)
- **Root access** or sudo privileges
- **Laravel project** with `artisan` and `composer.json`
- **Web server** (Apache/Nginx) with PHP

## 🚀 Quick Installation

### Option 1: Direct Download & Run
```bash
# Download the script
wget https://raw.githubusercontent.com/abdillahmubarok/laravel-permission-auto-fix-for-aapanel/main/laravel-ultimate-fix-v2.sh

# Make executable
chmod +x laravel-ultimate-fix-v2.sh

# Run from your Laravel project root
cd /www/wwwroot/your-laravel-project
sudo ./laravel-ultimate-fix-v2.sh
```

### Option 2: Clone Repository
```bash
# Clone repository
git clone https://github.com/abdillahmubarok/laravel-permission-auto-fix-for-aapanel.git

# Navigate to project
cd laravel-permission-auto-fix-for-aapanel

# Run the script from your Laravel root
cd /www/wwwroot/your-laravel-project
sudo /path/to/laravel-ultimate-fix-v2.sh
```

## 📖 Usage

### Basic Usage
```bash
# Navigate to your Laravel project root
cd /www/wwwroot/your-laravel-project

# Run the complete fix
sudo ./laravel-ultimate-fix-v2.sh
```

### Advanced Usage
```bash
# Basic permission fix only (no wrappers)
sudo ./laravel-ultimate-fix-v2.sh --basic

# Full solution without sudoers modification
sudo ./laravel-ultimate-fix-v2.sh --no-sudoers

# Create backup before changes
sudo ./laravel-ultimate-fix-v2.sh --backup

# Test current permissions without changes
sudo ./laravel-ultimate-fix-v2.sh --test-only

# Force execution without prompts
sudo ./laravel-ultimate-fix-v2.sh --force
```

## 🛠️ Command Line Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-b, --basic` | Basic permission fix only |
| `-f, --full` | Full persistent solution (default) |
| `-t, --test-only` | Test permissions without making changes |
| `--backup` | Create backup before changes |
| `--no-wrappers` | Skip wrapper command creation |
| `--no-aliases` | Skip alias creation |
| `--no-sudoers` | Skip sudoers configuration |
| `--force` | Force execution without prompts |

## 🎉 What Gets Installed

### 🔧 **Wrapper Commands**
- **`laravel-artisan`** - Permission-safe artisan wrapper
- **`laravel-composer`** - Permission-safe composer wrapper  
- **`laravel-fix-now`** - Quick permission fix command
- **`laravel-fix-permissions`** - Helper script (sudo safe)

### ⚡ **Convenient Aliases** (after shell reload)
- **`la`, `lart`** → `laravel-artisan`
- **`lcomp`** → `laravel-composer`
- **`lfix`** → `laravel-fix-now`
- **`la-clear`** → `laravel-artisan optimize:clear`
- **`la-cache`** → Cache config & routes
- **`la-migrate`** → `laravel-artisan migrate`
- **`la-fresh`** → `laravel-artisan migrate:fresh --seed`

## 💡 Usage Examples

### After Installation
```bash
# Reload shell to enable aliases
source ~/.bashrc

# Or open new terminal

# Use wrapper commands
laravel-composer update
laravel-artisan migrate
laravel-artisan cache:clear

# Use convenient aliases
la migrate --seed          # = laravel-artisan migrate --seed
lcomp require package-name # = laravel-composer require package-name
la-clear                   # = laravel-artisan optimize:clear
lfix                       # = quick permission fix
```

### Quick Permission Fix Anytime
```bash
# If permissions get messed up again
lfix

# Or manually
sudo laravel-fix-permissions /www/wwwroot/your-project
```

## 🆕 What's New in v2?

### 🔥 **Major Fixes**
- ✅ **Fixed sudoers syntax errors** that broke `sudo su -`
- ✅ **Safer sudoers configuration** with single helper script
- ✅ **Won't affect system functionality** anymore
- ✅ **Auto-cleanup** of problematic sudoers files

### 🛡️ **Enhanced Safety**
- ✅ **Syntax validation** before applying sudoers changes
- ✅ **Robust error handling** with automatic rollback
- ✅ **Optional sudoers** modification (can be skipped)
- ✅ **Production-ready** for public GitHub repository

### 🚀 **Improved Features**
- ✅ **Better auto-detection** of web server users
- ✅ **Enhanced compatibility** with various Linux distributions
- ✅ **Cleaner code structure** and documentation
- ✅ **More flexible options** for different use cases

## 🔧 Troubleshooting

### Common Issues

#### 1. **"Permission denied" errors persist**
```bash
# Re-run the permission fix
lfix

# Or run full fix again
sudo ./laravel-ultimate-fix-v2.sh --force
```

#### 2. **Web server user not detected correctly**
```bash
# Check current web server processes
ps aux | grep -E "apache|nginx|php-fpm"

# Manual fix if needed
sudo chown -R www-data:www-data storage/ bootstrap/cache/
```

#### 3. **Aliases not working**
```bash
# Reload shell configuration
source ~/.bashrc

# Or open new terminal session
```

#### 4. **"Command not found" for wrapper commands**
```bash
# Check if commands are installed
ls -la /usr/local/bin/laravel-*

# Re-run installation
sudo ./laravel-ultimate-fix-v2.sh --force
```

### 🆘 **Emergency Cleanup** (if needed)

If you encounter issues with the sudoers configuration:

```bash
# Remove problematic sudoers files
sudo rm -f /etc/sudoers.d/laravel-*

# Test sudo functionality
sudo su -

# Re-run script without sudoers
sudo ./laravel-ultimate-fix-v2.sh --no-sudoers
```

## 📊 Testing Your Setup

```bash
# Test all functionality
sudo ./laravel-ultimate-fix-v2.sh --test-only

# Test Laravel functionality
cd /www/wwwroot/your-project
php artisan --version
touch storage/logs/test.tmp && rm storage/logs/test.tmp

# Test wrapper commands
laravel-artisan --version
which laravel-fix-now
```

## 🏗️ **For aaPanel Users**

### Perfect Integration
This script is specifically designed for **aaPanel environments**:

- ✅ **Detects aaPanel's standard paths** (`/www/wwwroot/`)
- ✅ **Works with aaPanel's PHP-FPM** configuration
- ✅ **Compatible with aaPanel's Nginx/Apache** setup
- ✅ **Doesn't interfere** with aaPanel's management system

### Recommended Workflow for aaPanel
```bash
# 1. Create Laravel project via aaPanel
# 2. SSH into server
# 3. Navigate to project
cd /www/wwwroot/your-domain.com

# 4. Run permission fix
wget https://raw.githubusercontent.com/abdillahmubarok/laravel-permission-auto-fix-for-aapanel/main/laravel-ultimate-fix-v2.sh
sudo bash laravel-ultimate-fix-v2.sh

# 5. Use wrapper commands for Laravel operations
laravel-composer install
laravel-artisan key:generate
laravel-artisan migrate
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### How to Contribute
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Reporting Issues
- Use the GitHub Issues tab to report bugs
- Provide your OS version, Laravel version, and web server details
- Include the output of `sudo ./laravel-ultimate-fix-v2.sh --test-only`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⭐ Star This Repository

If this script helped you solve Laravel permission issues on aaPanel, please give it a star! ⭐

---

**Made with ❤️ for the Laravel community by [Abdillah Mubarok](https://github.com/abdillahmubarok)**

### 🔗 Related Links
- [Laravel Documentation](https://laravel.com/docs)
- [aaPanel Official Site](https://www.aapanel.com/)
- [Linux File Permissions Guide](https://chmod-calculator.com/)

---

> **Need help?** Open an issue or check the troubleshooting section above!
