#!/bin/bash

#naming scheme: ../GSF2960-NOF10-POA_S17_R1_001.fastq.gz

for f in ../*R1_001.fastq.gz 
do
    IFS='_' read -a array <<< $f;
    trimmomatic PE -phred33 ${array[0]}_${array[1]}_R1_001.fastq.gz ${array[0]}_${array[1]}_R2_001.fastq.gz \
    ${array[0]}_${array[1]}_R1_paired.fq.gz ${array[0]}_${array[1]}_R1_unpaired.fq.gz ${array[0]}_${array[1]}_R2_paired.fq.gz \
    ${array[0]}_${array[1]}_R2_unpaired.fq.gz TRAILING:28 SLIDINGWINDOW:4:15 MINLEN:32
done
