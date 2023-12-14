SHELL=bash

WS = ws
WS_SEQ = ws-sequential
WS_PAR = ws-parallel
SOCK = $(PWD)/server.sock
NUMBER_OF_THREADS = 5
PAGE_TIMEOUT = 120
ECHO = 
PROCESSOR = $(ECHO) ocrd-vandalize
CLIPARAMS = -I DEFAULT -O VANDALIZED

# Clone the workspace and download only the `DEFAULT` fileGrp
$(WS)/mets.xml clone:
	ocrd -l DEBUG workspace -d $(WS) clone \
		'https://content.staatsbibliothek-berlin.de/dc/PPN891267093.mets.xml' \
		-q DEFAULT \
		--download

#
# Sequential workflow w/o METS server
#
$(WS_SEQ)/mets.xml: $(WS)/mets.xml
	cp -r $(WS) $(WS_SEQ)

sequential: $(WS_SEQ)/mets.xml
	cd $(WS_SEQ) ; \
	$(PROCESSOR) $(CLIPARAMS)

rm-sequential:
	rm -rf $(WS_SEQ)


#
# Parallel workflow w/o METS server
#

start-server: $(WS_PAR)/mets.xml
	ocrd workspace -d $(WS_PAR)  -U $(SOCK) server start

stop-server: $(WS_PAR)/mets.xml
	-ocrd workspace -d $(WS_PAR)  -U $(SOCK) server stop

rm-parallel: stop-server
	rm -rf $(WS_PAR)

$(WS_PAR)/mets.xml: $(WS)/mets.xml
	cp -r $(WS) $(WS_PAR)

parallel-chunks: page_ranges = $(shell ocrd workspace -d $(WS_PAR) list-page -D $(NUMBER_OF_THREADS) -f comma-separated)
parallel-chunks: CLIPARAMS := -U $(SOCK) $(CLIPARAMS)
parallel-chunks: $(WS_PAR)/mets.xml
	cd $(WS_PAR) ; \
	for chunk in $(page_ranges); do $(PROCESSOR) $(CLIPARAMS) -g $$chunk & done; \
	wait

parallel: CLIPARAMS := -U $(SOCK) $(CLIPARAMS)
parallel: $(WS_PAR)/mets.xml
	cd $(WS_PAR) ; \
	ocrd workspace list-page | \
	parallel -j $(NUMBER_OF_THREADS) "timeout $(PAGE_TIMEOUT) $(PROCESSOR) $(CLIPARAMS) -g {} || $(ECHO) ocrd-dummy $(CLIPARAMS) -g {}"

