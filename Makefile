tests := $(wildcard test/*.sh)

.PHONY: test test-% obsidian github

# compile obsidian version
obsidian:
	@echo "Compiling obsidian version"
	@sh scripts/convert-files.sh 1
	@sh scripts/convert-links.sh 1

# compile github version
github:
	@echo "Compiling github version"
	@sh scripts/convert-files.sh 2
	@sh scripts/convert-links.sh 2

# test to run all test files
test:
	@for test_file in $(tests); do \
		echo "Running test $$test_file"; \
		$$test_file || exit 1; \
	done

# individual test to run a specific test file
test-%:
	@echo "Running test $*"
	@sh ./test/$*.sh || exit 1
