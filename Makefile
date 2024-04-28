
all: build copy-file install

build:
	docker build --rm -f Dockerfile -t ffmpeg-docker:dev .
copy-file:
	docker create --name dummy ffmpeg-docker:dev
	docker cp dummy:/root/bin/ffmpeg .
	docker rm -f dummy
install:
	mv ./ffmpeg ${HOME}/.local/bin/
run:
	docker run --rm -it -v ${PWD}/outfdir:/outdir ffmpeg-docker:dev bash
