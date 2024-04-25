build:
	docker build --rm -f Dockerfile -t ffmpeg-docker:dev .
copy-file:
	docker create --name dummy ffmpeg-docker:dev
	docker cp dummy:/root/bin/ffmpeg .
	docker rm -f dummy

run:
	docker run --rm -it -v ${PWD}/outfdir:/outdir ffmpeg-docker:dev bash
