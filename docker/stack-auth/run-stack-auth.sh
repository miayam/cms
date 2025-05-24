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
Stack Auth Management Script

Usage: ./run-stack-auth.sh [COMMAND]

Commands:
    dev           Start Stack Auth in development mode (uses Inbucket)
    prod          Start Stack Auth in production mode (uses email provider)
    stop          Stop all Stack Auth services
    restart       Restart all Stack Auth services
    logs          View all logs
    logs [service] View logs for specific service
    status        Show container status
    db-shell      Access PostgreSQL shell
    clean         Remove all containers and volumes
    gen-keys      Generate secure keys for Stack Auth and Svix
    fix-svix      Fix Svix database issues
    health        Check health of all services

Examples:
    ./run-stack-auth.sh dev
    ./run-stack-auth.sh prod
    ./run-stack-auth.sh logs stack-auth
    ./run-stack-auth.sh fix-svix
EOF
}

# Check if .env file exists
check_env_file() {
    if [ ! -f "$SCRIPT_DIR/.env" ]; then
        print_color "⚠️ .env file not found! Creating from template..." "$YELLOW"

        if [ -f "$SCRIPT_DIR/.env.template" ]; then
            cp "$SCRIPT_DIR/.env.template" "$SCRIPT_DIR/.env"
            print_color "✅ Created .env file from template" "$GREEN"
        else
            print_color "❌ .env.template not found in $SCRIPT_DIR!" "$RED"
            print_color "Please create $SCRIPT_DIR/.env file manually" "$RED"
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
    print_color "Update these in your .env file:" "$YELLOW"
    print_color "  DATABASE_URL=postgresql://stack_auth:$DB_PASSWORD@postgres:5432/stack_auth" "$BLUE"

    # Generate Svix API key
    SVIX_API_KEY="sk_test_$(openssl rand -hex 16)"
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
    env_file="$SCRIPT_DIR/.env"

    # Check if STACK_ENV exists in .env
    if grep -q "STACK_ENV=" "$env_file"; then
        # Replace existing STACK_ENV line
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s/STACK_ENV=.*/STACK_ENV=$mode/" "$env_file"
        else
            # Linux
            sed -i "s/STACK_ENV=.*/STACK_ENV=$mode/" "$env_file"
        fi
    else
        # Add STACK_ENV line
        echo "STACK_ENV=$mode" >> "$env_file"
    fi

    print_color "✅ Updated .env file with STACK_ENV=$mode" "$GREEN"
}

# Fix Svix database issues
fix_svix() {
    print_color "🔧 Fixing Svix database issues..." "$YELLOW"

    cd "$SCRIPT_DIR"

    # Stop Svix first
    print_color "Stopping Svix service..." "$YELLOW"
    docker-compose stop svix 2>/dev/null || true

    # Create svix database
    print_color "Creating svix database..." "$YELLOW"
    docker-compose exec postgres createdb -U stack_auth svix 2>/dev/null || print_color "Database might already exist" "$YELLOW"

    # Verify databases exist
    print_color "Verifying databases..." "$YELLOW"
    docker-compose exec postgres psql -U stack_auth -l | grep -E "(stack_auth|svix)" || print_color "Could not verify databases" "$RED"

    # Start Svix
    print_color "Starting Svix service..." "$YELLOW"
    docker-compose up -d svix

    # Wait and check health
    sleep 10
    print_color "Checking Svix health..." "$YELLOW"
    curl -s http://localhost:8071/api/v1/health/ && print_color "✅ Svix is healthy" "$GREEN" || print_color "❌ Svix health check failed" "$RED"
}

