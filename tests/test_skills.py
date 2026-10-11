import sys
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
from validate import validate

class SkillTests(unittest.TestCase):
    def test_skill_manifests(self):
        self.assertEqual([], validate())

if __name__ == '__main__':
    unittest.main()
