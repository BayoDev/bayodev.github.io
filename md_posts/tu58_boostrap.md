---
title: Bootstrap tu58 tapes on a PDP-11
date: 09/03/2024
---

This article is meant as a way to aggregate some information that I had to gather
in order to write a bootloader for tu58 tapes that is small enough to be typed in ODT.

> If you just want the code to type into ODT click [here](#type-in)

## The importance of tu58 images

If you want to get a basic PDP-11 system up and running, the simplest and most affordable way to get mass-storage is by emulating a tu58 tape. There are two reasons for this, the first is that the tu58 just uses a serial connection, so no special board is required, the second one is that it can easily be emulated.

Here are some of the main emulators online:

- [https://github.com/AK6DN/tu58em](https://github.com/AK6DN/tu58em)
- [https://github.com/j-hoppe/tu58fs/releases](https://github.com/j-hoppe/tu58fs/releases)

## Bootstrap code

If you search for tu58 boostrap codes on the internet you'll most likely find these

- [Diane's pdp-11 page code](https://web.archive.org/web/20240119034125/http://www.diane-neisius.de/pdp11/index_E.html#tape)
- [Bootrstrap code from tu58 user's manual](https://forum.vcfed.org/index.php?threads/boot-a-pdp-11-03-from-an-emulated-tu58.42283/post-512407)

Suprisingly the code from the user's manual fail the booting process with many tu58 tapes, while diane's one is much more reliable.

While I was troubleshooting my PDP-11, as suggested by a user in the vcfed forum where I was asking for some guidance[^forum], I decided to write my version of the bootstrap to get a better understanding of where the failure was happening.

### The tu58 protocol

The good thing about writing the bootstrap code is that you dont really need to use any complicated protocol message for the tu58 but you can simply use the special purpose *BOOT* command.

When this command is issued the tu58 will send the first 512 bytes of the tape without any type of acknowledgement or special protocol conventions. In a bootable tape these 512 bytes will contain the code that will carry on the booting process. _[From section 3-2 of TU58 user's guide[^guide]]_

### My code

This is what I came up with the help of @daver2 and @Hunta from the vcfed forum^[1](#bottom)^

```
; Configuration parameters

tuAddr=176500
codeStart=1000

.ASECT
.=codeStart

clr r0                  
mov #tuAddr,r1
wait2:
    tstb 04(r1)
    bpl wait2
mov #04,6(r1)               ; Init command
wait3:
    tstb 04(r1)
    bpl wait3
mov #10,6(r1)               ; Boot command
wait4:  
    tstb 04(r1)
    bpl wait4
mov #00,6(r1)               ; Drive number

mov #00,r2                   ; mem pointer
mov #1000,r3                 ; Loop counter
dataLoop:
    checkRCX:
        TSTB (r1)
        bpl checkRCX
    movb 02(r1),(r2)+
    sob r3,dataLoop
clr pc
```

The code is really simple, it just sends three commands over the serial line where the tu58 is located (176500 is the default address). The first command is the INIT command, the second one is the BOOT command and the third one indicates the drive number (0 in this case).

After the three commands are sent, the tu58 will start sending the 512 bytes of data that _dataLoop_ read and stores in memory starting from address 0. After the 512 are read, the execution is passed to the newly received code.

### Beware of the registers!

What prevented my code from working for a long time and what (I think) prevents the tu58 user's guide code to work is the lack of support for what seems like an 'undocumented' feature of some tu58 tapes. Some tapes such as XXDP ones, requires R0 to contain the drive number and R1 to contain the address of the CSR for the serial connection to the tu58 (by default 176500). I was able to find out about this, and fix my code, thanks to a disassembly of a XXDP tape available [here](https://web.archive.org/web/20190612155849/http://web.frainresearch.org:8080/projects/mypdp/xxdpdd.php) that was of invaluable help.

## ODT commands, at last {#type-in}

This can be easily sent by using the "Send file" function of "Tera Term". Or typed by hand.

```
1000/005000
1002/012701
1004/176500
1006/105761
1010/000004
1012/100375
1014/012761
1016/000004
1020/000006
1022/105761
1024/000004
1026/100375
1030/012761
1032/000010
1034/000006
1036/105761
1040/000004
1042/100375
1044/012761
1046/000000
1050/000006
1052/012702
1054/000000
1056/012703
1060/001000
1062/105711
1064/100376
1066/116122
1070/000002
1072/077305
1074/005007
1000G
```

## A digression on where to find bootable tu58 images

I decided to add this section since I had some trouble finding bootable tu58 tapes online, the only one I was able to find comes from a release of one of the emulators, tu58fs [here](https://github.com/j-hoppe/tu58fs/releases). In this release you can find some demo images such as rt11v57.tu58 that are bootable with any emulator and works with my boostrap code.

## References

[^guide]: [TU58 user's guide](https://web.archive.org/web/20240309145426/https://bitsavers.org/pdf/dec/dectape/tu58/EK-0TU58-UG-004_TU58_DECtape_II_Users_Guide_Dec83.pdf)

[^forum]: [My thread on the vcfed forum](https://forum.vcfed.org/index.php?threads/problems-booting-pdp-11-through-tu58-emulator.1245931/)