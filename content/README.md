# content/ - Website & Branding Assets

This directory contains public-facing website content, branding materials, and marketing assets.

## Directory Structure

```
content/
└── website/
    └── hawkinsops-v2/   # HawkinsOps public website
```

---

## website/hawkinsops-v2/

**Source:** hawkinsops-site repository
**Purpose:** Public-facing landing page and branding assets
**Deployed:** hawkinsops.com (assumed)

### Contents

| File | Purpose | Dimensions |
|------|---------|------------|
| `index.html` | Main landing page | ~48KB HTML |
| `og.png` | OpenGraph social media preview | 1200x630 recommended |
| `apple-touch-icon.png` | iOS home screen icon | 180x180 |
| `favicon-16.png` | Browser favicon (small) | 16x16 |
| `favicon-32.png` | Browser favicon (standard) | 32x32 |

### Features

The landing page (`index.html`) includes:
- Professional branding and navigation
- Portfolio positioning
- SOC content library highlights
- Contact/social links
- Responsive design

### Usage

**Local preview:**
```bash
# Simple HTTP server
cd content/website/hawkinsops-v2
python3 -m http.server 8000
# Open http://localhost:8000 in browser
```

**Deployment:**
- Copy contents to web hosting root
- Ensure proper MIME types for .png files
- Configure OpenGraph tags for social sharing

### Branding Guidelines

- Primary color scheme matches og.png
- Favicon follows brand identity
- Touch icon optimized for iOS retina displays

---

## Adding New Content

When adding website or branding content:
1. Organize by project or purpose
2. Include source files (PSDs, SVGs) if available
3. Optimize images for web (compression, dimensions)
4. Document dimensions and use cases
5. Update this README
