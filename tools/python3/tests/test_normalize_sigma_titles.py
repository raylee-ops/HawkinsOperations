from pathlib import Path
import unittest

from tools.python3.normalize_sigma_titles import normalize_sigma_text


class NormalizeSigmaTitleTests(unittest.TestCase):
    def test_normalize_sigma_text(self) -> None:
        sample_in = Path("tools/python3/samples/sigma_input.yml").read_text(encoding="utf-8")
        expected = Path("tools/python3/samples/sigma_expected.yml").read_text(encoding="utf-8")
        self.assertEqual(normalize_sigma_text(sample_in), expected)

    def test_cli_writes_output(self) -> None:
        sample_in = Path("tools/python3/samples/sigma_input.yml").read_text(encoding="utf-8")
        out = Path("tools/python3/samples/sigma_output_test.yml")
        try:
            out.write_text(normalize_sigma_text(sample_in), encoding="utf-8")
            self.assertTrue(out.exists())
            self.assertIn("title: Suspicious powershell encoded command", out.read_text(encoding="utf-8"))
        finally:
            if out.exists():
                out.unlink()


if __name__ == "__main__":
    unittest.main()
