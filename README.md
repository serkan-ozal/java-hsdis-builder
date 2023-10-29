# Java hsdis (HotSpot Disassembler) Builder

Builds Java hsdis (HotSpot Disassembler) library for different JDKs, operating systems and CPU architectures.  

## Supported JDKs

| JDK / OS               | `ubuntu (x86-64)`  |  `macos (x86-64)`  |  `macos (arm64)`   |                                     `windows (x86-64)`                                     |
|:-----------------------|:------------------:|:------------------:|:------------------:|:------------------------------------------------------------------------------------------:|
| `OpenJDK - 21`         | :white_check_mark: | :white_check_mark: | :white_check_mark: | :x: </br> Build fails with `LINK : fatal error LNK1181: cannot open input file 'rc'` error |          
| `Amazon Corretto - 21` | :white_check_mark: | :white_check_mark: | :white_check_mark: | :x: </br> Build fails with `LINK : fatal error LNK1181: cannot open input file 'rc'` error | 
