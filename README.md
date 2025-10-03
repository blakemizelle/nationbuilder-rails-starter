# NationBuilder Rails Starter

A production-ready Rails application for building NationBuilder App Store integrations. Features OAuth 2.0 with PKCE, multi-tenant support, and persistent token storage in PostgreSQL.

## Features

✅ **OAuth 2.0 with PKCE** - Secure authentication flow  
✅ **Multi-Tenant** - Nation-based token storage  
✅ **PostgreSQL** - Persistent installations with encrypted tokens  
✅ **Auto Token Refresh** - Seamless experience  
✅ **NationBuilder API v2** - Integrated client  
✅ **Modern UI** - Tailwind CSS dashboard  
✅ **Heroku Ready** - One-command deployment  

---

## Quick Start (Local Development)

### 1. Prerequisites

- Ruby 3.3.0 (via rbenv/rvm)
- PostgreSQL 15+
- NationBuilder OAuth App credentials

**New to Ruby/Rails?** See [SETUP.md](SETUP.md) for detailed installation instructions.

### 2. Install Dependencies

```bash
bundle install
```

### 3. Configure Environment

**Set Heroku config vars (recommended for production):**

```bash
# On Heroku
heroku config:set NB_CLIENT_ID=your_client_id
heroku config:set NB_CLIENT_SECRET=your_client_secret
heroku config:set NB_REDIRECT_URI=https://yourapp.herokuapp.com/oauth/callback
```

**For local development only, create `.env`:**

```bash
# .env (local development only - NOT for production)
NB_CLIENT_ID=your_client_id
NB_CLIENT_SECRET=your_client_secret
NB_REDIRECT_URI=http://localhost:3000/oauth/callback
```

### 4. Setup Database

```bash
rails db:create
rails db:migrate
```

### 5. Start Server

```bash
./bin/dev  # Runs Rails + Tailwind CSS compiler
```

Visit: `http://localhost:3000/?nation=yourslug`

---

## NationBuilder OAuth App Setup

1. Go to your NationBuilder Settings → API
2. Create OAuth Application
3. Set **Redirect URI**: 
   - Local: `http://localhost:3000/oauth/callback`
   - Production: `https://yourapp.herokuapp.com/oauth/callback`
4. Copy **Client ID** and **Client Secret**
5. Configure as Heroku config vars (see above)

---

## Architecture

### Models
- **Installation** - Stores OAuth tokens per nation (encrypted)

### Services
- **OAuth::PkceGenerator** - PKCE code generation
- **OAuth::TokenService** - Token exchange & refresh
- **OAuth::AuthenticationService** - OAuth flow orchestration
- **NationBuilder::ApiClient** - API wrapper with auto-refresh

### Controllers
- **OAuthController** - Handles install/callback/uninstall
- **DashboardController** - Shows connected user info

### Routes
```ruby
GET  /                  # Install (redirects to OAuth or dashboard)
GET  /oauth/callback    # OAuth callback handler
DELETE /uninstall       # Uninstall app
GET  /dashboard         # Show connection status & user info
```

---

## How It Works

### Installation Flow

1. **User clicks "Install" on NB App Store**
   ```
   Redirects to: https://yourapp.com/?nation=myorg
   ```

2. **App checks if already installed**
   - If yes → Dashboard
   - If no → OAuth flow

3. **OAuth Authentication**
   - Generate PKCE pair
   - Redirect to NationBuilder OAuth
   - User authorizes
   - NationBuilder redirects back with code

4. **Token Exchange & Storage**
   - Exchange code for tokens
   - Store in PostgreSQL (encrypted)
   - Nation is now "installed"

5. **Persistent Access**
   - Tokens stored by nation_slug
   - Works across sessions/browsers
   - Auto-refresh on expiry

### Uninstall Flow

User clicks "Uninstall" → Soft delete in database → Can reinstall later

---

## Database Schema

```ruby
create_table "installations" do |t|
  t.string :nation_slug, null: false, index: { unique: true }
  t.string :access_token, null: false  # Encrypted
  t.string :refresh_token, null: false  # Encrypted
  t.datetime :expires_at, null: false
  t.string :token_type, default: "Bearer"
  t.string :scope
  t.string :status, default: "active"
  t.datetime :installed_at, null: false
  t.datetime :last_used_at, null: false
  t.datetime :uninstalled_at
  t.jsonb :metadata, default: {}
  t.timestamps
end
```

---

## Heroku Deployment

### 1. Create Heroku App

```bash
heroku create your-app-name
```

### 2. Add PostgreSQL

```bash
heroku addons:create heroku-postgresql:mini
```

### 3. Set Config Vars

