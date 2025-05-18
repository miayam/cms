#!/bin/bash
# Script created with assistance from Claude AI (Anthropic)
# Date: 2025-05-18

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${2}${1}${NC}\n"
}

# Display help
show_help() {
    cat << EOF
Stack Auth Management Script

Usage: ./run-stack-auth.sh [COMMAND]

Commands:
    dev           Start Stack Auth in development mode (uses Inbucket)
    prod          Start Stack Auth in production mode (uses email provider)
    stop          Stop all Stack Auth services
    logs          View all logs
    logs [service] View logs for specific service
    status        Show container status
    db-shell      Access PostgreSQL shell
    clean         Remove all containers and volumes
    gen-keys      Generate secure keys for Stack Auth and Svix

Examples:
    ./run-stack-auth.sh dev
    ./run-stack-auth.sh prod
    ./run-stack-auth.sh logs stack-auth
EOF
}

# Check if .env file exists
check_env_file() {
    if [ ! -f "docker/stack-auth/.env" ]; then
        print_color "⚠️ .env file not found! Creating from template..." "$YELLOW"
        if [ -f "docker/stack-auth/.env.template" ]; then
            cp docker/stack-auth/.env.template docker/stack-auth/.env
            print_color "✅ Created .env file from template" "$GREEN"
            print_color "⚠️ Please edit docker/stack-auth/.env with your settings!" "$YELLOW"
        else
            print_color "❌ .env.template not found! Please create docker/stack-auth/.env file manually" "$RED"
            exit 1
        fi
    fi
}

# Generate secure keys
generate_keys() {
    print_color "Generating secure keys for Stack Auth..." "$GREEN"

    # Generate Stack Auth server secret
    SERVER_SECRET=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=')
    print_color "Stack Auth Server Secret: $SERVER_SECRET" "$GREEN"
    print_color "Add this to your .env file as STACK_SECRET_SERVER_KEY" "$YELLOW"

    # Generate strong password for database
    DB_PASSWORD=$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9')
    print_color "Database Password: $DB_PASSWORD" "$GREEN"
    print_color "Add this to your .env file for DATABASE_URL and POSTGRES_PASSWORD" "$YELLOW"

    # Generate Svix API key
    SVIX_API_KEY="sv-$(openssl rand -hex 16)"
    print_color "Svix API Key: $SVIX_API_KEY" "$GREEN"
    print_color "Add this to your .env file as STACK_SVIX_API_KEY" "$YELLOW"

    # Generate Svix JWT secret
    SVIX_JWT_SECRET="sv-$(openssl rand -hex 32)"
    print_color "Svix JWT Secret: $SVIX_JWT_SECRET" "$GREEN"
    print_color "Add this to your .env file as SVIX_JWT_SECRET" "$YELLOW"

    print_color "✅ All keys generated. Use these to update your .env file." "$GREEN"
}

# Update STACK_ENV in .env file
update_env_mode() {
    mode=$1
    env_file="docker/stack-auth/.env"

    # Check if STACK_ENV exists in .env
    if grep -q "STACK_ENV=" "$env_file"; then
        # Replace existing STACK_ENV line
        sed -i "s/STACK_ENV=.*/STACK_ENV=$mode/" "$env_file"
    else
        # Add STACK_ENV line
        echo "STACK_ENV=$mode" >> "$env_file"
    fi

    print_color "✅ Updated .env file with STACK_ENV=$mode" "$GREEN"
}

# Start development mode
start_dev() {
    print_color "Starting Stack Auth in DEVELOPMENT mode..." "$GREEN"

    # Update .env file
    update_env_mode "dev"

    # Start with development profile
    cd docker/stack-auth
    docker-compose --profile dev up -d

    print_color "✅ Stack Auth started in DEVELOPMENT mode" "$GREEN"
    print_color "📊 Dashboard: http://localhost:8101" "$GREEN"
    print_color "🔌 API: http://localhost:8102" "$GREEN"
    print_color "📧 Email testing: http://localhost:8105" "$GREEN"
    print_color "All emails will be captured by Inbucket" "$YELLOW"
}

# Start production mode
start_prod() {
    print_color "Starting Stack Auth in PRODUCTION mode..." "$GREEN"

    # Update .env file
    update_env_mode "prod"

    # Check if production email settings are configured
    env_file="docker/stack-auth/.env"
    if ! grep -q "STACK_EMAIL_HOST=" "$env_file" || grep -q "STACK_EMAIL_HOST=$" "$env_file"; then
        print_color "⚠️ Warning: Production email settings are not configured!" "$YELLOW"
        print_color "Please edit docker/stack-auth/.env to configure your production email settings" "$YELLOW"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_color "Aborted" "$RED"
            exit 1
        fi
    fi

    # Start with production profile
    cd docker/stack-auth
    docker-compose --profile prod up -d

    print_color "✅ Stack Auth started in PRODUCTION mode" "$GREEN"
    print_color "📊 Dashboard: http://localhost:8101" "$GREEN"
    print_color "🔌 API: http://localhost:8102" "$GREEN"
    print_color "Using email settings from .env file" "$YELLOW"
}

# Stop all services
stop() {
    print_color "Stopping Stack Auth services..." "$YELLOW"
    cd docker/stack-auth
    docker-compose down
    print_color "✅ Stack Auth services stopped" "$GREEN"
}

# View logs
logs() {
    cd docker/stack-auth
    if [ -z "$1" ]; then
        docker-compose logs -f
    else
        docker-compose logs -f "$1"
    fi
}

# Show status
status() {
    print_color "Stack Auth Container Status:" "$GREEN"
    cd docker/stack-auth
    docker-compose ps
}

# Database shell
db_shell() {
    print_color "Connecting to PostgreSQL shell..." "$GREEN"
    cd docker/stack-auth

    # Get the user and database name from .env file
    DB_USER=$(grep POSTGRES_USER docker/stack-auth/.env | cut -d '=' -f2)
    DB_NAME=$(grep POSTGRES_DB docker/stack-auth/.env | cut -d '=' -f2)

    # Use default values if not found
    DB_USER=${DB_USER:-stack_auth}
    DB_NAME=${DB_NAME:-stack_auth}

    docker-compose exec postgres psql -U $DB_USER $DB_NAME
}

# Clean up
clean() {
    print_color "⚠️  This will remove all Stack Auth containers and volumes" "$RED"
    print_color "All data will be lost. Are you sure? (y/N) " "$RED"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        cd docker/stack-auth
        docker-compose down -v
        print_color "✅ Stack Auth cleaned up" "$GREEN"
    else
        print_color "Clean up canceled" "$YELLOW"
    fi
}

# Main script logic
main() {
    # Check for .env file
    check_env_file

    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    command="$1"
    case "$command" in
        dev)
            start_dev
            ;;
        prod)
            start_prod
            ;;
        stop)
            stop
            ;;
        logs)
            logs "$2"
            ;;
        status)
            status
            ;;
        db-shell)
            db_shell
            ;;
        clean)
            clean
            ;;
        gen-keys)
            generate_keys
            ;;
        *)
            print_color "Unknown command: $command" "$RED"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
