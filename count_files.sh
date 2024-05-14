#!/bin/bash

 for dirname in */; do
     printf "%s:\t%d\n" "${dirname}" $(lfs find $(pwd)/${dirname} | wc -l)
 done