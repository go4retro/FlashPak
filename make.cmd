lwasm -9bl -p cd -o obj\flash.bin src\flash.asm > obj\flash.lst
;imgtool put coco_jvc_rsdos FLASH.dsk obj/flash.bin flash.bin
rm -f flash.dsk
decb dskini flash.dsk
decb copy src/autoexec.bas flash.dsk,AUTOEXEC.BAS -0 -t
decb copy -2 obj/flash.bin flash.dsk,FLASH.BIN
