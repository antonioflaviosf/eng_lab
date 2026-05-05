#!/bin/bash 

for node in vm-master vm-worker-1 vm-worker-2; do 
    incus delete -f $node 
done