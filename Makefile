
all: build copy-file install

build:
	docker build --rm -f Dockerfile -t ffmpeg-docker:dev .
copy-file:
	docker create --name dummy ffmpeg-docker:dev
	docker cp dummy:/root/bin/ffmpeg .
	docker cp dummy:/root/bin/ffplay .
	docker rm -f dummy
install:
	mv -v ./ffmpeg ${HOME}/.local/bin/
	mv -v ./ffplay ${HOME}/.local/bin/
run:
	docker run --rm -it ffmpeg-docker:dev bash
