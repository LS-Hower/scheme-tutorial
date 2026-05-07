SRC = src
DST ?= docs-test

SCRIBBLE = scribble
FLAGS = --dest $(DST)

SCRIBS = $(wildcard $(SRC)/*.scrbl)
HTMLS = $(patsubst $(SRC)/%.scrbl,$(DST)/%.html,$(SCRIBS))

all: $(HTMLS)

$(DST)/%.html: $(SRC)/%.scrbl
	$(SCRIBBLE) $(FLAGS) $<

clean-docs:
	rm -rf docs/*

publish: clean-docs
	$(MAKE) DST=docs
