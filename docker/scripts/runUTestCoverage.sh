#!/bin/bash

set -e

go test -v $(glide novendor)

echo "==============: Removing cache..."
rm -rf coverage

echo "==============: Installing unit test dependencies..."
go get -u github.com/jstemmer/go-junit-report

#We make de dir to set all the files and the result
mkdir -p coverage/utest

find . -name "*_test.go" -not -path "./vendor/*" -not -path "./test/*" -exec dirname {} \; | sort -u> coverage/packagesToTest.txt

#We get all the packages that we want to test
iterator=0
packagesWithTest=()
while read line; do
    packagesWithTest[$iterator]=${line}
    iterator=$((iterator+1))
done < coverage/packagesToTest.txt

#We execute the coverage test per package
tLen=${#packagesWithTest[@]}
iterator=0
for (( i=0; i<${tLen}; i++ ));
do
    go test -v -coverprofile=coverage/coverage${iterator}.out ${packagesWithTest[$iterator]} 2>&1 | go-junit-report > coverage/utest/report.xml
    iterator=$((iterator+1))
done

#We add all the result of the coverage test in one file that respect the format
#of go tool cover
totalCoverage="mode: set"
for (( i=0; i<${tLen}; i++ ));
do
    iterator=0
    while read line; do
        if [ ${iterator} == 1 ];then
            totalCoverage=${totalCoverage}"\n"${line}
        fi
        iterator=1

    done < coverage/coverage${i}.out
    #rm coverage/coverage${i}.out
done

echo -e ${totalCoverage}> coverage/coverage.out

#We generate the report of the coverage test
go tool cover -html=coverage/coverage.out -o coverage/coverage.html



echo "==============: Changing permissions..."
chmod -R 777 coverage


