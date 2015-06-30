#!/bin/sh
oarGPUs=`oarprint host -P host,gpu_num -F '% %'`
useGPU=`echo $oarGPUs|sed "s/[a-z0-9-]*\ //"|sed "s/,[,0-9]*//"`
if [ $useGPU -lt 0 ]; then
    echo $oarGPUs : this host has no GPU: $useGPU
    exit
else
    echo $oarGPUs : using GPU number $useGPU
fi
#exit
#export CUDA_VISIBLE_DEVICES=0
export CUDA_VISIBLE_DEVICES=$useGPU
echo running on `hostname` using GPU $CUDA_VISIBLE_DEVICES

