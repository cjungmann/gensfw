install:
	# Install the application
	install -D --mode=755 ./gensfw                   /usr/local/lib/SchemaServer/utilities/gensfw
	install -D --mode=644 ./gensfw_bacts             /usr/local/lib/SchemaServer/utilities/gensfw_bacts
	install -D --mode=644 ./gensfw_scripts_sql       /usr/local/lib/SchemaServer/utilities/gensfw_scripts_sql
	install -D --mode=644 ./gensfw_scripts_srm       /usr/local/lib/SchemaServer/utilities/gensfw_scripts_srm
	install -D --mode=755 ./gensfw_session_procs     /usr/local/lib/SchemaServer/utilities/gensfw_session_procs
	install -D --mode=644 ./gensfw_session_procs.xsl /usr/local/lib/SchemaServer/utilities/gensfw_session_procs.xsl
	install -D --mode=755 ./gensfw_isotable_procs     /usr/local/lib/SchemaServer/utilities/gensfw_isotable_procs
	install -D --mode=644 ./gensfw_isotable_procs.xsl /usr/local/lib/SchemaServer/utilities/gensfw_isotable_procs.xsl
	install -D --mode=755 ./gensfw_proc_from_table    /usr/local/lib/SchemaServer/utilities/gensfw_proc_from_table
	install -D --mode=755 ./gensfw_srm                /usr/local/lib/SchemaServer/utilities/gensfw_srm
	install -D --mode=755 ./gensfw_srm_from_proc      /usr/local/lib/SchemaServer/utilities/gensfw_srm_from_proc
	install -D --mode=755 ./gensfw_srm_from_proc_result      /usr/local/lib/SchemaServer/utilities/gensfw_srm_from_proc_result
	# Install to /usr/bin to make universally available:
	cp -sf /usr/local/lib/SchemaServer/utilities/gensfw               /usr/bin/gensfw
	cp -sf /usr/local/lib/SchemaServer/utilities/gensfw_session_procs /usr/bin/gensfw_session_procs
	cp -sf /usr/local/lib/SchemaServer/utilities/gensfw_isotable_procs /usr/bin/gensfw_isotable_procs
	cp -sf /usr/local/lib/SchemaServer/utilities/gensfw_proc_from_table /usr/bin/gensfw_proc_from_table
	cp -sf /usr/local/lib/SchemaServer/utilities/gensfw_srm /usr/bin/gensfw_srm
	cp -sf /usr/local/lib/SchemaServer/utilities/gensfw_srm_from_proc /usr/bin/gensfw_srm_from_proc
	cp -sf /usr/local/lib/SchemaServer/utilities/gensfw_srm_from_proc_result /usr/bin/gensfw_srm_from_proc_result

	# Install the man pages
	cp *.1 /usr/share/man/man1
	gzip -f /usr/share/man/man1/gensfw.1
	gzip -f /usr/share/man/man1/gensfw_isotable_procs.1
	# Install the info files
	makeinfo gensfw.info.txi --paragraph-indent=0 -o /usr/share/info
	gzip -f      /usr/share/info/gensfw.info
	install-info /usr/share/info/gensfw.info.gz /usr/share/info/dir

uninstall:
	# Uninstall the application:
	unlink /usr/bin/gensfw
	unlink /usr/bin/gensfw_session_procs
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw_bacts
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw_scripts_sql
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw_scripts_srm
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw_session_procs
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw_isotable_procs
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw_proc_from_table
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw_srm
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw_srm_from_proc
	rm -f /usr/local/lib/SchemaServer/utilities/gensfw_srm_from_proc_result
	# Remove documentation files
	install-info --delete /usr/share/info/gensfw.info.gz /usr/share/info/dir
	rm -f /usr/share/info/gensfw.info.gz
	rm -f /usr/share/man/man1/gensfw*.1.gz
