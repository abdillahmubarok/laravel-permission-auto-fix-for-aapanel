#!/bin/bash

# =============================================================================
# Laravel Ultimate Permission Fixer v2
# Complete solution for Laravel permission issues (FIXED VERSION)
# Compatible with Laravel 8.x - 12.x on all major Linux distributions
# 
# FIXES: Removed problematic sudoers configuration to prevent system issues
# =============================================================================

VERSION="4.1.0"
SCRIPT_NAME="Laravel Ultimate Permission Fixer v2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Global variables
LARAVEL_ROOT=""
WEB_USER=""
REAL_USER=""
OS=""
VER=""

# =============================================================================
# Utility Functions
# =============================================================================

print_header() {
    echo -e "${WHITE}============================================${NC}"
    echo -e "${WHITE}${SCRIPT_NAME} v${VERSION}${NC}"
    echo -e "${WHITE}Complete Laravel Permission Solution${NC}"
    echo -e "${WHITE}Compatible with Laravel 8.x - 12.x${NC}"
    echo -e "${WHITE}============================================${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_banner() {
    echo -e "${PURPLE}[BANNER]${NC} $1"
}

# =============================================================================
# Detection Functions
# =============================================================================

detect_real_user() {
    if [ -n "$SUDO_USER" ]; then
        REAL_USER="$SUDO_USER"
    elif [ -n "$LOGNAME" ]; then
        REAL_USER="$LOGNAME"
    else
        REAL_USER=$(logname 2>/dev/null || echo "unknown")
    fi
    
    print_info "Real user: $REAL_USER"
}

detect_laravel_root() {
    if [ -f "artisan" ] && [ -f "composer.json" ]; then
        LARAVEL_ROOT=$(pwd)
        return 0
    fi
    
    for i in {1..3}; do
        if [ -f "../artisan" ] && [ -f "../composer.json" ]; then
            LARAVEL_ROOT=$(cd .. && pwd)
            return 0
        fi
        cd ..
    done
    
    return 1
}

detect_web_server_user() {
    local detected_user=""
    
    print_step "Auto-detecting web server user..."
    
    # Check PHP-FPM processes
    if pgrep php-fpm >/dev/null 2>&1; then
        detected_user=$(ps aux | grep -E "php-fpm.*pool" | grep -v grep | head -1 | awk '{print $1}')
        if [ ! -z "$detected_user" ] && [ "$detected_user" != "root" ]; then
            print_info "Found PHP-FPM user: $detected_user"
            WEB_USER="$detected_user"
            return 0
        fi
    fi
    
    # Check Nginx worker processes
    if pgrep nginx >/dev/null 2>&1; then
        detected_user=$(ps aux | grep "nginx: worker" | grep -v grep | head -1 | awk '{print $1}')
        if [ ! -z "$detected_user" ] && [ "$detected_user" != "root" ]; then
            print_info "Found Nginx worker user: $detected_user"
            WEB_USER="$detected_user"
            return 0
        fi
    fi
    
    # Check Apache processes
    if pgrep -x "apache2\|httpd" >/dev/null 2>&1; then
        detected_user=$(ps aux | grep -E "(apache2|httpd)" | grep -v grep | grep -v root | head -1 | awk '{print $1}')
        if [ ! -z "$detected_user" ]; then
            print_info "Found Apache user: $detected_user"
            WEB_USER="$detected_user"
            return 0
        fi
    fi
    
    # Check common users
    local common_users=("www-data" "www" "apache" "nginx" "httpd" "web")
    for user in "${common_users[@]}"; do
        if id "$user" >/dev/null 2>&1; then
            print_info "Found common web user: $user"
            WEB_USER="$user"
            return 0
        fi
    done
    
    # Check config files
    for php_version in 8.3 8.2 8.1 8.0 7.4; do
        local php_config="/etc/php/${php_version}/fpm/pool.d/www.conf"
        if [ -f "$php_config" ]; then
            detected_user=$(grep "^user = " "$php_config" 2>/dev/null | cut -d'=' -f2 | tr -d ' ')
            if [ ! -z "$detected_user" ]; then
                print_info "Found PHP-FPM config user: $detected_user"
                WEB_USER="$detected_user"
                return 0
            fi
        fi
    done
    
    # OS-based fallback
    if [ -f /etc/debian_version ]; then
        WEB_USER="www-data"
        return 0
    elif [ -f /etc/redhat-release ]; then
        WEB_USER="apache"
        return 0
    fi
    
    return 1
}

detect_operating_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    print_info "Operating System: $OS $VER"
}

