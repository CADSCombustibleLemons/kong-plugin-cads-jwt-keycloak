UNIT_TEST_IMAGE:=jwt-keycloak-unit-test-image
INTE_TEST_IMAGE:=jwt-keycloak-inte-test-image

_build-unit-test-image:
	@echo "Building unit test image ..."
	@docker build -q -t ${UNIT_TEST_IMAGE} --build-arg PLUGIN_VERSION=${PLUGIN_VERSION} --build-arg KONG_VERSION=${KONG_VERSION} -f unit_tests/Dockerfile ..

_tests-unit: _build-unit-test-image
	@docker run -it --rm --net=host -v ${PWD}:/jwt-keycloak:ro ${UNIT_TEST_IMAGE}


_build-inte-test-image:
	@echo "Building integration test image ..."
	@docker build -q -t ${INTE_TEST_IMAGE} -f integration_tests/Dockerfile ..

_tests-integration: _build-inte-test-image
	@set -e; \
	docker run -it --rm --net=host -v ${PWD}/integration_tests/tests:/tests:ro ${INTE_TEST_IMAGE} python -m unittest /tests/TestBasics.py -v ;\
	docker run -it --rm --net=host -v ${PWD}/integration_tests/tests:/tests:ro ${INTE_TEST_IMAGE} python -m unittest /tests/TestConsumerMapping.py -v ;\
	docker run -it --rm --net=host -v ${PWD}/integration_tests/tests:/tests:ro ${INTE_TEST_IMAGE} python -m unittest /tests/TestIssuers.py -v ;\
	docker run -it --rm --net=host -v ${PWD}/integration_tests/tests:/tests:ro ${INTE_TEST_IMAGE} python -m unittest /tests/TestKeyRotation.py -v ;\
	docker run -it --rm --net=host -v ${PWD}/integration_tests/tests:/tests:ro ${INTE_TEST_IMAGE} python -m unittest /tests/TestRoles.py -v ;\
	docker run -it --rm --net=host -v ${PWD}/integration_tests/tests:/tests:ro ${INTE_TEST_IMAGE} python -m unittest /tests/TestScopes.py -v
