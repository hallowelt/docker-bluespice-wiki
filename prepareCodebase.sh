#!/bin/bash

if [ ! -d "_codebase" ]; then
	mkdir _codebase
fi

cd _codebase
if [ ! -d "./bluespice" ]; then
	wget https://master.dl.sourceforge.net/project/bluespice/BlueSpice-free-4.5.3.tar.gz?viasf=1 -O bluespice.tar.gz
	tar -xzf bluespice.tar.gz
	rm -rf .phar
	rm bluespice.tar.gz
fi


if [ ! -d "./simplesamlphp" ]; then
	wget https://github.com/simplesamlphp/simplesamlphp/releases/download/v2.3.3/simplesamlphp-2.3.3-slim.tar.gz -O simplesamlphp.tar.gz
	tar -xzf simplesamlphp.tar.gz
	mv simplesamlphp-2.3.3 simplesamlphp
	rm simplesamlphp.tar.gz
fi
cd -