all:
	mkdir build
	mkdir tmp
	. ./init.sh
	. ./config.sh
	cp redirects.conf build

clean:
	rm -rf build
	rm -rf tmp
