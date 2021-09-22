prod-tag = macroflask-prod
dev-tag = macroflask-dev

help:
	@echo "Production targets:"
	@echo "\tprod-image --builds the production image"
	@echo "\tprod --runs the production container"
	@echo "\tprod-test --runs the tests on the production container; default: all tests; specific tests: 'ARGS=<filename>' "
	@echo "\t\texample: make prod-test ARGS=test_command.py"
	@echo ""
	@echo "Test targets:"
	@echo "\ttest-image --builds the test image"
	@echo "\ttest --runs the tests on the test container; default: all tests; specific tests: 'ARGS=<filename>' "
	@echo "\t\texample: make test ARGS=test_command.py"

prod: prod-image
	docker run --privileged -v /lib/modules:/lib/modules -v /var/run/docker.sock:/var/run/docker.sock $(prod-tag)

prod-test: prod-image
	. environment/env-prod; docker run \
		--network=$${COMPOSE_NETWORK} \
		--privileged \
		-v /lib/modules:/lib/modules \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--entrypoint "/bin/bash" $(prod-tag) -c "/app/test-entrypoint.sh tests/$(ARGS)"

test: test-image
	. environment/env-dev; docker run \
		--network=$${COMPOSE_NETWORK} \
		--privileged \
		-v /lib/modules:/lib/modules \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--entrypoint "/bin/bash" $(dev-tag) -c "/app/test-entrypoint.sh tests/$(ARGS)"

prod-image:
	. environment/env-prod; docker build \
		--build-arg FLASK_APP=$${FLASK_APP} \
		--build-arg FLASK_ENV=$${FLASK_ENV} \
		--build-arg TOYNET_IMAGE_TAG=$${TOYNET_IMAGE_TAG} \
		--build-arg MINI_FLASK_PORT=$${MINI_FLASK_PORT} \
		--build-arg COMPOSE_NETWORK=$${COMPOSE_NETWORK} \
		-f Dockerfile -t $(prod-tag) .

test-image:
	. environment/env-dev; docker build \
		--build-arg FLASK_APP=$${FLASK_APP} \
		--build-arg FLASK_ENV=$${FLASK_ENV} \
		--build-arg TOYNET_IMAGE_TAG=$${TOYNET_IMAGE_TAG} \
		--build-arg MINI_FLASK_PORT=$${MINI_FLASK_PORT} \
		--build-arg COMPOSE_NETWORK=$${COMPOSE_NETWORK} \
		-f dev.Dockerfile -t $(dev-tag) .
