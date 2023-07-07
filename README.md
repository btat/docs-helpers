# rm-seo-helpers

Usage:

From the root of the docs repository run the command:

```
ruby canonical_links.rb <DOMAIN> <DIRECTORY>
```

Where:
- `<DOMAIN>` is the base URL of your site without a trailing slash.
- `<DIRECTORY>` is the directory to check/add canonical URLs to

Example:

```
ruby canonical_links.rb https://ranchermanager.docs.rancher.com docs/troubleshooting/other-troubleshooting-tips
ruby canonical_links.rb https://docs.rancherdesktop.io docs/tutorials
```
