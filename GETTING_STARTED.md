# Getting Started - NationBuilder Rails App

## 🎉 Your App is Built!

You now have a fully-functional NationBuilder OAuth integration built with Rails 7, PostgreSQL, and Tailwind CSS.

**Prerequisites**: This guide assumes Ruby 3.3+, Rails 7.2+, and PostgreSQL 15+ are already installed. If not, see [SETUP.md](SETUP.md) first.

---

## What Was Built

### ✅ Core Features
- OAuth 2.0 with PKCE authentication
- Multi-tenant nation-based installation
- PostgreSQL database with encrypted tokens
- NationBuilder API v2 client with auto-refresh
- Modern Tailwind CSS dashboard
- Heroku-ready deployment config

### ✅ Architecture
- **Model**: Installation (encrypted tokens)
- **Services**: OAuth (PKCE, Token, Auth), NationBuilder API Client
- **Controllers**: OAuth flow, Dashboard
- **Views**: Beautiful Tailwind UI

### ✅ Security
- PKCE for OAuth 2.1 compliance
- State parameter (CSRF protection)
- Encrypted tokens at rest (Rails 7)
- Secure session cookies
- HTTPS enforced in production

---

## Next Steps

### 1. Test Locally (15 minutes)

#### A. Get NationBuilder OAuth Credentials

1. Go to your NationBuilder admin
2. Settings → API → OAuth Applications
3. Create new OAuth Application:
   - **Name**: Your App Name
   - **Redirect URI**: `http://localhost:3000/oauth/callback`
   - **Scopes**: default (or specific scopes)
4. Copy **Client ID** and **Client Secret**

#### B. Configure Environment

**Step 1: Generate encryption keys**

```bash
bin/rails db:encryption:init
```

This outputs three keys. Copy the entire `active_record_encryption` block.

**Step 2: Add to Rails credentials**

```bash
EDITOR="nano" bin/rails credentials:edit
# Or use your preferred editor: code, vim, etc.
```

Paste the encryption keys into the file:

```yaml
active_record_encryption:
  primary_key: YOUR_PRIMARY_KEY
  deterministic_key: YOUR_DETERMINISTIC_KEY
  key_derivation_salt: YOUR_KEY_DERIVATION_SALT
```

Save and exit.

**Step 3: Create `.env` file**

Create `.env` file in project root with your NationBuilder OAuth credentials:

```bash
NB_CLIENT_ID=your_client_id_here
NB_CLIENT_SECRET=your_client_secret_here
NB_REDIRECT_URI=http://localhost:3000/oauth/callback
```

**Note**: `dotenv-rails` is already in the Gemfile, so no need to add it.

#### C. Start the App

```bash
# Start Rails + Tailwind
./bin/dev

# Visit in browser
open http://localhost:3000/
```

**You'll see a landing page with two options:**

**Option 1: Use the form**
1. Enter your nation slug (e.g., "myorg")
2. Click "Connect Nation"
3. Redirects to NationBuilder OAuth

**Option 2: Use direct URL**
```
http://localhost:3000/?nation=yourslug
```

#### D. Test OAuth Flow

1. Enter nation slug or visit with `?nation=` parameter
2. Redirected to NationBuilder to authorize
3. Click "Authorize"
4. Redirected back to dashboard
5. See your user info from NB API

**Test multi-tenant:** Open an incognito window and connect a different nation - both work simultaneously!

---

### 2. Deploy to Heroku (30 minutes)

Follow the comprehensive guide in **[HEROKU_DEPLOY.md](HEROKU_DEPLOY.md)**

Quick version:

```bash
# 1. Create Heroku app
heroku create your-app-name

# 2. Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# 3. Set config vars
heroku config:set NB_CLIENT_ID=xxx
heroku config:set NB_CLIENT_SECRET=xxx
heroku config:set NB_REDIRECT_URI=https://your-app-name.herokuapp.com/oauth/callback

# 4. Deploy
git push heroku main

# 5. Open app
heroku open
```

**Don't forget**: Update NB OAuth app redirect URI to Heroku URL!

---

### 3. Extend the Integration

#### Add More NationBuilder API Endpoints

Edit `app/services/nation_builder/api_client.rb`:

```ruby
def people
  @people ||= PeopleApi.new(self)
end

def events
  @events ||= EventsApi.new(self)
end
```

Create corresponding API wrappers:

```ruby
# app/services/nation_builder/people_api.rb
class NationBuilder::PeopleApi
  def initialize(client)
    @client = client
  end
  
  def list(params = {})
    @client.get("/api/v2/people", params: params)
  end
  
  def find(id)
    @client.get("/api/v2/people/#{id}")
  end
end
```