# Check health of all services
health_check() {
    print_color "🏥 Checking health of all services..." "$BLUE"

    cd "$SCRIPT_DIR"

    # Check if containers are running
    print_color "\n📊 Container Status:" "$BLUE"
    docker-compose ps

    # Check PostgreSQL
    print_color "\n🗄️ PostgreSQL Health:" "$BLUE"
    if docker-compose exec postgres pg_isready -U stack_auth >/dev/null 2>&1; then
        print_color "✅ PostgreSQL is ready" "$GREEN"
    else
        print_color "❌ PostgreSQL is not ready" "$RED"
    fi

    # Check Redis
    print_color "\n📦 Redis Health:" "$BLUE"
    if docker-compose exec redis redis-cli ping >/dev/null 2>&1; then
        print_color "✅ Redis is responding" "$GREEN"
    else
        print_color "❌ Redis is not responding" "$RED"
    fi

    # Check Svix
    print_color "\n🪝 Svix Health:" "$BLUE"
    if curl -s http://localhost:8071/api/v1/health/ >/dev/null 2>&1; then
        print_color "✅ Svix is healthy" "$GREEN"
    else
        print_color "❌ Svix is not healthy" "$RED"
    fi

    # Check Stack Auth
    print_color "\n🔐 Stack Auth Health:" "$BLUE"
    if curl -s http://localhost:8101/ >/dev/null 2>&1; then
        print_color "✅ Stack Auth Dashboard is accessible" "$GREEN"
    else
        print_color "❌ Stack Auth Dashboard is not accessible" "$RED"
    fi

    if curl -s http://localhost:8102/ >/dev/null 2>&1; then
        print_color "✅ Stack Auth API is accessible" "$GREEN"
    else
        print_color "❌ Stack Auth API is not accessible" "$RED"
    fi
}

# Start development mode
start_dev() {
    print_color "🚀 Starting Stack Auth in DEVELOPMENT mode..." "$GREEN"

    cd "$SCRIPT_DIR"

    # Update .env file
    update_env_mode "dev"

    # Stop any existing containers first
    print_color "Stopping existing containers..." "$YELLOW"
    docker-compose down --timeout 30

    # Start with development profile
    print_color "Starting services..." "$YELLOW"
    docker-compose --profile dev up -d

    # Wait a bit for services to start
    sleep 5

    print_color "✅ Stack Auth started in DEVELOPMENT mode" "$GREEN"
    print_color "📊 Dashboard: http://localhost:8101" "$GREEN"
    print_color "🔌 API: http://localhost:8102" "$GREEN"
    print_color "📧 Email testing: http://localhost:8105" "$GREEN"
    print_color "🪝 Svix API: http://localhost:8071" "$GREEN"
    print_color "All emails will be captured by Inbucket" "$YELLOW"

    # Run health check
    print_color "\nRunning health check in 10 seconds..." "$YELLOW"
    sleep 10
    health_check
}

# Start production mode
start_prod() {
    print_color "🚀 Starting Stack Auth in PRODUCTION mode..." "$GREEN"

    cd "$SCRIPT_DIR"

    # Update .env file
    update_env_mode "prod"

    # Check if production email settings are configured
    env_file="$SCRIPT_DIR/.env"
    if ! grep -q "SMTP_HOST=" "$env_file" || grep -q "SMTP_HOST=$" "$env_file"; then
        print_color "⚠️ Warning: Production email settings are not configured!" "$YELLOW"
        print_color "Please edit $env_file to configure your production email settings" "$YELLOW"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_color "Aborted" "$RED"
            exit 1
        fi
    fi

    # Stop any existing containers first
    print_color "Stopping existing containers..." "$YELLOW"
    docker-compose down --timeout 30

    # Start with production profile
    print_color "Starting services..." "$YELLOW"
    docker-compose --profile prod up -d

    # Wait a bit for services to start
    sleep 5

    print_color "✅ Stack Auth started in PRODUCTION mode" "$GREEN"
    print_color "📊 Dashboard: http://localhost:8101" "$GREEN"
    print_color "🔌 API: http://localhost:8102" "$GREEN"
    print_color "🪝 Svix API: http://localhost:8071" "$GREEN"
    print_color "Using email settings from .env file" "$YELLOW"

    # Run health check
    print_color "\nRunning health check in 10 seconds..." "$YELLOW"
    sleep 10
    health_check
}

