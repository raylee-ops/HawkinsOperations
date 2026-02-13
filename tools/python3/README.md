# Python 3 Utility Samples

This folder is a small Python 3 signal for recruiters and hiring managers.

## Utility
- `normalize_sigma_titles.py`
  - Normalizes Sigma rule title lines (`title:`) into consistent sentence case.
  - Keeps dependency footprint low (standard library only).

## Usage
```bash
python tools/python3/normalize_sigma_titles.py \
  --in tools/python3/samples/sigma_input.yml \
  --out tools/python3/samples/sigma_output.yml
```

## Quick test
```bash
python -m unittest tools.python3.tests.test_normalize_sigma_titles
```

## Sample files
- Input: `tools/python3/samples/sigma_input.yml`
- Expected: `tools/python3/samples/sigma_expected.yml`

