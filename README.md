# lines-not-covered
A shell script checking which lines are actually covered by PHPUnit

# Intro
This shell script tries to find lines of PHP code that are not tested
using PHPUnit. It does so, by removing a single line of code, runs the
tests and checks, if the tests fail. If they don't, then the line is not
tested.

This is repeated line by line for the entire code file

This script is stupid and will report false positives. Still it gives an
interesting list of lines that a developer may want to review.

# Run
It requires two arguments: the code file and the test file. Example:
```
lines-not-covered.sh src/mycode.php tests/testmycode.php
```

# Next
A rewrite of this shell script in PHP may be interesting. This can help having
less false positives (e.g. ignoring `public $foo` variable definitions) as well
as leveraging code coverage annotations from PHPUnit.
