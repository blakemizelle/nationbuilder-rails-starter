# Heroku Deployment Guide

Complete guide to deploying your NationBuilder Rails app to Heroku.

---

## Prerequisites

- Heroku CLI installed ([Get it here](https://devcenter.heroku.com/articles/heroku-cli))
- Heroku account
- NationBuilder OAuth app configured

---

## Step-by-Step Deployment

### 1. Login to Heroku

```bash
heroku login
```

### 2. Create Heroku App

```bash
# Create app (Heroku will generate a name)
heroku create

# Or with custom name
heroku create your-app-name

# Note the app URL (e.g., https://your-app-name.herokuapp.com)
```

### 3. Add PostgreSQL

```bash
# Add PostgreSQL database
heroku addons:create heroku-postgresql:mini

# Verify it was added
heroku addons
```

### 4. Configure Environment Variables

```bash
# Set NationBuilder OAuth credentials
heroku config:set NB_CLIENT_ID=your_client_id_here
heroku config:set NB_CLIENT_SECRET=your_client_secret_here

# Set redirect URI (use your actual Heroku app URL)
heroku config:set NB_REDIRECT_URI=https://your-app-name.herokuapp.com/oauth/callback

# ⚠️ CRITICAL: Set Rails master key for credentials decryption
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)

# Verify all config vars are set
heroku config
```

**Why RAILS_MASTER_KEY is needed**: Your app uses Rails encrypted credentials to store the database encryption keys. Without the master key, Heroku can't decrypt these credentials and token encryption will fail.

### 5. Update NationBuilder OAuth App

1. Go to your NationBuilder admin: Settings → API
2. Edit your OAuth Application
3. Update **Redirect URI** to match Heroku:
   ```
   https://your-app-name.herokuapp.com/oauth/callback
   ```
4. Save changes

### 6. Deploy to Heroku

```bash
# Push code to Heroku
git push heroku main

# Or if on a different branch
git push heroku your-branch:main
```

### 7. Run Database Migrations

```bash
# This should happen automatically via Procfile's release command
# But you can manually run it:
heroku run rails db:migrate
```

### 8. Open Your App

```bash
heroku open
```

---

## Testing the Deployment

### 1. Test OAuth Flow

Visit your app:
```
https://your-app-name.herokuapp.com/?nation=yourslug
```

Should redirect to NationBuilder OAuth → authorize → redirect back → dashboard

### 2. Check Logs

```bash
# View real-time logs
heroku logs --tail

# View last 500 lines
heroku logs -n 500

# Filter for errors
heroku logs --tail | grep ERROR
```

### 3. Verify Database

```bash
# Open Rails console on Heroku
heroku run rails console

# Check installations
> Installation.count
> Installation.first
> Installation.active.pluck(:nation_slug)
```

---

## Common Deployment Issues

### Issue: "Push rejected"

**Error**: `! [remote rejected] main -> main (pre-receive hook declined)`

**Fix**:
```bash
# Make sure all changes are committed
git add -A
git commit -m "Fix deployment"
git push heroku main
```

### Issue: "Database does not exist"

**Error**: `ActiveRecord::NoDatabaseError`

**Fix**:
```bash
# Ensure PostgreSQL addon is added
heroku addons:create heroku-postgresql:mini

# Run migrations
heroku run rails db:migrate
```

### Issue: "Missing NB_CLIENT_ID"

**Error**: `KeyError (key not found: "NB_CLIENT_ID")`

**Fix**:
```bash
# Set all required config vars
heroku config:set NB_CLIENT_ID=xxx
heroku config:set NB_CLIENT_SECRET=xxx
heroku config:set NB_REDIRECT_URI=https://yourapp.herokuapp.com/oauth/callback
```

### Issue: "Invalid redirect URI"

**Error**: OAuth error from NationBuilder

**Fix**:
1. Check Heroku app URL: `heroku info`
2. Update NB OAuth app redirect URI to match exactly
3. Ensure no trailing slashes
4. Check http vs https (must be https on Heroku)

### Issue: "Application Error (500)"

**Fix**:
```bash
# Check logs for details
heroku logs --tail

# Common causes:
# - Missing config vars
# - Database not migrated
# - Assets not precompiled

# Force asset precompile
heroku run rails assets:precompile
```

---

## Monitoring & Maintenance

### View App Info

```bash
# App details
heroku info

# Dynos status
heroku ps

# Database info
heroku pg:info
```

### Database Backups

```bash
# Create backup
heroku pg:backups:capture

# Download backup
heroku pg:backups:download

# Schedule automatic backups (requires paid plan)
heroku pg:backups:schedule DATABASE_URL --at '02:00 America/Los_Angeles'
```

### Scaling

```bash
# Scale web dynos (requires payment beyond 1 dyno)
heroku ps:scale web=2

# Scale down
heroku ps:scale web=1
```

### Restart App

```bash
# Restart all dynos
heroku restart

# Restart specific dyno type
heroku restart web
```

---

## Environment-Specific Config

### Development Environment

```bash
# Local .env file (gitignored)
NB_CLIENT_ID=dev_client_id
NB_CLIENT_SECRET=dev_client_secret
NB_REDIRECT_URI=http://localhost:3000/oauth/callback
```

### Staging Environment

```bash
# Create staging app
heroku create your-app-staging --remote staging

# Deploy to staging
git push staging main

# Set staging config
heroku config:set NB_CLIENT_ID=staging_client_id --remote staging
```

### Production Environment

```bash
# Production app (default)
git push heroku main

# Production config
heroku config:set NB_CLIENT_ID=production_client_id
```

---

## Performance Optimization

### 1. Enable Rack Timeout (optional)

```bash
# Add to Gemfile
gem 'rack-timeout'

# Set timeout
heroku config:set RACK_TIMEOUT_SERVICE_TIMEOUT=15
```

### 2. Database Connection Pooling

Already configured in `config/database.yml`:
```yaml
production:
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

### 3. CDN for Assets (optional)

Use Cloudflare or CloudFront to serve static assets.

---

## Security Checklist

- [ ] All sensitive config in Heroku config vars (not .env)
- [ ] HTTPS enforced (automatic on Heroku)
- [ ] Tokens encrypted in database (via Rails)
- [ ] NB OAuth app redirect URI matches exactly
- [ ] CORS configured if needed
- [ ] Rate limiting considered (if needed)

---

## Cost Estimation

### Eco Dyno (Recommended for small apps)
- **Web Dyno**: $5/month
- **PostgreSQL Mini**: $5/month
- **Total**: $10/month

### Free Tier (Limited hours)
- **Web Dyno**: Free (550-1000 hrs/month)
- **PostgreSQL Mini**: $5/month
- **Total**: $5/month (but dyno sleeps after 30 min inactivity)

---

## Useful Heroku Commands

```bash
# Logs
heroku logs --tail                 # Real-time logs
heroku logs --source app           # App logs only
heroku logs --ps web.1             # Specific dyno

# Rails Console
heroku run rails console           # Open console
heroku run rails db:migrate        # Run migrations
heroku run rails db:seed           # Seed database

# Database
heroku pg:psql                     # Connect to database
heroku pg:info                     # Database stats
heroku pg:reset DATABASE_URL       # Reset database (dangerous!)

# Config
heroku config                      # View all config vars
heroku config:get NB_CLIENT_ID     # Get specific var
heroku config:unset VARIABLE_NAME  # Remove config var

# Apps
heroku apps:info                   # App info
heroku apps:destroy --app appname  # Delete app (careful!)
heroku apps:rename newname         # Rename app
```

---

## Next Steps After Deployment

1. **Test OAuth Flow** - Try installing from different nations
2. **Monitor Logs** - Watch for errors during first uses
3. **Set Up Monitoring** - Consider Papertrail or LogDNA
4. **Enable SSL** - Automatic on Heroku, verify it works
5. **Configure Domain** - Add custom domain if needed
6. **Schedule Backups** - Set up database backups
7. **Add Staging** - Create staging environment for testing

---

## Troubleshooting Resources

- [Heroku Rails Guide](https://devcenter.heroku.com/articles/getting-started-with-rails7)
- [Heroku Logs](https://devcenter.heroku.com/articles/logging)
- [PostgreSQL on Heroku](https://devcenter.heroku.com/articles/heroku-postgresql)
- [Rails on Heroku](https://devcenter.heroku.com/categories/ruby-support)

---

## Emergency Rollback

If deployment breaks production:

```bash
# Rollback to previous release
heroku rollback

# Or rollback to specific version
heroku releases
heroku rollback v123
```

---

**You're ready to deploy! 🚀**

Run through the steps above and your NationBuilder app will be live on Heroku.
