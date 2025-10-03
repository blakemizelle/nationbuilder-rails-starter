# NationBuilder Rails App - Prerequisites Setup

**Purpose**: Install Ruby, Rails, and PostgreSQL before starting development.

**Already have these installed?** Skip to [GETTING_STARTED.md](GETTING_STARTED.md)

---

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

## Verify Installation

Once installed, verify everything works:

```bash
# Check Ruby version
ruby --version
# Should show: ruby 3.3.0 or higher

# Check Rails version
rails --version
# Should show: Rails 7.2.2 or higher

# Check PostgreSQL
psql --version
# Should show: psql (PostgreSQL) 15.x or higher

# Test PostgreSQL connection
psql postgres -c "SELECT version();"
# Should connect without errors
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

## Next Steps

✅ Once all prerequisites are installed and verified:

1. **Continue to [GETTING_STARTED.md](GETTING_STARTED.md)** for application setup
2. **Or see [README.md](README.md)** for a quick overview

---

## Need Help?

- **Ruby Installation Issues**: [Ruby Install Guide](https://www.ruby-lang.org/en/documentation/installation/)
- **Rails Installation Issues**: [Rails Getting Started](https://guides.rubyonrails.org/getting_started.html)
- **PostgreSQL Issues**: [PostgreSQL Downloads](https://www.postgresql.org/download/)
