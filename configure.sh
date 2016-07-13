#!/bin/bash

files=($(find ./config -type f))

for path in "${files[@]}" 
do
	pattern="\.DS_Store"
	source=${path/\./}
	target=${path/\.\/config/\/etc}
	
	if [[ ! $target =~ $pattern ]]; then
		if [[ -f $target ]]; then
			echo "    Removing \"$target\"" && rm -rf $target
		fi
		
		echo "    Linking \"$source\" to \"$target\"" && mkdir -p $(dirname "${target}") && ln -s $source $target
	fi
done
