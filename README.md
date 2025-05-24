# CMS Monorepo (WIP)

An all-in-one, self-hosted CMS platform for your side hustles (blogging, newsletters, subscription courses, membership sites, digital products, etc.) powered by Strapi and Stack Auth.

## 🚀 Quick Start

```bash
# Install dependencies
pnpm install

# Initialize .env in development mode for Stack Auth and Strapi
pnpm bootstrap

# Start Stack Auth and Strapi in development mode
pnpm dev
```

## 📋 Available Commands

### 🔑 Stack Auth Commands

```bash
# Start Stack Auth in development mode (uses Inbucket for email)
pnpm stack-auth:start

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

### 🏗️ Strapi Commands

```bash
# Start Strapi in development mode
pnpm strapi:dev

# Start Strapi in production mode
pnpm strapi:start

# Build Strapi for production
pnpm strapi:build

# Stop Strapi containers
pnpm strapi:stop

# View Strapi logs
pnpm strapi:logs

# Access Strapi database shell (PostgreSQL)
pnpm strapi:db-shell

# Clean up Strapi containers and volumes
pnpm strapi:clean

# Reset Strapi database (WARNING: This will delete all data)
pnpm strapi:reset

# Generate Strapi admin user
pnpm strapi:admin
```

## 📦 Structure

```
cms/
├── apps/                       # Your applications
│   └── strapi/                 # Strapi CMS
│       ├── src/
│       │   ├── api/            # Strapi API routes
│       │   ├── components/     # Strapi components
│       │   ├── extensions/     # Strapi extensions
│       │   └── plugins/        # Custom Strapi plugins
│       ├── config/             # Strapi configuration
│       ├── docker-compose.yml  # Strapi Docker setup
│       ├── Dockerfile          # Strapi Docker image
│       ├── .env.example        # Strapi environment template
│       ├── setup-strapi-env.sh # Generate .env for development
│       └── package.json
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

### 🔧 Setting Up Stack Auth

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

4. Your `.env` file should include these essential configurations:

```env
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

# Seed script settings
STACK_SEED_INTERNAL_PROJECT_SIGN_UP_ENABLED=true
STACK_SEED_INTERNAL_PROJECT_OTP_ENABLED=false
STACK_SEED_INTERNAL_PROJECT_ALLOW_LOCALHOST=true
STACK_SEED_INTERNAL_PROJECT_USER_EMAIL=admin@example.com
STACK_SEED_INTERNAL_PROJECT_USER_PASSWORD=StrongPassword123
STACK_SEED_INTERNAL_PROJECT_USER_INTERNAL_ACCESS=true
```

### 🏗️ Setting Up Strapi

1. Create `.env` file from example:
   ```bash
   cp apps/strapi/.env.example apps/strapi/.env
   ```

2. Generate required secure keys for Strapi:

   a. For `JWT_SECRET`:
   ```bash
   openssl rand -base64 32
   ```

   b. For `ADMIN_JWT_SECRET`:
   ```bash
   openssl rand -base64 32
   ```

   c. For `APP_KEYS` (generate 4 keys):
   ```bash
   echo "$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32),$(openssl rand -base64 32)"
   ```

3. Your Strapi `.env` file should include:

```env
# Secrets
JWT_SECRET=YOUR_GENERATED_JWT_SECRET
ADMIN_JWT_SECRET=YOUR_GENERATED_ADMIN_JWT_SECRET
APP_KEYS=YOUR_GENERATED_APP_KEYS

# Database
DATABASE_CLIENT=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5433
DATABASE_NAME=strapi
DATABASE_USERNAME=strapi
DATABASE_PASSWORD=strapi

# Environment
NODE_ENV=development
```

4. Start Strapi services:
   ```bash
   pnpm strapi:dev
   ```

5. Access Strapi admin panel at http://localhost:1338/admin and create your first admin user.

### 📧 Email Configuration

#### 🧪 Development (Default)

The default configuration uses Inbucket for development, which captures all emails locally:

- Access emails at: http://localhost:8105
- No real emails are sent

#### 🚀 Production

For production, edit `docker/stack-auth/.env` and update the email settings:

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
- **Strapi Admin Panel**: http://localhost:1338/admin
- **Strapi API**: http://localhost:1338/api
- **Email Testing UI**: http://localhost:8105 (development only)
- **Stack Auth PostgreSQL**: `postgresql://localhost:5432`
- **Strapi PostgreSQL**: `postgresql://localhost:5434`

## 🔑 Default Admin Credentials

### Stack Auth
When Stack Auth starts for the first time, it creates a default admin user:
- **Email**: admin@example.com
- **Password**: StrongPassword123

You can change these credentials in your `.env` file by updating:
```env
STACK_SEED_INTERNAL_PROJECT_USER_EMAIL=your-email@example.com
STACK_SEED_INTERNAL_PROJECT_USER_PASSWORD=your-strong-password
```

### Strapi
When you first access the Strapi admin panel, you'll be prompted to create an admin user. No default credentials are provided for security reasons.

## 🧩 Strapi Plugins

### 📝 Diajar Notes
_A clean, intuitive note-taking plugin inspired by Simplenote, Notion, and Gutenberg._

### 🚀 Jamhook
_Automate the regeneration of your static sites with seamless integration to Netlify, Cloudflare Pages, and Vercel._

## 🛠️ Troubleshooting

#### ⚠️ Common Issues

1. **Port conflicts**: Make sure ports 1338, 5433, 8101, 8102, 8105, and 8071 are available.

2. **Database connection issues**:
   - Check if PostgreSQL containers are running
   - Verify database credentials in `.env` files
   - Ensure network connectivity between containers

3. **Stack Auth integration issues**:
   - Verify API keys and endpoints
   - Check CORS settings in both Stack Auth and Strapi

4. **Plugin development issues**:
   - Run `pnpm strapi:build` after making changes
   - Check plugin registration in `config/plugins.js`
   - Verify plugin dependencies are installed

#### 🔍 Logs and Debugging

```bash
# View all services logs
pnpm stack-auth:logs
pnpm strapi:logs

# Access database shells for debugging
pnpm stack-auth:db-shell
pnpm strapi:db-shell
```

---

## 📚 Additional Resources

- [Stack Auth Documentation](https://docs.stack-auth.com)
- [Strapi Documentation](https://docs.strapi.io)
- [Strapi Plugin Development](https://docs.strapi.io/developer-docs/latest/plugin-development/quick-start.html)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
