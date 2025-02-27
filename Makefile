.PHONY: all clean znnd version

GO ?= latest

ifeq ($(OS),Windows_NT) 
    detected_OS := Windows
else
    detected_OS := $(shell sh -c 'uname 2>/dev/null || echo Unknown')
endif

ifeq ($(detected_OS),Windows)
    EXECUTABLE=libznn.dll
endif
ifeq ($(detected_OS),Darwin)
    EXECUTABLE=libznn.dylib
endif
ifeq ($(detected_OS),Linux)
    EXECUTABLE=libznn.so
endif

SERVERMAIN = $(shell pwd)/cmd/znnd/main.go
LIBMAIN = $(shell pwd)/cmd/libznn/main_libznn.go
BUILDDIR = $(shell pwd)/build
GIT_COMMIT=$(shell git rev-parse HEAD)
GIT_COMMIT_FILE=$(shell pwd)/metadata/git_commit.go

$(EXECUTABLE):
	go build -o $(BUILDDIR)/$(EXECUTABLE) -buildmode=c-shared -tags libznn $(LIBMAIN)

libznn: $(EXECUTABLE) ## Build binaries
	@echo "Build libznn done."

znnd:
	go build -o $(BUILDDIR)/znnd $(SERVERMAIN)
	@echo "Build znnd done."
	@echo "Run \"$(BUILDDIR)/znnd\" to start znnd."

version:
	@echo "package metadata\n" > $(GIT_COMMIT_FILE)
	@echo "const (" >> $(GIT_COMMIT_FILE)
	@echo "\tGitCommit = \"${GIT_COMMIT}\"" >> $(GIT_COMMIT_FILE)
	@echo ")" >> $(GIT_COMMIT_FILE)

clean:
	rm -r $(BUILDDIR)/

all: znnd libznn
