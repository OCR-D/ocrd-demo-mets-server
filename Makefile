SHELL=bash

WS = ws
WS_SEQ = ws-sequential
WS_PAR = ws-parallel
SOCK = $(PWD)/server.sock
NUMBER_OF_THREADS = 5
ECHO = 
PROCESSOR = $(ECHO) ocrd-vandalize

# Clone the workspace and download only the `DEFAULT` fileGrp
clone:
	ocrd -l DEBUG workspace -d $(WS) clone \
		'https://content.staatsbibliothek-berlin.de/dc/PPN891267093.mets.xml' \
		-q DEFAULT \
		--download

#
# Sequential workflow w/o METS server
#
$(WS_SEQ)/mets.xml:
	cp -r $(WS) $(WS_SEQ)

sequential: $(WS_SEQ)/mets.xml
	cd $(WS_SEQ) ; \
	$(PROCESSOR) -I DEFAULT -O VANDALIZED

rm-sequential:
	rm -rf $(WS_SEQ)


#
# Parallel workflow w/o METS server
#

start-server: $(WS_PAR)/mets.xml
	ocrd workspace -d $(WS_PAR)  -U $(SOCK) server start

rm-parallel:
	rm -rf $(WS_PAR)

$(WS_PAR)/mets.xml:
	cp -r $(WS) $(WS_PAR)

parallel: $(WS_PAR)/mets.xml
	cd $(WS_PAR) ; \
	page_ranges=( $$(ocrd workspace list-page -D $(NUMBER_OF_THREADS) -f comma-separated) ) ;\
	for chunk in $$(seq 0 $$(( $(NUMBER_OF_THREADS) -1 )));do \
		$(PROCESSOR) -U $(SOCK) -I DEFAULT -O VANDALIZED -g $${page_ranges[$$chunk]} &\
	done; wait

