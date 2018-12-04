all: test

solidity-test:
	npm run test

test: solidity-test

node_modules:
	npm install
