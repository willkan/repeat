TESTS = $(shell find test -type f -name *.test.*)
NPM_REGISTRY = --registry=http://registry.npm.taobao.net --disturl=http://dist.cnpmjs.org
NPM_INSTALL_TEST = PYTHON=`which python2.6` NODE_ENV=test npm install $(NPM_REGISTRY)
NPM_INSTALL_PRODUCTION = PYTHON=`which python2.6` NODE_ENV=production npm install $(NPM_REGISTRY)

-TESTS := $(sort $(TESTS))
-JS_TESTS := $(patsubst %.coffee, %.js, $(-TESTS))

-INIT_DIR := logs

-BIN_MOCHA := ./node_modules/.bin/mocha
-BIN_COFFEE := ./node_modules/coffee-script/bin/coffee
-BIN_ISTANBUL := ./node_modules/.bin/istanbul

-RELEASE_NOT_NEED := ./node_modules test logs pkg out

default: dev
-common-pre: clean -npm-install

test: -common-pre
	@echo test
	@mkdir $(-INIT_DIR)
	@$(-BIN_MOCHA) \
		--no-colors \
		--ignore-leaks \
		--compilers coffee:coffee-script/register \
		--reporter tap \
		$(-TESTS)

-cov-pre: -common-pre
	@echo 'cov pre'
	@mkdir out out/test
	@rsync -av . ./out/test --exclude out --exclude .idea --exclude node_modules
	@rsync -av ./node_modules ./out/test
	@$(-BIN_COFFEE) -cb out/test
	@find ./out/test -path ./out/test/node_modules -prune -o -name "*.coffee" -exec rm -rf {} \;
	@cd out/test && mkdir $(-INIT_DIR)

test-cov: -cov-pre
	@cd out/test && \
	  $(-BIN_ISTANBUL) cover ./node_modules/.bin/_mocha -- -u exports -R tap $(-JS_TESTS) && \
	  $(-BIN_ISTANBUL) report html

test-js: -cov-pre
	@cd out/test && \
	  $(-BIN_MOCHA) --no-colors --ignore-leaks --reporter tap $(-JS_TESTS)

-release-pre: -common-pre
	@echo 'release pre'
	@mkdir out out/release
	@cd out/release && mkdir $(-INIT_DIR)
	@rsync -av . ./out/release --exclude out --exclude .git --exclude node_modules
	@rsync -av ./node_modules ./out/release
	@$(-BIN_COFFEE) -cb out/release
	@find ./out/release -name "*.coffee" -exec rm -rf {} \;
	@mkdir ${-INIT_DIR}
	@cd out/release && \
	  $(-BIN_MOCHA) --no-colors --reporter tap $(-JS_TESTS)

release: -release-pre
	@cd out/release && rm -rf $(-RELEASE_NOT_NEED) && $(NPM_INSTALL_PRODUCTION)
	@echo 'make release done'

dev: -common-pre
	@mkdir $(-INIT_DIR)

-npm-install:
	@$(NPM_INSTALL_TEST)

clean:
	@echo 'clean'
	@rm -rf out logs
