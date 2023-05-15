#!/bin/bash
filename="test-runs/mrt/$1-20.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-20.1 pr20 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '20.1'


filename="test-runs/mrt/$1-19.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-19.1 pr19 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '19.1'


filename="test-runs/mrt/$1-18.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-18.1 pr18 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '18.1'


filename="test-runs/mrt/$1-17.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-17.1 pr17 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '17.1'


filename="test-runs/mrt/$1-16.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-16.1 pr16 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '16.1'


filename="test-runs/mrt/$1-15.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-15.1 pr15 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '15.1'


filename="test-runs/mrt/$1-14.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-14.1 pr14 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '14.1'


filename="test-runs/mrt/$1-13.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-13.1 pr13 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '13.1'


filename="test-runs/mrt/$1-12.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-12.1 pr12 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '12.1'


filename="test-runs/mrt/$1-11.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-11.1 pr11 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '11.1'


filename="test-runs/mrt/$1-10.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-10.1 pr10 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '10.1'


filename="test-runs/mrt/$1-9.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-9.1 pr09 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '9.1'


filename="test-runs/mrt/$1-8.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-8.1 pr08 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '8.1'


filename="test-runs/mrt/$1-7.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-7.1 pr07 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '7.1'


filename="test-runs/mrt/$1-6.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-6.1 pr06 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '6.1'


filename="test-runs/mrt/$1-5.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-5.1 pr05 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '5.1'


filename="test-runs/mrt/$1-4.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-4.1 pr04 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '4.1'


filename="test-runs/mrt/$1-3.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-3.1 pr03 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '3.1'


filename="test-runs/mrt/$1-2.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-2.1 pr02 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '2.1'


filename="test-runs/mrt/$1-1.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/mrt/$1-1.1 pr01 $2 0 100 4 >> logs/mrt/$1.txt
fi
echo '1.1'


