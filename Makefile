.PHONY: help build run test lint fmt fmt-check clean docker-build docker-run docker-test install-tools

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the application
	go build -v -o bin/backend-go .

run: ## Run the application
	go run main.go

test: ## Run tests
	go test -v -race -coverprofile=coverage.txt -covermode=atomic ./...

lint: ## Run golangci-lint
	$(shell go env GOPATH)/bin/golangci-lint run --timeout=10m

fmt: ## Format code
	go fmt ./...
	gofmt -s -w .

fmt-check: ## Check code formatting
	@echo "Checking code formatting..."
	@if [ -n "$$(gofmt -l .)" ]; then \
		echo "The following files are not formatted correctly:"; \
		gofmt -l .; \
		echo "Please run 'make fmt' to format the code."; \
		exit 1; \
	fi
	@echo "All files are formatted correctly."

clean: ## Clean build artifacts
	rm -rf bin/
	rm -f coverage.txt

docker-build: ## Build Docker image
	docker build -t backend-go:latest .

docker-run: ## Run Docker container
	docker-compose up

docker-test: ## Test Docker build
	docker build -t backend-go:test .

install-tools: ## Install development tools
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install golang.org/x/tools/cmd/goimports@latest
	go install github.com/securego/gosec/v2/cmd/gosec@latest

mod-tidy: ## Run go mod tidy
	go mod tidy

mod-download: ## Download dependencies
	go mod download

security-scan: ## Run security scan with gosec
	$(shell go env GOPATH)/bin/gosec ./...

coverage: test ## Generate test coverage report
	go tool cover -html=coverage.txt -o coverage.html

check: fmt lint test ## Run all checks (format, lint, test)

ci: install-tools check ## Run CI checks locally