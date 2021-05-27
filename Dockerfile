# stage 1: builder
FROM alpine:latest as builder

RUN apk --no-cache add nasm gcc make

COPY . /usr/src
WORKDIR /usr/src

RUN make tiny-os.img

# stage 2: emulator
FROM alpine:latest

RUN apk --no-cache add qemu-system-x86_64 qemu-ui-curses

COPY --from=builder /usr/src/tiny-os.img /tiny-os.img

CMD ["qemu-system-x86_64", "-curses", "-drive", "file=/tiny-os.img,format=raw,index=0,media=disk"]
