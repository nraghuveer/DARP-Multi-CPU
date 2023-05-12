#!/bin/bash
filename="test-runs/$1-1.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-1.1 pr01 $2 190.02 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '1.1'

filename="test-runs/$1-1.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-1.2 pr01 $2 190.02 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '1.2'

filename="test-runs/$1-1.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-1.3 pr01 $2 190.02 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '1.3'


filename="test-runs/$1-2.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-2.1 pr02 $2 302.08 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '2.1'

filename="test-runs/$1-2.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-2.2 pr02 $2 302.08 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '2.2'

filename="test-runs/$1-2.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-2.3 pr02 $2 302.08 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '2.3'


filename="test-runs/$1-3.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-3.1 pr03 $2 532.08 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '3.1'

filename="test-runs/$1-3.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-3.2 pr03 $2 532.08 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '3.2'

filename="test-runs/$1-3.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-3.3 pr03 $2 532.08 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '3.3'


filename="test-runs/$1-4.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-4.1 pr04 $2 572.78 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '4.1'

filename="test-runs/$1-4.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-4.2 pr04 $2 572.78 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '4.2'

filename="test-runs/$1-4.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-4.3 pr04 $2 572.78 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '4.3'


filename="test-runs/$1-5.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-5.1 pr05 $2 636.97 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '5.1'

filename="test-runs/$1-5.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-5.2 pr05 $2 636.97 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '5.2'

filename="test-runs/$1-5.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-5.3 pr05 $2 636.97 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '5.3'


filename="test-runs/$1-6.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-6.1 pr06 $2 801.4 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '6.1'

filename="test-runs/$1-6.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-6.2 pr06 $2 801.4 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '6.2'

filename="test-runs/$1-6.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-6.3 pr06 $2 801.4 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '6.3'


filename="test-runs/$1-7.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-7.1 pr07 $2 291.71 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '7.1'

filename="test-runs/$1-7.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-7.2 pr07 $2 291.71 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '7.2'

filename="test-runs/$1-7.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-7.3 pr07 $2 291.71 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '7.3'


filename="test-runs/$1-8.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-8.1 pr08 $2 494.89 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '8.1'

filename="test-runs/$1-8.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-8.2 pr08 $2 494.89 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '8.2'

filename="test-runs/$1-8.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-8.3 pr08 $2 494.89 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '8.3'


filename="test-runs/$1-9.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-9.1 pr09 $2 672.44 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '9.1'

filename="test-runs/$1-9.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-9.2 pr09 $2 672.44 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '9.2'

filename="test-runs/$1-9.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-9.3 pr09 $2 672.44 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '9.3'


filename="test-runs/$1-10.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-10.1 pr10 $2 878.76 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '10.1'

filename="test-runs/$1-10.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-10.2 pr10 $2 878.76 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '10.2'

filename="test-runs/$1-10.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-10.3 pr10 $2 878.76 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '10.3'


filename="test-runs/$1-11.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-11.1 pr11 $2 164.46 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '11.1'

filename="test-runs/$1-11.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-11.2 pr11 $2 164.46 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '11.2'

filename="test-runs/$1-11.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-11.3 pr11 $2 164.46 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '11.3'


filename="test-runs/$1-12.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-12.1 pr12 $2 296.06 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '12.1'

filename="test-runs/$1-12.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-12.2 pr12 $2 296.06 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '12.2'

filename="test-runs/$1-12.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-12.3 pr12 $2 296.06 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '12.3'


filename="test-runs/$1-13.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-13.1 pr13 $2 493.3 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '13.1'

filename="test-runs/$1-13.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-13.2 pr13 $2 493.3 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '13.2'

filename="test-runs/$1-13.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-13.3 pr13 $2 493.3 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '13.3'


filename="test-runs/$1-14.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-14.1 pr14 $2 535.9 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '14.1'

filename="test-runs/$1-14.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-14.2 pr14 $2 535.9 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '14.2'

filename="test-runs/$1-14.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-14.3 pr14 $2 535.9 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '14.3'


filename="test-runs/$1-15.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-15.1 pr15 $2 589.74 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '15.1'

filename="test-runs/$1-15.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-15.2 pr15 $2 589.74 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '15.2'

filename="test-runs/$1-15.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-15.3 pr15 $2 589.74 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '15.3'


filename="test-runs/$1-16.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-16.1 pr16 $2 743.6 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '16.1'

filename="test-runs/$1-16.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-16.2 pr16 $2 743.6 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '16.2'

filename="test-runs/$1-16.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-16.3 pr16 $2 743.6 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '16.3'


filename="test-runs/$1-17.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-17.1 pr17 $2 248.21 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '17.1'

filename="test-runs/$1-17.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-17.2 pr17 $2 248.21 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '17.2'

filename="test-runs/$1-17.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-17.3 pr17 $2 248.21 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '17.3'


filename="test-runs/$1-18.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-18.1 pr18 $2 462.69 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '18.1'

filename="test-runs/$1-18.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-18.2 pr18 $2 462.69 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '18.2'

filename="test-runs/$1-18.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-18.3 pr18 $2 462.69 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '18.3'


filename="test-runs/$1-19.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-19.1 pr19 $2 601.96 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '19.1'

filename="test-runs/$1-19.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-19.2 pr19 $2 601.96 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '19.2'

filename="test-runs/$1-19.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-19.3 pr19 $2 601.96 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '19.3'


filename="test-runs/$1-20.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-20.1 pr20 $2 798.63 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '20.1'

filename="test-runs/$1-20.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-20.2 pr20 $2 798.63 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '20.2'

filename="test-runs/$1-20.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-20.3 pr20 $2 798.63 1 2 4 8 16 32 64 >> logs/$1.txt
fi
echo '20.3'


