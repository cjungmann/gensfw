install:
	makeinfo gensfw.info.txi --paragraph-indent=0 -o /usr/share/info
	gzip -f      /usr/share/info/gensfw.info
	install-info /usr/share/info/gensfw.info.gz /usr/share/info/dir

	install -D --mode=755 ./gensfw /usr/local/lib/SchemaServer/utilities/gensfw
	cp -sf /usr/local/lib/SchemaServer/utilities/gensfw  /usr/bin/gensfw

uninstall:
	rm -f /usr/share/info/gensfw.info.gz
	unlink /usr/bin/gensfw
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw
