compile:
	coffee -c -o lib src/simple_pubsub_client.coffee
	coffee -c -o bin src/simple_pubsub_server.coffee

npm: compile
	npm publish

clean:
	rm -rf lib bin

.PHONY: compile npm clean
