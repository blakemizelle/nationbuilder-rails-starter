# NationBuilder Rails App - Setup Guide

## Prerequisites Setup (Do This First!)

### 1. Install Ruby 3.3+

#### Option A: Using Homebrew (Recommended for Mac)
```bash
# Install rbenv
brew install rbenv ruby-build

# Initialize rbenv
rbenv init
# Follow the instructions to add to your shell profile

# Install Ruby 3.3.0
rbenv install 3.3.0
rbenv local 3.3.0

# Verify
ruby --version  # Should show 3.3.0
```

#### Option B: Using RVM
```bash
# Install RVM
\curl -sSL https://get.rvm.io | bash -s stable

# Install Ruby 3.3.0
rvm install 3.3.0
rvm use 3.3.0 --default

# Verify
ruby --version  # Should show 3.3.0
```

### 2. Install Rails 7.1+
```bash
gem install rails -v '~> 7.1'

# Verify
rails --version  # Should show Rails 7.1.x
```

### 3. Install PostgreSQL

#### Mac (Homebrew):
```bash
brew install postgresql@15
brew services start postgresql@15
```

#### Or use Postgres.app:
Download from https://postgresapp.com/

### 4. Install Dependencies
```bash
gem install bundler
```

---

## Rails App Creation (Once Ruby/Rails Installed)

### Step 1: Create Rails App
```bash
cd /Users/blakemizelle/blakes_projects/nationbuilder-rails-starter/nb-rails-app

# Create Rails app with PostgreSQL and Tailwind
rails new . --database=postgresql --css=tailwind --javascript=importmap \
  --skip-test --skip-jbuilder --skip-action-mailbox \
  --skip-action-text --skip-active-storage
```

### Step 2: Install Dependencies
```bash
bundle install
```

### Step 3: Setup Database
```bash
# Create database
rails db:create

# Run migrations (we'll create these next)
rails db:migrate
```

---

## What Happens Next

Once you run the above commands, I'll provide:

1. **All Application Files** - Models, Controllers, Services, Views
2. **Database Migrations** - Installation table schema
3. **Configuration Files** - Routes, initializers, environment variables
4. **Deployment Guide** - Heroku setup step-by-step
5. **Testing Guide** - How to test the OAuth flow

---

## Quick Reference

```bash
# Start development server
rails server

# Create database
rails db:create

# Run migrations
rails db:migrate

# Rails console
rails console

# Generate migration
rails g migration MigrationName
```

---

## Troubleshooting

### "Rails not found"
- Make sure Ruby 3.3+ is installed
- Run: `gem install rails`

### "PostgreSQL connection failed"
- Make sure PostgreSQL is running
- Check: `brew services list` or `ps aux | grep postgres`

### "Bundle install fails"
- Make sure you have build tools: `xcode-select --install`

---

**Next Steps:**
1. Install Ruby 3.3+ (see above)
2. Install Rails 7.1+ (see above)
3. Run `rails new` command (see above)
4. Let me know when done - I'll provide all the application files!
