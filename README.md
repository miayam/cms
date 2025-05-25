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
pnpm stack-auth:dev

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
# Start Strapi in development mode (dependencies + native)
pnpm strapi:dev

# Stop Strapi containers
pnpm strapi:stop

# Restart Strapi containers
pnpm strapi:restart

# View Strapi logs
pnpm strapi:logs

# View Strapi database logs
pnpm strapi:logs:db

# Access Strapi database shell (PostgreSQL)
pnpm strapi:db-shell

# Clean up Strapi containers and volumes
pnpm strapi:clean

# Reset Strapi database (WARNING: This will delete all data)
pnpm strapi:reset
```

## 📦 Structure

```
cms/
├── apps/                           # Your applications
│   └── strapi/                     # Strapi CMS
│       ├── src/
│       │   ├── api/                # Strapi API routes
│       │   ├── components/         # Strapi components
│       │   ├── extensions/         # Strapi extensions
│       │   └── plugins/            # Custom Strapi plugins
│       ├── config/                 # Strapi configuration
│       ├── docker-compose.dev.yml  # Strapi Docker setup for development
│       ├── docker-compose.prod.yml # Strapi Docker setup for production
│       ├── Dockerfile              # Strapi Docker image for production
│       ├── .env.example            # Strapi environment template
│       ├── setup-strapi-env.sh     # Generate .env for development
│       └── package.json
├── docker/
│   └── stack-auth/                 # Stack Auth configuration
│       ├── docker-compose.yml
│       ├── .env.template           # Environment config template
│       ├── .env                    # Environment config (create from .env.template)
│       └── run-stack-auth.sh
├── packages/                       # Shared packages
│   ├── diajar-notes/               # Notes-taking plugin for Strapi (shared publicly)
│   ├── jamhook/                    # Jamstack build management
│   └── ...
├── package.json
└── pnpm-workspace.yaml
```

## ⚙️ Configuration

### 🔧 Setting Up Stack Auth

1. Initialize Stack Auth with automatically generated secure keys:
   ```bash
   pnpm stack-auth:init
   ```

2. Your Stack Auth `.env` file will include these essential configurations:

```env
# Core URLs
NEXT_PUBLIC_STACK_API_URL=http://localhost:8102
NEXT_PUBLIC_STACK_DASHBOARD_URL=http://localhost:8101

# Database connection
DATABASE_URL=postgresql://stack_auth:stack_auth_password@postgres:5432/stack_auth

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

3. Review and customize the generated `.env` file if needed

### 🏗️ Setting Up Strapi

1. Initialize Strapi with automatically generated secure keys:
   ```bash
   pnpm strapi:init
   ```

2. Your Strapi `.env` file will include:

```env
# Server Configuration
HOST=0.0.0.0
PORT=1337
APP_KEYS=YOUR_GENERATED_APP_KEYS
API_TOKEN_SALT=YOUR_GENERATED_API_TOKEN_SALT
ADMIN_JWT_SECRET=YOUR_GENERATED_ADMIN_JWT_SECRET
TRANSFER_TOKEN_SALT=YOUR_GENERATED_TRANSFER_TOKEN_SALT
JWT_SECRET=YOUR_GENERATED_JWT_SECRET

# Database Configuration (for development with Docker dependencies)
DATABASE_CLIENT=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5433
DATABASE_NAME=strapi
DATABASE_USERNAME=strapi
DATABASE_PASSWORD=strapi
DATABASE_SSL=false

# Environment
NODE_ENV=development
```

3. Review and customize the generated `.env` file if needed

4. Start Strapi services:
   ```bash
   pnpm strapi:dev
   ```

5. Access Strapi admin panel at http://localhost:1337/admin and create your first admin user.

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
- **Strapi Admin Panel**: http://localhost:1337/admin
- **Strapi API**: http://localhost:1337/api
- **Email Testing UI**: http://localhost:8105 (development only)
- **Stack Auth PostgreSQL**: `postgresql://localhost:5432`
- **Strapi PostgreSQL**: `postgresql://localhost:5433`

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

1. **Port conflicts**: Make sure ports 1337, 5433, 8101, 8102, 8105, and 8071 are available.

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
