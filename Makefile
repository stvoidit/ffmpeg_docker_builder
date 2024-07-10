
.PHONY: all
all: build compile

.PHONY: build
build:
	docker build --rm -f Dockerfile -t ffmpeg-docker:dev .

.PHONY: compile
compile:
	echo ${PWD}
	docker run --rm --user="$(id -un):$(id -ug)" -v ${PWD}:/ffmpeg_build ffmpeg-docker:dev

.PHONY: install
install:
	@install -v ./ffmpeg ./ffplay ./ffprobe -t ${HOME}/.local/bin/ && rm ./ffmpeg ./ffplay ./ffprobe

.PHONY: run
run:
	docker run --rm -it --user="$(id -un):$(id -ug)" -v ${PWD}:/ffmpeg_build ffmpeg-docker:dev bash
