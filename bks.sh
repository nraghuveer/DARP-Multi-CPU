#!/bin/bash
filename="test-runs/$1-1.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-1.1 pr01 $2 190.02 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '1.1'

filename="test-runs/$1-1.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-1.2 pr01 $2 190.02 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '1.2'

filename="test-runs/$1-1.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-1.3 pr01 $2 190.02 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '1.3'

filename="test-runs/$1-1.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-1.4 pr01 $2 190.02 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '1.4'

filename="test-runs/$1-1.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-1.5 pr01 $2 190.02 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '1.5'


filename="test-runs/$1-2.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-2.1 pr02 $2 302.08 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '2.1'

filename="test-runs/$1-2.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-2.2 pr02 $2 302.08 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '2.2'

filename="test-runs/$1-2.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-2.3 pr02 $2 302.08 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '2.3'

filename="test-runs/$1-2.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-2.4 pr02 $2 302.08 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '2.4'

filename="test-runs/$1-2.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-2.5 pr02 $2 302.08 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '2.5'


filename="test-runs/$1-3.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-3.1 pr03 $2 532.08 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '3.1'

filename="test-runs/$1-3.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-3.2 pr03 $2 532.08 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '3.2'

filename="test-runs/$1-3.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-3.3 pr03 $2 532.08 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '3.3'

filename="test-runs/$1-3.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-3.4 pr03 $2 532.08 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '3.4'

filename="test-runs/$1-3.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-3.5 pr03 $2 532.08 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '3.5'


filename="test-runs/$1-4.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-4.1 pr04 $2 572.78 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '4.1'

filename="test-runs/$1-4.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-4.2 pr04 $2 572.78 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '4.2'

filename="test-runs/$1-4.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-4.3 pr04 $2 572.78 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '4.3'

filename="test-runs/$1-4.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-4.4 pr04 $2 572.78 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '4.4'

filename="test-runs/$1-4.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-4.5 pr04 $2 572.78 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '4.5'


filename="test-runs/$1-5.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-5.1 pr05 $2 636.97 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '5.1'

filename="test-runs/$1-5.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-5.2 pr05 $2 636.97 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '5.2'

filename="test-runs/$1-5.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-5.3 pr05 $2 636.97 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '5.3'

filename="test-runs/$1-5.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-5.4 pr05 $2 636.97 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '5.4'

filename="test-runs/$1-5.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-5.5 pr05 $2 636.97 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '5.5'


filename="test-runs/$1-6.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-6.1 pr06 $2 801.4 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '6.1'

filename="test-runs/$1-6.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-6.2 pr06 $2 801.4 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '6.2'

filename="test-runs/$1-6.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-6.3 pr06 $2 801.4 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '6.3'

filename="test-runs/$1-6.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-6.4 pr06 $2 801.4 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '6.4'

filename="test-runs/$1-6.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-6.5 pr06 $2 801.4 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '6.5'


filename="test-runs/$1-7.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-7.1 pr07 $2 291.71 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '7.1'

filename="test-runs/$1-7.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-7.2 pr07 $2 291.71 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '7.2'

filename="test-runs/$1-7.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-7.3 pr07 $2 291.71 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '7.3'

filename="test-runs/$1-7.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-7.4 pr07 $2 291.71 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '7.4'

filename="test-runs/$1-7.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-7.5 pr07 $2 291.71 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '7.5'


filename="test-runs/$1-8.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-8.1 pr08 $2 494.89 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '8.1'

filename="test-runs/$1-8.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-8.2 pr08 $2 494.89 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '8.2'

filename="test-runs/$1-8.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-8.3 pr08 $2 494.89 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '8.3'

filename="test-runs/$1-8.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-8.4 pr08 $2 494.89 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '8.4'

filename="test-runs/$1-8.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-8.5 pr08 $2 494.89 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '8.5'


filename="test-runs/$1-9.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-9.1 pr09 $2 672.44 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '9.1'

filename="test-runs/$1-9.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-9.2 pr09 $2 672.44 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '9.2'

filename="test-runs/$1-9.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-9.3 pr09 $2 672.44 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '9.3'

filename="test-runs/$1-9.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-9.4 pr09 $2 672.44 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '9.4'

filename="test-runs/$1-9.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-9.5 pr09 $2 672.44 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '9.5'


filename="test-runs/$1-10.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-10.1 pr10 $2 878.76 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '10.1'

filename="test-runs/$1-10.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-10.2 pr10 $2 878.76 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '10.2'

filename="test-runs/$1-10.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-10.3 pr10 $2 878.76 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '10.3'

filename="test-runs/$1-10.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-10.4 pr10 $2 878.76 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '10.4'

filename="test-runs/$1-10.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-10.5 pr10 $2 878.76 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '10.5'


