# MAAPs - Market Agricultural Analytics and Prediction System

A comprehensive agricultural market analytics platform with ordering system, user authentication, and admin panel.

## Features

- **User Authentication** - Register and login with Supabase integration
- **Product Catalog** - Browse agricultural products with search and filtering
- **Shopping Cart** - Add products, manage quantities, checkout
- **Order Management** - Place orders with GCash or Cash payment
- **Order Tracking** - Track order status with timeline view (like Shopee)
- **Admin Panel** - Manage orders, update statuses, view analytics
- **Market Analytics** - Price predictions and market insights

## Tech Stack

- **Frontend**: HTML, CSS, JavaScript (Single Page Application)
- **Backend**: Supabase (Authentication & Database)
- **Styling**: Custom CSS with modern UI/UX
- **Icons**: Font Awesome

## Getting Started

### Prerequisites

- A Supabase account and project
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/OsirisXx/MAAps.git
cd MAAps
```

2. Configure Supabase:
   - Create a new Supabase project
   - Run the SQL schema from `supabase-schema.sql` in the SQL Editor
   - Update the Supabase URL and anon key in `maaps-website.html`

3. Deploy to Vercel or serve locally

### Local Development

You can serve the site locally using Python:
```bash
python -m http.server 8080
```

Then open http://localhost:8080/maaps-website.html

## Deployment

This project is ready for deployment on Vercel:

1. Connect your GitHub repository to Vercel
2. Deploy with default settings
3. The site will be live!

## Project Structure

```
├── maaps-website.html    # Main application (SPA)
├── supabase-schema.sql   # Database schema for Supabase
├── SUPABASE_SETUP.md     # Supabase setup guide
├── vercel.json           # Vercel deployment config
└── README.md             # This file
```

## Default Admin Account

For demo purposes:
- Email: `admin@admin.com`
- Password: Any password (6+ characters)

## License

MIT License

## Authors

- Nova Tech Inc. — MAAPS
- Venture by Uriel Justine DV. Robles & Dadille Cinco · RTU CBEA
