GOPATH  := $(shell go env GOPATH)
GOCACHE := $(shell go env GOCACHE)
GOBIN   ?= $(GOPATH)/bin

RICHGO := $(GOBIN)/richgo
GOLANGCILINT   := $(GOBIN)/golangci-lint
GOFUMPT := $(GOBIN)/gofumpt

$(RICHGO):
	$(GO) install github.com/kyoh86/richgo@v0.3.6

$(GOLANGCILINT):
	# To bump, simply change the version at the end to the desired version. The git sha here points to the newest       commit
	# of the install script verified by our team located here: https://github.com/golangci/golangci-lint/blob/mast      er/install.sh
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/b90551cdf9c6214075f2a40d1b5595c6b41ffff0/i      nstall.sh | sh -s -- -b ${GOBIN} v1.43.0


GO := $(shell command -v go 2> /dev/null)
ifndef GO
$(error go is required, please install)
endif

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

lint: $(GOLANGCILINT)
	$(GOLANGCILINT) run

check: fmt lint test