# Stop all services
stop() {
    print_color "🛑 Stopping Stack Auth services..." "$YELLOW"
    cd "$SCRIPT_DIR"

    # Force stop all containers with timeout
    docker-compose down --timeout 30

    # Double check and force kill if needed
    containers=$(docker-compose ps -q 2>/dev/null)
    if [ ! -z "$containers" ]; then
        print_color "Force stopping remaining containers..." "$YELLOW"
        echo "$containers" | xargs docker stop -t 10 2>/dev/null || true
        echo "$containers" | xargs docker rm -f 2>/dev/null || true
    fi

    print_color "✅ Stack Auth services stopped" "$GREEN"
}

# Restart services
restart() {
    print_color "🔄 Restarting Stack Auth services..." "$YELLOW"
    stop
    sleep 3

    # Determine which mode we were in
    env_file="$SCRIPT_DIR/.env"
    if grep -q "STACK_ENV=prod" "$env_file"; then
        start_prod
    else
        start_dev
    fi
}

# View logs
logs() {
    cd "$SCRIPT_DIR"
    if [ -z "$1" ]; then
        print_color "📜 Viewing all logs (Ctrl+C to exit)..." "$BLUE"
        docker-compose logs -f --tail=100
    else
        print_color "📜 Viewing logs for $1 (Ctrl+C to exit)..." "$BLUE"
        docker-compose logs -f --tail=100 "$1"
    fi
}

# Show status
status() {
    print_color "📊 Stack Auth Container Status:" "$GREEN"
    cd "$SCRIPT_DIR"
    docker-compose ps

    print_color "\n🌐 Service URLs:" "$BLUE"
    print_color "Dashboard: http://localhost:8101" "$GREEN"
    print_color "API: http://localhost:8102" "$GREEN"
    print_color "Email testing: http://localhost:8105" "$GREEN"
    print_color "Svix API: http://localhost:8071" "$GREEN"
}

# Database shell
db_shell() {
    print_color "🗄️ Connecting to PostgreSQL shell..." "$GREEN"
    cd "$SCRIPT_DIR"

    # Get the user and database name from .env file
    DB_USER=$(grep "POSTGRES_USER\|DATABASE_USERNAME" "$SCRIPT_DIR/.env" | head -1 | cut -d '=' -f2)
    DB_NAME=$(grep "POSTGRES_DB\|DATABASE_NAME" "$SCRIPT_DIR/.env" | head -1 | cut -d '=' -f2)

    # Use default values if not found
    DB_USER=${DB_USER:-stack_auth}
    DB_NAME=${DB_NAME:-stack_auth}

    print_color "Connecting as user: $DB_USER to database: $DB_NAME" "$YELLOW"
    docker-compose exec postgres psql -U "$DB_USER" "$DB_NAME"
}

# Clean up
clean() {
    print_color "⚠️  This will remove ALL Stack Auth containers, volumes, and data" "$RED"
    print_color "ALL DATA WILL BE PERMANENTLY LOST!" "$RED"
    print_color "Are you absolutely sure? Type 'yes' to confirm: " "$RED"
    read -r response
    if [[ "$response" == "yes" ]]; then
        cd "$SCRIPT_DIR"
        print_color "Stopping and removing all containers and volumes..." "$YELLOW"
        docker-compose down -v --timeout 30

        # Remove any orphaned containers
        docker-compose rm -f 2>/dev/null || true

        # Clean up any remaining containers with our project name
        project_name=$(basename "$SCRIPT_DIR" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
        docker ps -a --filter "label=com.docker.compose.project=$project_name" -q | xargs docker rm -f 2>/dev/null || true

        print_color "✅ Stack Auth completely cleaned up" "$GREEN"
    else
        print_color "❌ Clean up canceled" "$YELLOW"
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
        restart)
            restart
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
        fix-svix)
            fix_svix
            ;;
        health)
            health_check
            ;;
        *)
            print_color "❌ Unknown command: $command" "$RED"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
