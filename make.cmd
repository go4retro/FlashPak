lwasm -9bl -p cd -o obj\flash.bin src\flash.asm > obj\flash.lst
imgtool put coco_jvc_rsdos FLASH.dsk obj/flash.bin flash.bin
