# Amarna Action

This action allows you to run the [Amarna static
analyzer](https://github.com/crytic/amarna) against your project, from
within a GitHub Actions workflow.

To learn more about [Amarna](https://github.com/crytic/amarna) itself, visit
its [GitHub repository](https://github.com/crytic/amarna).

- [How to use](#how-to-use)
- [Github Code Scanning integration](#github-code-scanning-integration)

# How to use

Create `.github/workflows/amarna.yml`:
```yaml
name: Amarna Analysis
on: [push]
jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: crytic/amarna-action@v0.1.1
```

## Options

| Key              | Description
|------------------|------------
| `sarif`          | If provided, the path of the SARIF file to produce, relative to the repo root (see [Github Code Scanning integration](#github-code-scanning-integration)).
| `amarna-args`    | Extra arguments to pass to Amarna. 
| `amarna-version` | The version of amarna-analyzer to use. By default, the latest release in PyPI is used.
| `target`         | The path to the root of the project to be analyzed by Amarna. Can be a directory or a file. Defaults to the repo root.

# Github Code Scanning integration

The action supports the Github Code Scanning integration, which will push Amarna's alerts to the Security tab of the Github project (see [About code scanning](https://docs.github.com/en/code-security/code-scanning/automatically-scanning-your-code-for-vulnerabilities-and-errors/about-code-scanning)). This integration eases the triaging of findings and improves the continious integration.

## How to use

To enable the integration, use the `sarif` option, and upload the Sarif file to `codeql-action`:

```yaml
name: Amarna Analysis
on: [push]
jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Amarna
        uses: crytic/amarna-action@v0.1.1
        id: amarna
        continue-on-error: true
        with:
          sarif: results.sarif
          target: 'src/'

      - name: Upload SARIF file
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: ${{ steps.amarna.outputs.sarif }}
          checkout_path: ${{ github.workspace }}
```

Here:
- `continue-on-error: true` is required to let the SARIF upload step runs if Amarna finds issues
- `id: amarna` is the name used in for `steps.amarna.outputs.sarif`
- `target: 'src/'` means Amarna will analyze the `src/` directory
