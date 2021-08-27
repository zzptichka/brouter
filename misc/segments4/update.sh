#!/bin/bash
for filename in *.rd5; do
        echo Downloading $filename ...
        wget http://brouter.de/brouter/segments4/$filename -O $filename
done