```bash
heroku config:set NB_CLIENT_ID=your_client_id
heroku config:set NB_CLIENT_SECRET=your_client_secret
heroku config:set NB_REDIRECT_URI=https://your-app-name.herokuapp.com/oauth/callback
```

### 4. Deploy

```bash
git push heroku main
```

### 5. Run Migrations

```bash
heroku run rails db:migrate
```

### 6. Open App

```bash
heroku open
```

---

## Testing the OAuth Flow

### Local Testing

1. Start server: `./bin/dev`
2. Visit: `http://localhost:3000/?nation=yourslug`
3. Click through OAuth flow
4. Should see dashboard with user info

### Production Testing

1. Deploy to Heroku (see above)
2. Update NB OAuth app redirect URI
3. Visit: `https://yourapp.herokuapp.com/?nation=yourslug`
4. Complete OAuth flow
5. Verify dashboard shows user data

---

## API Usage

### Fetch User Info

```ruby
# In a controller
client = NationBuilder::ApiClient.new(session[:nation_slug])
user_info = client.signups.me

# Returns:
{
  "id" => 123,
  "username" => "user",
  "email" => "user@example.com",
  "full_name" => "User Name",
  ...
}
```

### Add More API Endpoints

```ruby
# app/services/nation_builder/api_client.rb

def people
  @people ||= PeopleApi.new(self)
end

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

---

## Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `NB_CLIENT_ID` | OAuth Client ID | ✅ | `abc123...` |
| `NB_CLIENT_SECRET` | OAuth Client Secret | ✅ | `secret...` |
| `NB_REDIRECT_URI` | OAuth Callback URL | ✅ | `https://yourapp.com/oauth/callback` |
| `DATABASE_URL` | PostgreSQL connection | Auto (Heroku) | `postgresql://...` |
| `RAILS_MASTER_KEY` | Credentials encryption | Auto (Rails) | Generated |

**Note:** Use Heroku config vars in production. Never commit secrets to Git.

---

## Security Features

- ✅ **PKCE** - Proof Key for Code Exchange (OAuth 2.1 standard)
- ✅ **State Parameter** - CSRF protection
- ✅ **Encrypted Tokens** - Rails 7 built-in encryption at rest
- ✅ **Secure Sessions** - HTTPOnly cookies
- ✅ **Token Rotation** - Auto-refresh on expiry
- ✅ **HTTPS Only** - Enforced in production

---

## Troubleshooting

### "Invalid redirect URI"
- Ensure NB OAuth app redirect URI matches exactly
- Check http vs https
- No trailing slashes

### "Invalid state parameter"
- Clear browser cookies
- Session may have expired during OAuth flow
- Restart browser and try again

### "Token exchange failed"
- Verify `NB_CLIENT_ID` and `NB_CLIENT_SECRET`
- Check NB OAuth app is active
- Ensure PKCE is enabled

### "Nation not installed"
- Complete OAuth flow first
- Check database has installation record:
  ```bash
  heroku run rails console
  > Installation.all
  ```

### PostgreSQL connection failed (local)
```bash
# Start PostgreSQL
brew services start postgresql@15

# Or if using Postgres.app
# Make sure Postgres.app is running
```

---

## Project Structure

```
app/
├── controllers/
│   ├── o_auth_controller.rb        # OAuth flow
│   └── dashboard_controller.rb     # Post-auth UI
│
├── models/
│   └── installation.rb             # Token storage
│
├── services/
│   ├── oauth/
│   │   ├── pkce_generator.rb       # PKCE generation
│   │   ├── token_service.rb        # Token exchange/refresh
│   │   └── authentication_service.rb  # OAuth orchestration
│   └── nation_builder/
│       └── api_client.rb           # NB API wrapper
│
└── views/
    └── dashboard/
        └── show.html.erb           # Dashboard UI
```

---

## What's Next?

### Extend the Integration

1. **Add More API Endpoints**
   - People, Events, Donations, etc.
   - See `app/services/nation_builder/api_client.rb`

2. **Build Features**
   - Data sync
   - Reporting dashboard
   - Webhook receivers (optional)
   - Background jobs

3. **Scale Up**
   - Add Redis for caching
   - Background job processing (Sidekiq)
   - Admin interface

---

## Support

- [NationBuilder API Docs](https://support.nationbuilder.com/en/articles/9899245-api-v2-walkthrough)
- [OAuth 2.0 Spec](https://oauth.net/2/)
- [PKCE RFC](https://datatracker.ietf.org/doc/html/rfc7636)
- [Rails Guides](https://guides.rubyonrails.org/)

---

## License

MIT License - see LICENSE file for details

---

**Built with ❤️ for the NationBuilder community**