check_prerequisites() {
    if [ "$EUID" -ne 0 ]; then
        print_error "This script must be run as root or with sudo"
        echo ""
        print_info "Usage: sudo $0 [options]"
        exit 1
    fi
    
    detect_real_user
    detect_operating_system
    
    if ! detect_laravel_root; then
        print_error "Could not find Laravel root directory"
        print_info "Please run this script from Laravel project root directory"
        exit 1
    fi
    
    if ! detect_web_server_user; then
        print_warning "Could not auto-detect web server user"
        print_info "Will proceed with manual configuration"
        WEB_USER="www"
    fi
    
    print_success "Prerequisites check completed"
    print_info "Laravel root: $LARAVEL_ROOT"
    print_info "Web server user: $WEB_USER"
    print_info "Real user: $REAL_USER"
}

# =============================================================================
# Backup Functions
# =============================================================================

create_permission_backup() {
    local backup_dir="${LARAVEL_ROOT}/.permission-backup"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${backup_dir}/permissions_${timestamp}.txt"
    
    print_step "Creating permission backup..."
    
    mkdir -p "$backup_dir"
    find "$LARAVEL_ROOT" -exec stat -c "%n %U:%G %a" {} \; > "${backup_file}.ownership" 2>/dev/null
    echo "$backup_file" > "${backup_dir}/latest_backup.txt"
    
    print_success "Permission backup created: $backup_file"
}

# =============================================================================
# Core Permission Functions
# =============================================================================

create_required_directories() {
    print_step "Creating required Laravel directories..."
    
    local directories=(
        "storage/logs"
        "storage/framework/cache"
        "storage/framework/sessions"
        "storage/framework/views"
        "storage/framework/testing"
        "storage/app/public"
        "bootstrap/cache"
    )
    
    for dir in "${directories[@]}"; do
        local full_path="${LARAVEL_ROOT}/${dir}"
        if [ ! -d "$full_path" ]; then
            mkdir -p "$full_path"
            print_info "Created directory: $dir"
        fi
    done
    
    print_success "Required directories created"
}

