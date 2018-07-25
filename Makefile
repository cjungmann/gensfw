install:
	# Install the application
	install -D --mode=755 ./gensfw /usr/local/lib/SchemaServer/utilities/gensfw
	install -D --mode=644 ./gensfw_bacts /usr/local/lib/SchemaServer/utilities/gensfw_bacts
	install -D --mode=644 ./gensfw_scripts_sql /usr/local/lib/SchemaServer/utilities/gensfw_scripts_sql
	install -D --mode=644 ./gensfw_scripts_srm /usr/local/lib/SchemaServer/utilities/gensfw_scripts_srm
	# Install the man page
	cp gensfw.1 /usr/share/man/man1
	gzip -f /usr/share/man/man1/gensfw.1
	# Install the info file
	cp -sf /usr/local/lib/SchemaServer/utilities/gensfw  /usr/bin/gensfw
	makeinfo gensfw.info.txi --paragraph-indent=0 -o /usr/share/info
	gzip -f      /usr/share/info/gensfw.info
	install-info /usr/share/info/gensfw.info.gz /usr/share/info/dir


uninstall:
	# Uninstall the application:
	unlink /usr/bin/gensfw
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw_bacts
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw_scripts_sql
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw_scripts_srm
	# Remove documentation files
	install-info --delete /usr/share/info/gensfw.info.gz /usr/share/info/dir
	rm -f /usr/share/info/gensfw.info.gz
	rm -f /usr/share/man/man1/gensfw.1.gz
