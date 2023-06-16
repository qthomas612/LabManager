#!/bin/bash

for file in allreads/*.fastq.gz;
do
    fastqc $file;
done
