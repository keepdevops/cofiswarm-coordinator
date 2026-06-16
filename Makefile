ROLE := coordinator
.PHONY: build test test-standalone-layout
build:
	./scripts/build-coordinator.sh
test: test-standalone-layout
test-standalone-layout:
	./test/scripts/assert-layout.sh $(ROLE)