filename="test-runs/$1-11.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-11.1 pr11 $2 164.46 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '11.1'

filename="test-runs/$1-11.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-11.2 pr11 $2 164.46 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '11.2'

filename="test-runs/$1-11.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-11.3 pr11 $2 164.46 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '11.3'

filename="test-runs/$1-11.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-11.4 pr11 $2 164.46 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '11.4'

filename="test-runs/$1-11.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-11.5 pr11 $2 164.46 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '11.5'


filename="test-runs/$1-12.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-12.1 pr12 $2 296.06 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '12.1'

filename="test-runs/$1-12.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-12.2 pr12 $2 296.06 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '12.2'

filename="test-runs/$1-12.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-12.3 pr12 $2 296.06 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '12.3'

filename="test-runs/$1-12.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-12.4 pr12 $2 296.06 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '12.4'

filename="test-runs/$1-12.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-12.5 pr12 $2 296.06 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '12.5'


filename="test-runs/$1-13.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-13.1 pr13 $2 493.3 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '13.1'

filename="test-runs/$1-13.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-13.2 pr13 $2 493.3 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '13.2'

filename="test-runs/$1-13.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-13.3 pr13 $2 493.3 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '13.3'

filename="test-runs/$1-13.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-13.4 pr13 $2 493.3 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '13.4'

filename="test-runs/$1-13.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-13.5 pr13 $2 493.3 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '13.5'


filename="test-runs/$1-14.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-14.1 pr14 $2 535.9 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '14.1'

filename="test-runs/$1-14.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-14.2 pr14 $2 535.9 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '14.2'

filename="test-runs/$1-14.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-14.3 pr14 $2 535.9 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '14.3'

filename="test-runs/$1-14.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-14.4 pr14 $2 535.9 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '14.4'

filename="test-runs/$1-14.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-14.5 pr14 $2 535.9 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '14.5'


filename="test-runs/$1-15.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-15.1 pr15 $2 589.74 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '15.1'

filename="test-runs/$1-15.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-15.2 pr15 $2 589.74 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '15.2'

filename="test-runs/$1-15.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-15.3 pr15 $2 589.74 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '15.3'

filename="test-runs/$1-15.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-15.4 pr15 $2 589.74 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '15.4'

filename="test-runs/$1-15.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-15.5 pr15 $2 589.74 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '15.5'


filename="test-runs/$1-16.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-16.1 pr16 $2 743.6 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '16.1'

filename="test-runs/$1-16.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-16.2 pr16 $2 743.6 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '16.2'

filename="test-runs/$1-16.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-16.3 pr16 $2 743.6 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '16.3'

filename="test-runs/$1-16.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-16.4 pr16 $2 743.6 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '16.4'

filename="test-runs/$1-16.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-16.5 pr16 $2 743.6 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '16.5'


filename="test-runs/$1-17.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-17.1 pr17 $2 248.21 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '17.1'

filename="test-runs/$1-17.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-17.2 pr17 $2 248.21 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '17.2'

filename="test-runs/$1-17.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-17.3 pr17 $2 248.21 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '17.3'

filename="test-runs/$1-17.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-17.4 pr17 $2 248.21 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '17.4'

filename="test-runs/$1-17.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-17.5 pr17 $2 248.21 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '17.5'


filename="test-runs/$1-18.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-18.1 pr18 $2 462.69 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '18.1'

filename="test-runs/$1-18.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-18.2 pr18 $2 462.69 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '18.2'

filename="test-runs/$1-18.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-18.3 pr18 $2 462.69 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '18.3'

filename="test-runs/$1-18.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-18.4 pr18 $2 462.69 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '18.4'

filename="test-runs/$1-18.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-18.5 pr18 $2 462.69 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '18.5'


filename="test-runs/$1-19.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-19.1 pr19 $2 601.96 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '19.1'

filename="test-runs/$1-19.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-19.2 pr19 $2 601.96 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '19.2'

filename="test-runs/$1-19.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-19.3 pr19 $2 601.96 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '19.3'

filename="test-runs/$1-19.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-19.4 pr19 $2 601.96 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '19.4'

filename="test-runs/$1-19.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-19.5 pr19 $2 601.96 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '19.5'


filename="test-runs/$1-20.1.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-20.1 pr20 $2 798.63 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '20.1'

filename="test-runs/$1-20.2.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-20.2 pr20 $2 798.63 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '20.2'

filename="test-runs/$1-20.3.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-20.3 pr20 $2 798.63 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '20.3'

filename="test-runs/$1-20.4.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-20.4 pr20 $2 798.63 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '20.4'

filename="test-runs/$1-20.5.csv"
if [ ! -e "$filename"  ]
then
    ./runv2.sh test-runs/$1-20.5 pr20 $2 798.63 0 1 2 4 8 16 24 >> logs/$1.txt
fi
echo '20.5'


