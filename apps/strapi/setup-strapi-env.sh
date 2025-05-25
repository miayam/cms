#!/bin/bash
# Script created with assistance from Claude AI (Anthropic)
# Date: 2025-05-24

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${2}${1}${NC}\n"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Display help
show_help() {
    cat << EOF
Strapi Environment Setup Script

Usage: ./setup-strapi-env.sh [COMMAND]

Commands:
    create        Create .env file for Strapi
    generate      Generate secure keys and tokens
    help          Show this help message

Examples:
    ./setup-strapi-env.sh create
    ./setup-strapi-env.sh generate
EOF
}

# Check if openssl is available
check_openssl() {
    if ! command -v openssl &> /dev/null; then
        print_color "❌ OpenSSL is not installed!" "$RED"
        print_color "Please install OpenSSL:" "$YELLOW"
        print_color "  Ubuntu/Debian: sudo apt update && sudo apt install openssl" "$NC"
        print_color "  CentOS/RHEL: sudo yum install openssl" "$NC"
        print_color "  Alpine: apk add openssl" "$NC"
        exit 1
    fi
}

# Generate secure tokens for Strapi
generate_strapi_tokens() {
    check_openssl
    print_color "Generating secure tokens for Strapi..." "$GREEN"

    # Generate APP_KEYS (4 keys separated by commas)
    APP_KEY1=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    APP_KEY2=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    APP_KEY3=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    APP_KEY4=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    APP_KEYS="$APP_KEY1,$APP_KEY2,$APP_KEY3,$APP_KEY4"

    # Generate API Token Salt
    API_TOKEN_SALT=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')

    # Generate Admin JWT Secret
    ADMIN_JWT_SECRET=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')

    # Generate Transfer Token Salt
    TRANSFER_TOKEN_SALT=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')

    # Generate JWT Secret
    JWT_SECRET=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')

    print_color "✅ Generated all Strapi tokens" "$GREEN"

    # Return the tokens as variables
    echo "APP_KEYS=$APP_KEYS"
    echo "API_TOKEN_SALT=$API_TOKEN_SALT"
    echo "ADMIN_JWT_SECRET=$ADMIN_JWT_SECRET"
    echo "TRANSFER_TOKEN_SALT=$TRANSFER_TOKEN_SALT"
    echo "JWT_SECRET=$JWT_SECRET"
}

# Create .env file for Strapi
create_strapi_env() {
    check_openssl

    if [ -f "$SCRIPT_DIR/.env" ]; then
        print_color "⚠️ .env file already exists, overwriting..." "$YELLOW"
    fi

    print_color "Creating Strapi .env file with secure tokens..." "$YELLOW"

    # Generate all tokens
    APP_KEY1=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    APP_KEY2=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    APP_KEY3=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    APP_KEY4=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    APP_KEYS="$APP_KEY1,$APP_KEY2,$APP_KEY3,$APP_KEY4"

    API_TOKEN_SALT=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    ADMIN_JWT_SECRET=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    TRANSFER_TOKEN_SALT=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    JWT_SECRET=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')

    # Create .env file
    cat > "$SCRIPT_DIR/.env" << EOF
# Server Configuration
HOST=0.0.0.0
PORT=1337
APP_KEYS=$APP_KEYS
API_TOKEN_SALT=$API_TOKEN_SALT
ADMIN_JWT_SECRET=$ADMIN_JWT_SECRET
TRANSFER_TOKEN_SALT=$TRANSFER_TOKEN_SALT
JWT_SECRET=$JWT_SECRET

# Database Configuration (for development with Docker dependencies)
DATABASE_CLIENT=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5433
DATABASE_NAME=strapi
DATABASE_USERNAME=strapi
DATABASE_PASSWORD=strapi
DATABASE_SSL=false

# Node Environment
NODE_ENV=development

# Admin Configuration
STRAPI_ADMIN_BACKEND_URL=http://localhost:1337
STRAPI_ADMIN_CLIENT_URL=http://localhost:1337
STRAPI_ADMIN_CLIENT_PREVIEW_SECRET=preview-secret-token

# File Upload Configuration
STRAPI_PLUGIN_I18N_INIT_LOCALE_CODE=en

# Optional: Email Configuration (uncomment and configure as needed)
# EMAIL_PROVIDER=smtp
# EMAIL_SMTP_HOST=smtp.gmail.com
# EMAIL_SMTP_PORT=587
# EMAIL_SMTP_USERNAME=your-email@gmail.com
# EMAIL_SMTP_PASSWORD=your-app-password
# EMAIL_SMTP_SECURE=false

# Optional: Cloud Storage (uncomment and configure as needed)
# AWS_ACCESS_KEY_ID=your-access-key
# AWS_SECRET_ACCESS_KEY=your-secret-key
# AWS_REGION=us-east-1
# AWS_BUCKET=your-bucket-name

# Optional: Redis (if using Redis for caching)
# REDIS_URL=redis://localhost:6379

# Security
STRAPI_DISABLE_UPDATE_NOTIFICATION=true
STRAPI_TELEMETRY_DISABLED=true
EOF

    print_color "✅ Created Strapi .env file successfully!" "$GREEN"
    print_color "📁 Location: $SCRIPT_DIR/.env" "$BLUE"
    print_color "🔑 All secure tokens have been generated automatically" "$BLUE"
    print_color "" "$NC"
    print_color "📋 Next steps:" "$YELLOW"
    print_color "1. Review the .env file and customize as needed" "$NC"
    print_color "2. Configure email settings if required" "$NC"
    print_color "3. Set up cloud storage if needed" "$NC"
    print_color "4. Start Strapi with: pnpm strapi:dev" "$NC"
    print_color "5. Access Strapi admin at: http://localhost:1337/admin" "$NC"
}

# Display generated tokens (for manual copying)
show_generated_tokens() {
    check_openssl

    print_color "Generated Strapi tokens:" "$GREEN"
    print_color "Copy these to your .env file:" "$YELLOW"
    print_color "" "$NC"

    # Generate tokens
    APP_KEY1=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    APP_KEY2=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    APP_KEY3=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    APP_KEY4=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    APP_KEYS="$APP_KEY1,$APP_KEY2,$APP_KEY3,$APP_KEY4"

    API_TOKEN_SALT=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    ADMIN_JWT_SECRET=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    TRANSFER_TOKEN_SALT=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    JWT_SECRET=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')

    print_color "APP_KEYS=$APP_KEYS" "$BLUE"
    print_color "API_TOKEN_SALT=$API_TOKEN_SALT" "$BLUE"
    print_color "ADMIN_JWT_SECRET=$ADMIN_JWT_SECRET" "$BLUE"
    print_color "TRANSFER_TOKEN_SALT=$TRANSFER_TOKEN_SALT" "$BLUE"
    print_color "JWT_SECRET=$JWT_SECRET" "$BLUE"
}

# Main script logic
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    command="$1"
    case "$command" in
        create)
            create_strapi_env
            ;;
        generate)
            show_generated_tokens
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_color "❌ Unknown command: $command" "$RED"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
