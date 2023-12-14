# Docs Helpers

## Canonical Links

Adds a canonical link tag to all files. 

Caveats:
- Assumes files in the `docs` directory are to be used as the canonical link.
- Canonical links are only added to files in the `versioned_docs` directory if their path matches a file in the `docs` directory.
- Existing canonical links are currently not overwritten.

### Usage

From the root of the docs repository run the command:

```
ruby canonical_links.rb <DOMAIN> <DIRECTORY>
```

Where:
- `<DOMAIN>` is the base URL of your site **without** the trailing slash.
- `<DIRECTORY>` is the directory to check/add canonical URLs to.

Example:

```
ruby canonical_links.rb https://ranchermanager.docs.rancher.com docs/troubleshooting/other-troubleshooting-tips
ruby canonical_links.rb https://docs.rancherdesktop.io docs/tutorials
```
