include makefiles/*.mk

IMAGE?=kong-plugin-jwt-keycloak
KONG_VERSION?=3.2.2
FULL_IMAGE_NAME:=${IMAGE}:${KONG_VERSION}-alpine

PLUGIN_VERSION?=1.6.1-1
PLUGIN_NAME?=kong-plugin-cads-jwt-keycloak

TEST_VERSIONS?=3.2.2

### Docker ###

build:
	@echo "Building image ..."
	docker build --pull -q -t ${FULL_IMAGE_NAME} --build-arg KONG_VERSION=${KONG_VERSION} --build-arg PLUGIN_VERSION=${PLUGIN_VERSION} .

run: build
	docker run -it --rm ${FULL_IMAGE_NAME} kong start --vv

exec: build
	docker run -it --rm ${FULL_IMAGE_NAME} ash

### LuaRocks ###

lua-build:
	@luarocks make ;\
	luarocks pack ${PLUGIN_NAME} ${PLUGIN_VERSION}

upload:
	luarocks upload ${PLUGIN_NAME}-${PLUGIN_VERSION}.rockspec --api-key=${API_KEY}

local-install: lua-build
	luarocks install ${PLUGIN_NAME}-${PLUGIN_VERSION}.all.rock

### Testing ###

local-run: local-install
	@kong stop ;\
	kong start

local-logs:
	tail -f /var/log/kong/error.log | grep handler.lua

start: kong-db-start kong-start
restart: kong-stop kong-start
restart-all: stop start
stop: kong-stop kong-db-stop

test-unit: keycloak-start
	@echo ======================================================================
	@echo "Running unit tests with kong version ${KONG_VERSION}"
	@echo

	@cd tests && $(MAKE) --no-print-directory _tests-unit PLUGIN_VERSION=${PLUGIN_VERSION} KONG_VERSION=${KONG_VERSION}

	@echo
	@echo "Unit tests passed with kong version ${KONG_VERSION}"
	@echo ======================================================================

test-integration: restart-all sleep keycloak-start
	@echo ======================================================================
	@echo "Testing kong version ${KONG_VERSION} with ${KONG_DATABASE}"
	@echo

	@cd tests && $(MAKE) --no-print-directory _tests-integration PLUGIN_VERSION=${PLUGIN_VERSION}

	@echo
	@echo "Testing kong version ${KONG_VERSION} with ${KONG_DATABASE} was successful"
	@echo ======================================================================

test: test-unit test-integration

test-all: keycloak-start
	@echo "Starting integration tests for multiple versions"
	@set -e; for t in  $(TEST_VERSIONS); do \
		$(MAKE) --no-print-directory test-unit PLUGIN_VERSION=${PLUGIN_VERSION} KONG_VERSION=$$t ; \
    $(MAKE) --no-print-directory test-integration PLUGIN_VERSION=${PLUGIN_VERSION} KONG_VERSION=$$t KONG_DATABASE=postgres ; \
		$(MAKE) --no-print-directory test-integration PLUGIN_VERSION=${PLUGIN_VERSION} KONG_VERSION=$$t KONG_DATABASE=cassandra ; \
    done
	@echo "All test successful"

sleep:
	@sleep 5
