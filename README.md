# Docs Helpers

A collection of helpers to assist Docs work.

- [Canonical Links](#canonical-links)
- [Move Pages](#move-pages)

## Canonical Links

- Adds a canonical link tag to all files. 
- Assumes files in the `docs` directory are to be used as the canonical link.
- Adds a canonical link tag to files in the `versioned_docs` directory that follow the same path as the file in the `docs` directory.
- Outputs a file containing a list of files **without** a canonical link.

Caveats:
- Existing canonical links are **NOT** overwritten.

### Usage

From the root of the repository run the command:

```
ruby canonical_links.rb <DOMAIN> <DIRECTORY>
```

Where:
- `<DOMAIN>` is the base URL of your site **WITHOUT** the trailing slash.
- `<DIRECTORY>` is the directory to check/add canonical URLs to.

Example:

```
ruby canonical_links.rb https://ranchermanager.docs.rancher.com docs/troubleshooting/other-troubleshooting-tips
ruby canonical_links.rb https://docs.rancherdesktop.io docs/tutorials
```

## Move Pages

- Takes a CSV file containing a file's current path and the new path as input.
- Moves the specified file(s).
- Updates internal links that use the filepath format. Absolute links are ignored.
  - Links in the moved file.
  - Links in files linking to the moved file. 
- Outputs a file containing a block of redirects to use in the Docusaurus config.
- Updates the sidebar value of the moved page. Sidebar placement is **NOT** updated.

### Usage

From the root of the docs repository run the command:

```
ruby page-move.rb <CSV_FILE>
```

Where:

- The CSV file has 2 columns, one for `old_path` and another for `new_path`.
- `old_path` is the current path of the file to be moved.
- `new_path` is the destination path of the file to be moved.
- Paths are relative to the root of the docs directory.

Example:

```
ruby page-move.rb ~/test_input/files_to_move.csv
```

Where `files_to_move.csv` contains:

```
old_path, new_path
docs/pages-for-subheaders/cis-scans, docs/integrations-in-rancher/cis-scans/cis-scans
docs/pages-for-subheaders/about-the-api, docs/reference-guides/about-the-api/about-the-api
```
