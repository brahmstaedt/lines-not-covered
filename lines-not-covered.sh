#!/bin/bash

# This shell script tries to find lines of PHP code that are not tested
# using PHPUnit. It does so, by removing a single line of code, runs the
# tests and checks, if the tests fail. If they don't, then the line is not
# tested. This script is stupid and will report false positives.

# It requires two arguments: the code file and the test file
# example: lines-not-covered.sh src/mycode.php tests/testmycode.php


codeFile=$1
testFile=$2

if [ -z "$codeFile" ]
then
      echo "First parameter must be the code file"
      exit 1
fi

if [ ! -f "$codeFile" ]
then
      echo "Code file '$codeFile' not found"
      exit 1
fi

if [ -z "$testFile" ]
then
      echo "Second parameter must be the test file"
      exit 1
fi

if [ ! -f "$testFile" ]
then
      echo "Test file '$testFile' not found"
      exit 1
fi

linesTotal=$(grep '' -c $codeFile)
affectedLines=''

backupCodeFile=${codeFile}____backup
cp $codeFile $backupCodeFile

for ((i=1;i<=$linesTotal;i++)); do

  # get the line i from the codeFile
  line=$(sed -e $i!d $codeFile)
  trimmedLine=$(xargs <<<$line)

  # delete this line from the file
  sed -e ${i}d -i $codeFile

  # test if the PHP code is syntactically valid
  php -l $codeFile > /dev/null 2>&1
  rc=$?

  # if PHP code is valid, run PHPUnit test
  if [ $rc -eq 0 ]; then
    bin/phpunit $testFile > /dev/null 2>&1
    rc=$?
    # if PHPUnit has no error, report this line as untested
    if [ $rc -eq 0 ]; then

      # if the line is not empty
      if [ ! -z "$trimmedLine" ]; then
        firstChar=${trimmedLine:0:1}

        # line is not a comment
        if [ "$firstChar" != '*' -a "$firstChar" != '/' -a "$firstChar" != '#' ]; then
          echo "$i: $line";
          affectedLines="$affectedLines $i"
        fi

      fi

    fi

  fi

  # restore file from backup
  cp $backupCodeFile $codeFile

done

# remove backup file
test -f $backupCodeFile && rm $backupCodeFile

# iterate over the code file and add comments to untested lines
let offset=0
for lineNumber in $affectedLines; do
  sed "$((lineNumber + offset)) i # TODO the following line is not covered by PHPUnit" -i $codeFile
  let offset=$((offset + 1))
done