clean_problematic_files() {
    print_step "Cleaning problematic files..."
    
    cd "$LARAVEL_ROOT"
    
    rm -rf storage/framework/views/*.php 2>/dev/null
    rm -rf storage/framework/cache/* 2>/dev/null
    rm -rf storage/framework/sessions/* 2>/dev/null
    rm -rf bootstrap/cache/*.php 2>/dev/null
    
    print_success "Problematic files cleaned"
}

set_basic_permissions() {
    print_step "Setting basic Laravel permissions..."
    
    cd "$LARAVEL_ROOT"
    
    # Set ownership
    chown -R "$WEB_USER:$WEB_USER" ./
    
    # Set directory permissions
    find . -type d -exec chmod 755 {} \; 2>/dev/null
    
    # Set file permissions
    find . -type f -exec chmod 644 {} \; 2>/dev/null
    
    # Set executable permissions
    chmod 755 artisan 2>/dev/null
    
    # Set writable directories
    chmod -R 775 storage bootstrap/cache 2>/dev/null
    find storage -type f -exec chmod 664 {} \; 2>/dev/null
    find bootstrap/cache -type f -exec chmod 664 {} \; 2>/dev/null
    
    # Set secure permissions for sensitive files
    chmod 600 .env 2>/dev/null
    chmod 600 .env.example 2>/dev/null
    
    # Fix composer files
    chown "$WEB_USER:$WEB_USER" composer.lock composer.json 2>/dev/null
    chmod 664 composer.lock composer.json 2>/dev/null
    chown -R "$WEB_USER:$WEB_USER" vendor/ 2>/dev/null
    
    print_success "Basic permissions set"
}

# =============================================================================
# ACL and Persistent Functions (SAFE VERSION)
# =============================================================================

install_acl() {
    if ! command -v setfacl >/dev/null 2>&1; then
        print_step "Installing ACL package..."
        if [ -f /etc/debian_version ]; then
            apt-get update >/dev/null 2>&1 && apt-get install -y acl >/dev/null 2>&1
        elif [ -f /etc/redhat-release ]; then
            (yum install -y acl || dnf install -y acl) >/dev/null 2>&1
        fi
        print_success "ACL installed"
    fi
}

setup_acl_permissions() {
    print_step "Setting up ACL permissions..."
    
    if ! command -v setfacl >/dev/null 2>&1; then
        print_warning "ACL not available, skipping ACL setup"
        return 1
    fi
    
    local laravel_dirs=(
        "$LARAVEL_ROOT"
        "$LARAVEL_ROOT/storage"
        "$LARAVEL_ROOT/bootstrap/cache"
        "$LARAVEL_ROOT/vendor"
    )
    
    for dir in "${laravel_dirs[@]}"; do
        if [ -d "$dir" ]; then
            setfacl -R -m u:$REAL_USER:rwx "$dir" 2>/dev/null
            setfacl -R -m u:$WEB_USER:rwx "$dir" 2>/dev/null
            setfacl -R -d -m u:$REAL_USER:rwx "$dir" 2>/dev/null
            setfacl -R -d -m u:$WEB_USER:rwx "$dir" 2>/dev/null
        fi
    done
    
    print_success "ACL permissions configured"
}

create_wrapper_commands() {
    print_step "Creating Laravel wrapper commands..."
    
    local bin_dir="/usr/local/bin"
    
    # Create helper script for permission fixing
    cat > "$bin_dir/laravel-fix-permissions" << EOF
#!/bin/bash
# Laravel Permission Fix Helper

if [ \$# -ne 1 ]; then
    echo "Usage: \$0 <laravel_root_path>"
    exit 1
fi

LARAVEL_ROOT="\$1"
WEB_USER="$WEB_USER"

cd "\$LARAVEL_ROOT"
chown -R \$WEB_USER:\$WEB_USER bootstrap/cache/ storage/ 2>/dev/null
find bootstrap/cache storage -type f -exec chmod 664 {} \\; 2>/dev/null
find bootstrap/cache storage -type d -exec chmod 775 {} \\; 2>/dev/null
chown \$WEB_USER:\$WEB_USER composer.lock 2>/dev/null
chown -R \$WEB_USER:\$WEB_USER vendor/ 2>/dev/null
chmod 664 composer.lock 2>/dev/null
EOF
    
    chmod +x "$bin_dir/laravel-fix-permissions"
    
    # Create artisan wrapper
    cat > "$bin_dir/laravel-artisan" << EOF
#!/bin/bash
# Laravel Artisan Wrapper - Auto-fixes permissions

find_laravel_root() {
    local dir=\$(pwd)
    while [ "\$dir" != "/" ]; do
        if [ -f "\$dir/artisan" ] && [ -f "\$dir/composer.json" ]; then
            echo "\$dir"
            return 0
        fi
        dir=\$(dirname "\$dir")
    done
    return 1
}

LARAVEL_ROOT=\$(find_laravel_root)
if [ -z "\$LARAVEL_ROOT" ]; then
    echo "Error: Not in a Laravel project directory"
    exit 1
fi

cd "\$LARAVEL_ROOT"
php artisan "\$@"
RESULT=\$?

if [ \$RESULT -eq 0 ]; then
    echo "🔧 Fixing permissions..."
    sudo laravel-fix-permissions "\$LARAVEL_ROOT"
fi

exit \$RESULT
EOF

    # Create composer wrapper
    cat > "$bin_dir/laravel-composer" << EOF
#!/bin/bash
# Laravel Composer Wrapper - Auto-fixes permissions

find_laravel_root() {
    local dir=\$(pwd)
    while [ "\$dir" != "/" ]; do
        if [ -f "\$dir/artisan" ] && [ -f "\$dir/composer.json" ]; then
            echo "\$dir"
            return 0
        fi
        dir=\$(dirname "\$dir")
    done
    return 1
}

LARAVEL_ROOT=\$(find_laravel_root)
if [ -z "\$LARAVEL_ROOT" ]; then
    echo "Error: Not in a Laravel project directory"
    exit 1
fi

cd "\$LARAVEL_ROOT"
composer "\$@"
RESULT=\$?

if [ \$RESULT -eq 0 ]; then
    echo "🔧 Fixing permissions..."
    sudo laravel-fix-permissions "\$LARAVEL_ROOT"
fi

exit \$RESULT
EOF

    # Create quick fix command
    cat > "$bin_dir/laravel-fix-now" << EOF
#!/bin/bash
# Laravel Quick Permission Fix

find_laravel_root() {
    local dir=\$(pwd)
    while [ "\$dir" != "/" ]; do
        if [ -f "\$dir/artisan" ] && [ -f "\$dir/composer.json" ]; then
            echo "\$dir"
            return 0
        fi
        dir=\$(dirname "\$dir")
    done
    return 1
}

LARAVEL_ROOT=\$(find_laravel_root)
if [ -z "\$LARAVEL_ROOT" ]; then
    echo "Error: Not in a Laravel project directory"
    exit 1
fi

echo "🔧 Quick fixing Laravel permissions..."
sudo laravel-fix-permissions "\$LARAVEL_ROOT"
echo "✅ Laravel permissions fixed!"
EOF

    # Make wrappers executable
    chmod +x "$bin_dir/laravel-artisan"
    chmod +x "$bin_dir/laravel-composer" 
    chmod +x "$bin_dir/laravel-fix-now"
    
    print_success "Wrapper commands created"
}

# SAFE SUDOERS SETUP - Only for the helper script
setup_safe_sudoers() {
    print_step "Setting up safe sudoers configuration..."
    
    local sudoers_file="/etc/sudoers.d/laravel-safe-fix"
    
    # Create simple, safe sudoers entry
    cat > "$sudoers_file" << EOF
# Laravel Safe Permission Fix - Single helper script only
$REAL_USER ALL=(ALL) NOPASSWD: /usr/local/bin/laravel-fix-permissions
EOF

    chmod 440 "$sudoers_file"
    
    # Test sudoers syntax
    if visudo -c >/dev/null 2>&1; then
        print_success "Safe sudoers configuration created"
    else
        print_error "Sudoers syntax error detected, removing file"
        rm -f "$sudoers_file"
        return 1
    fi
}

create_aliases() {
    print_step "Creating convenient aliases..."
    
    local home_dir="/home/$REAL_USER"
    local bashrc_file="$home_dir/.bashrc"
    
    if [ -f "$bashrc_file" ]; then
        if ! grep -q "Laravel Ultimate Fix v2" "$bashrc_file"; then
            cat >> "$bashrc_file" << 'EOF'

# Laravel Ultimate Fix v2 - Permission-Safe Aliases
alias la='laravel-artisan'
alias lart='laravel-artisan'
alias lcomp='laravel-composer'
alias lfix='laravel-fix-now'

# Quick Laravel commands
alias la-clear='laravel-artisan optimize:clear'
alias la-cache='laravel-artisan config:cache && laravel-artisan route:cache'
alias la-migrate='laravel-artisan migrate'
alias la-seed='laravel-artisan db:seed'
alias la-fresh='laravel-artisan migrate:fresh --seed'

EOF
            print_success "Aliases added to $bashrc_file"
        else
            print_info "Aliases already exist"
        fi
    fi
}

# =============================================================================
# Laravel Specific Functions
# =============================================================================

clear_laravel_caches() {
    print_step "Clearing Laravel caches..."
    
    cd "$LARAVEL_ROOT"
    
    local cache_commands=(
        "config:clear"
        "route:clear" 
        "view:clear"
        "cache:clear"
    )
    
    for command in "${cache_commands[@]}"; do
        php artisan $command >/dev/null 2>&1 && print_info "Cleared: $command"
    done
    
    print_success "Laravel caches cleared"
}

test_permissions() {
    print_step "Testing Laravel permissions..."
    
    local test_results=0
    
    # Test storage write
    if touch "$LARAVEL_ROOT/storage/logs/test.tmp" 2>/dev/null; then
        rm "$LARAVEL_ROOT/storage/logs/test.tmp"
        print_success "Storage directory: WRITABLE"
    else
        print_error "Storage directory: NOT WRITABLE"
        test_results=1
    fi
    
    # Test bootstrap cache write
    if touch "$LARAVEL_ROOT/bootstrap/cache/test.tmp" 2>/dev/null; then
        rm "$LARAVEL_ROOT/bootstrap/cache/test.tmp"
        print_success "Bootstrap cache: WRITABLE"
    else
        print_error "Bootstrap cache: NOT WRITABLE"
        test_results=1
    fi
    
    # Test artisan executable
    if [ -x "$LARAVEL_ROOT/artisan" ]; then
        print_success "Artisan: EXECUTABLE"
    else
        print_error "Artisan: NOT EXECUTABLE"
        test_results=1
    fi
    
    # Test Laravel functionality
    cd "$LARAVEL_ROOT"
    if php artisan --version >/dev/null 2>&1; then
        print_success "Laravel: WORKING"
    else
        print_error "Laravel: NOT WORKING"
        test_results=1
    fi
    
    # Test wrapper commands
    if command -v laravel-artisan >/dev/null 2>&1; then
        print_success "Wrapper commands: INSTALLED"
    else
        print_warning "Wrapper commands: NOT FOUND"
        test_results=1
    fi
    
    # Test sudoers (safe version)
    if sudo -n laravel-fix-permissions "$LARAVEL_ROOT" 2>/dev/null; then
        print_success "Sudoers helper: WORKING"
    else
        print_info "Sudoers helper: Requires password (normal)"
    fi
    
    return $test_results
}

# =============================================================================
# Main Functions
# =============================================================================

show_help() {
    echo -e "${WHITE}Laravel Ultimate Permission Fixer v2 - SAFE VERSION${NC}"
    echo ""
    echo "USAGE:"
    echo "  sudo $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help              Show this help message"
    echo "  -b, --basic             Basic permission fix only"
    echo "  -f, --full              Full persistent solution (default)"
    echo "  -t, --test-only         Test permissions without changes"
    echo "  --backup               Create backup before changes"
    echo "  --no-wrappers          Skip wrapper command creation"
    echo "  --no-aliases           Skip alias creation"
    echo "  --no-sudoers           Skip sudoers configuration"
    echo "  --force                Force execution without prompts"
    echo ""
    echo "IMPROVEMENTS IN V2:"
    echo "  • Fixed sudoers syntax errors"
    echo "  • Safer permission management"
    echo "  • Won't break 'sudo su -' functionality"
    echo "  • Simplified sudoers configuration"
    echo ""
    echo "EXAMPLES:"
    echo "  sudo $0                 # Full safe solution"
    echo "  sudo $0 --basic         # Basic fix only"
    echo "  sudo $0 --no-sudoers    # Without sudoers modification"
    echo ""
}

show_success_message() {
    echo ""
    print_banner "🎉 Laravel Ultimate Permission Fix v2 completed successfully!"
    echo ""
    print_info "📦 What was installed:"
    print_info "  • laravel-artisan     - Permission-safe artisan wrapper"
    print_info "  • laravel-composer    - Permission-safe composer wrapper"  
    print_info "  • laravel-fix-now     - Quick permission fix command"
    print_info "  • laravel-fix-permissions - Helper script (sudo safe)"
    echo ""
    print_info "🔧 Available aliases (after shell reload):"
    print_info "  • la, lart            - laravel-artisan"
    print_info "  • lcomp               - laravel-composer"
    print_info "  • lfix                - laravel-fix-now"
    print_info "  • la-clear            - optimize:clear"
    print_info "  • la-cache            - cache config & routes"
    echo ""
    print_info "💡 Usage examples:"
    print_info "  laravel-composer update"
    print_info "  laravel-artisan migrate"
    print_info "  la-clear              # (after shell reload)"
    print_info "  lfix                  # (quick permission fix)"
    echo ""
    print_success "✅ SAFE VERSION: Won't affect 'sudo su -' functionality"
    print_warning "⚠️  NEXT STEPS:"
    print_warning "1. Open new terminal OR run: source ~/.bashrc"
    print_warning "2. Use wrapper commands for Laravel operations"
    echo ""
}

main() {
    local mode="full"
    local create_backup=false
    local test_only=false
    local no_wrappers=false
    local no_aliases=false
    local no_sudoers=false
    local force_execution=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -b|--basic)
                mode="basic"
                shift
                ;;
            -f|--full)
                mode="full"
                shift
                ;;
            -t|--test-only)
                test_only=true
                shift
                ;;
            --backup)
                create_backup=true
                shift
                ;;
            --no-wrappers)
                no_wrappers=true
                shift
                ;;
            --no-aliases)
                no_aliases=true
                shift
                ;;
            --no-sudoers)
                no_sudoers=true
                shift
                ;;
            --force)
                force_execution=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    print_header
    check_prerequisites
    
    if [ "$test_only" = true ]; then
        test_permissions
        exit $?
    fi
    
    if [ "$force_execution" != true ]; then
        echo ""
        print_warning "This will modify Laravel permissions for: $LARAVEL_ROOT"
        print_warning "Mode: $mode"
        print_warning "Web server user: $WEB_USER"
        print_info "SAFE VERSION: Won't break sudo functionality"
        echo -n "Continue? [y/N]: "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            print_info "Operation cancelled"
            exit 0
        fi
    fi
    
    echo ""
    print_step "Starting Laravel Ultimate Permission Fix v2..."
    print_info "Mode: $mode"
    
    if [ "$create_backup" = true ]; then
        create_permission_backup
    fi
    
    # Basic permission fix (always done)
    create_required_directories
    clean_problematic_files
    set_basic_permissions
    clear_laravel_caches
    
    # Full persistent solution
    if [ "$mode" = "full" ]; then
        install_acl
        setup_acl_permissions
        
        if [ "$no_wrappers" != true ]; then
            create_wrapper_commands
            
            if [ "$no_sudoers" != true ]; then
                setup_safe_sudoers
            fi
        fi
        
        if [ "$no_aliases" != true ]; then
            create_aliases
        fi
    fi
    
    # Test final permissions
    echo ""
    print_step "Testing final setup..."
    if test_permissions; then
        show_success_message
    else
        print_error "Some tests failed. Please check the output above."
        exit 1
    fi
}

# =============================================================================
# Script Execution
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
