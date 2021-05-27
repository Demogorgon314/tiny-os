TARGET := tiny-os.img
OBJS := entry.o main.o vgastr.o

ifeq ($(shell uname), Linux)
ASM := nasm
CC  := gcc
LD  := ld
endif

ifeq ($(shell uname), Darwin)
ASM := nasm
CC 	:= x86_64-elf-gcc
LD 	:= x86_64-elf-ld
endif

ASMFLAGS := -f elf32
CFLAGS   := -c -Os -std=c99 -m32 -Wall -Wextra -Werror -fno-pie -fno-stack-protector -fomit-frame-pointer -fno-builtin -fno-common -ffreestanding
LDFLAGS  := -s -static -T layout.ld -n -m elf_i386


.PHONY: all clean run docker docker-image

all: clean run

run: $(TARGET)
	qemu-system-x86_64 -curses -drive 'file=$<,format=raw,index=0,media=disk'
run_window: $(TARGET)
	qemu-system-x86_64 $<
clean:
	rm -f $(TARGET) $(OBJS)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<
%.o: %.c *.h
	$(CC) $(CFLAGS) -o $@ $<

docker: docker-image
	docker run --rm -it --name tiny-os-emu tiny-os-emu

docker-image: Dockerfile
	docker build -t tiny-os-emu .