# CMS Monorepo

An all-in-one, self-hosted CMS platform for your side hustles (blogging, newsletters, subscription courses, membership sites, digital products, etc.) powered by Strapi and Stack Auth.

## 🚀 Quick Start

```bash
# Install dependencies
pnpm install

# Create and configure the .env file for Stack Auth
cp docker/stack-auth/.env.template docker/stack-auth/.env
# Edit the .env file with your settings
nano docker/stack-auth/.env

# Generate secure keys
openssl rand -base64 32 | tr '+/' '-_' | tr -d '=' # For STACK_SECRET_SERVER_KEY
echo "sv-$(openssl rand -hex 16)" # For STACK_SVIX_API_KEY
echo "sv-$(openssl rand -hex 32)" # For SVIX_JWT_SECRET

# Start Stack Auth in development mode
chmod +x docker/stack-auth/run-stack-auth.sh
pnpm stack-auth:start

# Start Strapi in development mode
pnpm strapi:dev

# Start everything
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
# Start everything (Stack Auth + Strapi + all apps) in development mode
pnpm dev:all

# Start everything in production mode
pnpm prod:all

# Stop everything
pnpm stop:all
```

## 📦 Structure

```
cms/
├── apps/                       # Your applications
|    └── strapi/                # Strapi CMS application
│       ├── src/
│       │   ├── extensions/     # Strapi extensions
│       └── ...
├── docker/
│   └── stack-auth/             # Stack Auth configuration
│       ├── docker-compose.yml
│       ├── .env.template       # Environment config template
│       ├── .env                # Environment config (create from .env.template)
│       └── run-stack-auth.sh
├── packages/                   # Shared packages
│   ├── diajar-notes/           # Notes-taking plugin for Strapi (shared publicly)
│   ├── jamhook/                # Jamstack build management
│   └── ...
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

3. Generate required secure keys and update the `.env` file:

   a. For `STACK_SECRET_SERVER_KEY`:
   ```bash
   openssl rand -base64 32 | tr '+/' '-_' | tr -d '='
   ```

   b. For database password:
   ```bash
   openssl rand -base64 24 | tr -dc 'a-zA-Z0-9'
   ```

   c. For Svix API Key:
   ```bash
   echo "sv-$(openssl rand -hex 16)"
   ```

   d. For Svix JWT Secret:
   ```bash
   echo "sv-$(openssl rand -hex 32)"
   ```

4. Your `.env` file should include these essential configurations:

```
# Core URLs
NEXT_PUBLIC_STACK_API_URL=http://localhost:8102
NEXT_PUBLIC_STACK_DASHBOARD_URL=http://localhost:8101

# Database connection
DATABASE_URL=postgresql://stack_auth:YOUR_GENERATED_PASSWORD@postgres:5432/stack_auth

# Server secret key
STACK_SECRET_SERVER_KEY=YOUR_GENERATED_SECRET

# Development or Production mode
STACK_ENV=dev

# Email settings
SMTP_HOST=inbucket
SMTP_PORT=2500
SMTP_SECURE=false
SMTP_USER=
SMTP_PASSWORD=
SMTP_FROM_NAME=Stack Auth
SMTP_FROM_EMAIL=noreply@example.com

# Svix webhooks configuration
STACK_SVIX_SERVER_URL=http://svix:8071
NEXT_PUBLIC_STACK_SVIX_SERVER_URL=http://localhost:8071
STACK_SVIX_API_KEY=YOUR_GENERATED_SVIX_API_KEY
SVIX_JWT_SECRET=YOUR_GENERATED_SVIX_JWT_SECRET

# Seed script settings
STACK_SEED_INTERNAL_PROJECT_SIGN_UP_ENABLED=true
STACK_SEED_INTERNAL_PROJECT_OTP_ENABLED=false
STACK_SEED_INTERNAL_PROJECT_ALLOW_LOCALHOST=true
STACK_SEED_INTERNAL_PROJECT_USER_EMAIL=admin@example.com
STACK_SEED_INTERNAL_PROJECT_USER_PASSWORD=StrongPassword123
STACK_SEED_INTERNAL_PROJECT_USER_INTERNAL_ACCESS=true
```

### Email Configuration

#### Development (Default)

The default configuration uses Inbucket for development, which captures all emails locally:

- Access emails at: http://localhost:8105
- No real emails are sent

#### Production

For production, edit `.env` and update the email settings:

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

### Webhooks with Svix

Stack Auth uses Svix for webhook functionality. This allows your application to receive notifications when events occur (such as user creation, authentication, etc.).

The webhooks are configured automatically with the settings in your `.env` file. You can access the Svix API at http://localhost:8071 in development mode.

## 🔗 Access URLs

- **Stack Auth Dashboard**: http://localhost:8101
- **Stack Auth API**: http://localhost:8102
- **Email Testing UI**: http://localhost:8105 (development only)
- **Svix API**: http://localhost:8071
- **PostgreSQL**: localhost:5432

## 🔑 Default Admin Credentials

When Stack Auth starts for the first time, it creates a default admin user:

- **Email**: admin@example.com
- **Password**: StrongPassword123

You can change these credentials in your `.env` file by updating:
```
STACK_SEED_INTERNAL_PROJECT_USER_EMAIL=your-email@example.com
STACK_SEED_INTERNAL_PROJECT_USER_PASSWORD=your-strong-password
```

## 🔌 Integrating with Your Applications

### Stack Auth Integration

To connect your applications to Stack Auth:

1. Add the following environment variable to your application:
   ```
   NEXT_PUBLIC_STACK_API_URL=http://localhost:8102
   ```

2. Follow the [Stack Auth documentation](https://github.com/stack-auth/stack-auth) for client integration.

3. Create a new project in the Stack Auth Dashboard for your application.

## 🌱 Setting Up Strapi

_Step-by-step instructions for setting up and running Strapi will be provided soon._

## 🧩 Strapi Plugins

### Diajar Notes
_A clean, intuitive note-taking plugin inspired by Simplenote, Notion, and Gutenberg._

### Jamhook
_Automate the regeneration of your static sites with seamless integration to Netlify, Cloudflare Pages, and Vercel._
