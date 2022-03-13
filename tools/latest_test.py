#!/usr/bin/env python3
version = "0.1.0"

import unittest

from latest import latest


class TestLatest(unittest.TestCase):
    def setUp(self):
        pass

    def test_patch_difference(self):
        result = latest(["3.0.624-zero-release-tests", "3.0.626-zero-release-tests"])
        self.assertEqual(result, "3.0.626-zero-release-tests")

    def test_minor_difference(self):
        result = latest(["3.1.626-zero-release-tests", "3.0.628-zero-release-tests"])
        self.assertEqual(result, "3.1.626-zero-release-tests")

    def test_major_difference(self):
        result = latest(["3.1.626-zero-release-tests", "4.0.624-zero-release-tests"])
        self.assertEqual(result, "4.0.624-zero-release-tests")

    def test_version_difference_1(self):
        result = latest(["3.0.624-zero-release-tests", "3.0.624-zero-release-tests-v1"])
        self.assertEqual(result, "3.0.624-zero-release-tests-v1")

    def test_version_difference_2(self):
        result = latest(
            ["3.0.624-zero-release-tests-v1", "3.0.624-zero-release-tests-v9"]
        )
        self.assertEqual(result, "3.0.624-zero-release-tests-v9")

    def test_version_difference_3(self):
        result = latest(
            ["3.0.624-zero-release-tests-v10", "3.0.624-zero-release-tests-v9"]
        )
        self.assertEqual(result, "3.0.624-zero-release-tests-v10")

    def test_all_difference(self):
        result = latest(
            [
                "3.0.9-z",
                "3.1.624-z-v22",
                "14.0.624-z-v88",
                "12.17.624-z-v8",
                "14.0.628-z-v1",
                "1.2.3-z-v4",
            ]
        )
        self.assertEqual(result, "14.0.628-z-v1")

    def test_numbering_patch(self):
        result = latest(["9.9.10-z", "9.9.9-z"])
        self.assertEqual(result, "9.9.10-z")

    def test_numbering_minor(self):
        result = latest(["9.10.9-z", "9.9.9-z"])
        self.assertEqual(result, "9.10.9-z")

    def test_numbering_major(self):
        result = latest(["10.9.9-z", "9.9.9-z"])
        self.assertEqual(result, "10.9.9-z")

    def test_numbering_version(self):
        result = latest(["9.9.9-z-v10", "9.9.9-z-v9"])
        self.assertEqual(result, "9.9.9-z-v10")

    def test_non_matching_folder_name(self):
        result = latest(["shouldBeIgnored", "9.9.9-z-v9"])
        self.assertEqual(result, "9.9.9-z-v9")


if __name__ == "__main__":
    unittest.main()