#### Build New Features

Ideas:
- Data sync from NationBuilder
- Reporting dashboard
- Export tools
- Custom integrations
- Webhook receivers (optional)
- Background jobs for async processing

---

## File Structure Quick Reference

```
app/
├── controllers/
│   ├── o_auth_controller.rb        # OAuth install/callback/uninstall
│   └── dashboard_controller.rb     # Shows user info
│
├── models/
│   └── installation.rb             # Stores encrypted tokens
│
├── services/
│   ├── oauth/
│   │   ├── pkce_generator.rb       # Generate PKCE pair
│   │   ├── token_service.rb        # Exchange code, refresh tokens
│   │   └── authentication_service.rb  # Orchestrate OAuth flow
│   └── nation_builder/
│       └── api_client.rb           # NB API wrapper with auto-refresh
│
└── views/
    └── dashboard/
        └── show.html.erb           # Dashboard UI
```

---

## Environment Variables

### Development (.env file)
```bash
NB_CLIENT_ID=dev_client_id
NB_CLIENT_SECRET=dev_client_secret
NB_REDIRECT_URI=http://localhost:3000/oauth/callback
```

### Production (Heroku config vars)
```bash
heroku config:set NB_CLIENT_ID=prod_client_id
heroku config:set NB_CLIENT_SECRET=prod_client_secret
heroku config:set NB_REDIRECT_URI=https://yourapp.herokuapp.com/oauth/callback
```

**Important**: NEVER commit .env file to Git! It's gitignored by default.

---

## Common Commands

### Development
```bash
# Start server with Tailwind
./bin/dev

# Rails console
rails console

# Database
rails db:migrate
rails db:rollback
rails db:reset

# Routes
rails routes | grep oauth
```

### Production (Heroku)
```bash
# Logs
heroku logs --tail

# Console
heroku run rails console

# Database
heroku pg:info
heroku run rails db:migrate

# Restart
heroku restart
```

---

## Troubleshooting

### OAuth Flow Issues

**Problem**: "Invalid redirect URI"  
**Solution**: Ensure NB OAuth app redirect URI matches exactly (check http vs https, trailing slashes)

**Problem**: "Invalid state parameter"  
**Solution**: Clear browser cookies, session may have expired

**Problem**: "Missing nation parameter"  
**Solution**: URL must include `?nation=yourslug`

### Database Issues

**Problem**: "ActiveRecord::NoDatabaseError"  
**Solution**: Run `rails db:create` then `rails db:migrate`

**Problem**: Encrypted tokens error  
**Solution**: Ensure `config/master.key` exists (created by Rails)

### API Issues

**Problem**: "Nation not installed"  
**Solution**: Complete OAuth flow first, check Installation.all in console

**Problem**: "Token expired"  
**Solution**: Should auto-refresh, check logs for refresh errors

---

## Resources

### Documentation
- **[README.md](README.md)** - Complete documentation
- **[HEROKU_DEPLOY.md](HEROKU_DEPLOY.md)** - Deployment guide
- **[GitHub Repo](https://github.com/blakemizelle/nationbuilder-rails-starter)** - Source code

### External Resources
- [NationBuilder API Docs](https://support.nationbuilder.com/en/articles/9899245-api-v2-walkthrough)
- [OAuth 2.0 Spec](https://oauth.net/2/)
- [PKCE RFC](https://datatracker.ietf.org/doc/html/rfc7636)
- [Rails Guides](https://guides.rubyonrails.org/)

---

## Support & Help

### Check Logs
```bash
# Development
tail -f log/development.log

# Production
heroku logs --tail --source app
```

### Database Console
```bash
# Development
rails console
> Installation.all
> Installation.active.count

# Production
heroku run rails console
> Installation.all
```

### GitHub Issues
Open an issue on GitHub if you encounter problems:
https://github.com/blakemizelle/nationbuilder-rails-starter/issues

---

## What's Next?

1. ✅ **Test locally** - Verify OAuth flow works
2. ✅ **Deploy to Heroku** - Get it live
3. ✅ **Add features** - Build your integration
4. ✅ **Monitor** - Watch logs and usage
5. ✅ **Iterate** - Improve based on feedback

---

## Success Checklist

- [ ] OAuth flow works locally
- [ ] Dashboard shows user info
- [ ] Deployed to Heroku
- [ ] Production OAuth flow works
- [ ] NB OAuth app configured correctly
- [ ] Logs show no errors
- [ ] Ready to build features!

---

**🎉 Congratulations! You've built a production-ready NationBuilder integration!**

Start building amazing features on top of this foundation. The hard part (OAuth, tokens, database) is done!
