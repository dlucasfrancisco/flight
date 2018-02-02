#!/bin/bash

set -e

echo "==============: Removing cache..."
rm -rf coverage

echo "==============: Creating folders..."
mkdir -p coverage/utest/

echo "==============: Running unit tests and generate JUNIT xml..."
file=$(mktemp)
go test -v ./cmd/... ./internal/... ./pkg/... | tee $file
cat $file | go-junit-report > coverage/utest/report.xml

echo "==============: Generate Coverage html..."
find . -name "*_test.go" -not -path "./vendor/*" -not -path "./test/*" -exec dirname {} \; | sort -u> coverage/packagesToTest.txt

export OCP_DOMAIN=test.domain
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
    go test -coverprofile=coverage/coverage${iterator}.out ${packagesWithTest[$iterator]} 2>&1
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
chmod -R 777 coverage/