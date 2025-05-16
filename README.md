# CMS Monorepo

A monorepo for CMS applications with Stack Auth integration.

## 🚀 Quick Start

```bash
# Install dependencies
pnpm install

# Start Stack Auth in development mode
pnpm stack-auth:start

# Start everything (when you add your apps)
pnpm dev:all
```

## 📋 Available Commands

### Stack Auth Commands

```bash
# Start Stack Auth in development mode (uses Inbucket for email)
pnpm stack-auth:start
# or
pnpm stack-auth:start:dev

# Start Stack Auth in production mode (uses configured email provider)
pnpm stack-auth:start:prod

# Stop Stack Auth
pnpm stack-auth:stop

# View Stack Auth logs
pnpm stack-auth:logs

# Check Stack Auth status
pnpm stack-auth:status

# Access PostgreSQL database shell
pnpm stack-auth:db-shell

# Clean up Stack Auth containers and volumes
pnpm stack-auth:clean
```

### Combined Commands

```bash
# Start everything (Stack Auth + apps) in development mode
pnpm dev:all

# Start everything in production mode
pnpm prod:all

# Stop everything
pnpm stop:all
```

## 📦 Structure

```
cms/
├── apps/                   # Your applications
├── docker/
│   └── stack-auth/         # Stack Auth configuration
│       ├── docker-compose.yml
│       ├── .env            # Environment config (create from .env.template)
│       └── run-stack-auth.sh
├── packages/               # Shared packages
├── package.json
└── pnpm-workspace.yaml
```

## ⚙️ Configuration

### Setting Up Stack Auth

1. Create `.env` file from template:
   ```bash
   cp docker/stack-auth/.env.template docker/stack-auth/.env
   ```

2. Edit `.env` with your settings:
   ```bash
   nano docker/stack-auth/.env
   ```

3. Generate a secure key for `STACK_SECRET_SERVER_KEY`:
   ```bash
   openssl rand -hex 32
   ```

### Email Configuration

#### Development (Default)

The default configuration uses Inbucket for development, which captures all emails locally:

- Access emails at: http://localhost:8105
- No real emails are sent

#### Production

For production, edit `.env` and uncomment the production email settings:

```env
SMTP_HOST=smtp.mailersend.net
SMTP_PORT=587
SMTP_SECURE=true
SMTP_USER=your_mailersend_username
SMTP_PASSWORD=your_mailersend_api_key_here
SMTP_FROM_NAME=Stack Auth
SMTP_FROM_EMAIL=noreply@your-domain.com

# Change this to 'prod' for production mode
STACK_ENV=prod
```

## 🔗 Access URLs

- **Stack Auth Dashboard**: http://localhost:8101
- **Stack Auth API**: http://localhost:8102
- **Email Testing UI**: http://localhost:8105 (development only)
- **PostgreSQL**: localhost:5432
