GOPATH  := $(shell go env GOPATH)
GOCACHE := $(shell go env GOCACHE)
GOBIN   ?= $(GOPATH)/bin

RICHGO := $(GOBIN)/richgo
GOFUMPT := $(GOBIN)/gofumpt

GO := $(shell command -v go 2> /dev/null)
ifndef GO
$(error go is required, please install)
endif

$(RICHGO):
	$(GO) install github.com/kyoh86/richgo@v0.3.6

$(GOFUMPT):
	$(GO) install mvdan.cc/gofumpt@v0.1.1

PKGS  = $(or $(PKG),$(shell env GO111MODULE=on $(GO) list ./...))
FILES = $(shell find . -name '.?*' -prune -o -name vendor -prune -o -name '*.go' -print)

TIMEOUT  = 10m
TESTPKGS = $(shell env GO111MODULE=on $(GO) list -f \
	'{{ if or .TestGoFiles .XTestGoFiles }}{{ .ImportPath }}{{ end }}' \
	$(PKGS))

fmt: $(GOFUMPT)
	$(GO) fmt $(PKGS)
	$(GOFUMPT) -s -w $(FILES)

test: $(RICHGO)
	$(GO) test -timeout $(TIMEOUT) $(ARGS) $(TESTPKGS) | tee >(RICHGO_FORCE_COLOR=1 $(RICHGO) testfilter); \
		test $${PIPESTATUS[0]} -eq 0

check: fmt test
