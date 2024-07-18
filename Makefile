
.PHONY: all
all: build compile

.PHONY: build
build:
	docker build --rm -f Dockerfile -t ffmpeg-docker:dev .
build.test:
	docker build --rm -f Dockerfile.test -t ffmpeg-docker:test .

.PHONY: compile
compile:
	docker run --rm --user="$(id -un):$(id -ug)" -v ${PWD}:/ffmpeg_build ffmpeg-docker:dev
compile.test:
	docker run --rm --user="$(id -un):$(id -ug)" -v ${PWD}:/ffmpeg_build ffmpeg-docker:test bash

.PHONY: run
run:
	docker run --rm -it --user="$(id -un):$(id -ug)" -v ${PWD}:/ffmpeg_build ffmpeg-docker:dev bash
run.test:
	docker run --rm -it --user="$(id -un):$(id -ug)" -v ${PWD}:/ffmpeg_build ffmpeg-docker:test bash

.PHONY: install
install:
	@install -v ./ffmpeg ./ffplay ./ffprobe -t ${HOME}/.local/bin/ && rm ./ffmpeg ./ffplay ./ffprobe
