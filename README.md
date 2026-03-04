# Stacked Data

Deep-dive technical articles on Microsoft Fabric and modern data engineering — built with Hugo and hosted on Azure Static Web Apps.

## Stack

| Layer | Technology |
|-------|-----------|
| Static site generator | [Hugo](https://gohugo.io/) 0.140.2 extended |
| Hosting | [Azure Static Web Apps](https://azure.microsoft.com/en-us/products/app-service/static) (Free tier) |
| CI/CD | GitHub Actions — auto-deploy on push to `main`, PR previews on pull requests |
| Article authoring | Claude `blog-article` skill — research → draft → HTML → GitHub PR |

## One-time Setup

1. Edit `setup.sh` — update `GITHUB_USER` if needed
2. Run: `bash setup.sh`
3. That's it — the script creates the GitHub repo, Azure resource group, SWA, and wires the deploy secret

**Prerequisites:** `gh` (GitHub CLI), `az` (Azure CLI), both authenticated.

### Custom domain (after setup)

```bash
az staticwebapp hostname set \
  --name stacked-data \
  --resource-group rg-stacked-data \
  --hostname your-domain.com
```

Then update the `SITE_BASE_URL` GitHub variable to your domain.

## CI/CD Flow

```
git push main
     │
     ▼
GitHub Actions (.github/workflows/azure-static-web-apps.yml)
     │
     ├─ peaceiris/actions-hugo@v3   → builds Hugo with --minify
     │
     └─ Azure/static-web-apps-deploy@v1  → deploys public/ to SWA
```

Pull requests get automatic preview environments at a unique SWA URL.

## Writing Articles

### Via the `blog-article` skill (recommended)

Run the `blog-article` Claude skill. It handles research, draft, HTML, diagrams, and opens a GitHub PR.

### Manually

1. Create `content/posts/<slug>/index.md`:

```yaml
---
title: "Your Article Title"
subtitle: "Optional subtitle"
date: 2026-03-04
draft: false
categories: ["Microsoft Fabric"]
tags: ["tag1", "tag2"]
author: "Maciej Rubczynski"
description: "SEO description (160 chars)"
---

Article body in Markdown...
```

2. Images go in `static/images/posts/<slug>/` — reference as `/images/posts/<slug>/image.png`
3. Push to a branch, open a PR — preview environment is created automatically
4. Merge to deploy

### Self-contained HTML articles

For articles with custom CSS/layouts (like the first Fabric IQ deep dive), place the HTML in `static/<slug>/index.html`. The Hugo post entry uses `externalURL: "/<slug>/"` so it appears in listings but serves the standalone page.

## Shortcodes

```
{{< tip >}}Your tip content{{< /tip >}}
{{< note >}}Your note content{{< /note >}}
{{< warning >}}Your warning content{{< /warning >}}
```

## Local Development

```bash
# Install Hugo (macOS)
brew install hugo

# Serve locally with live reload
hugo server -D

# Build for production
hugo --minify
```

## Project Structure

```
stacked-data/
├── .github/workflows/          # GitHub Actions CI/CD
├── archetypes/posts.md         # New post template (hugo new posts/<slug>/index.md)
├── content/
│   ├── posts/                  # Markdown articles
│   └── about.md                # About page
├── layouts/                    # Hugo templates (no theme dependency)
│   ├── _default/               # baseof, single, list
│   ├── partials/               # header, footer
│   ├── shortcodes/             # tip, note, warning
│   └── index.html              # Homepage
├── static/
│   ├── css/main.css            # All site styles
│   └── fabric-iq-deep-dive/   # First article (self-contained HTML)
├── hugo.toml                   # Site configuration
├── setup.sh                    # One-time Azure + GitHub setup
└── README.md
```
