#!/bin/bash

for file in **/*.fastq.gz;
do
    IFS='/' read -a array <<< $file;
    name="allreads/${array[1]}";
    cat $file >> $name;
done
