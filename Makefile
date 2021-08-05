all: build

build:
	docker build -f Dockerfile -t mock_server .

shell:
	docker run -p 9293:9293 -v $$(pwd):/app -ti mock_server bash

run:
	docker run -p 9293:9293 -v $$(pwd):/app -t mock_server

start-mock:
	docker run -p 9293:9293 -v $$(pwd):/app -t mock_server ./start-mock.sh
