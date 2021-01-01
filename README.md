# DigitalLogicFinalProject
Digital Logic Lecture Final Project in the first term of year 2020-21

## Content
Handwritting number distinguishing with CNN by Nexys 4 DDR in Verilog HDL.

## Data Type 
8 bit float
### 1 bit sign
### 7 bit tail 
### 8'b10000000 means 1
### eg. 8'b01000000 means 1.01b = 1.25d
## Data Addr
0x000 Conv1 Filter 0 ~ 4

0x001 Conv1 Filter 5 ~ 9

...

0x005 Conv1 Filter 25 ~ 29

0x006 Conv1 Filter 30 ~ 31, bias 0 ~ 31

0x007 Conv2 Filter 0 ~ 4

0x008 Conv2 Filter 5 ~ 9

...

0x06B Conv2 Filter 500 ~ 504

0x06C Conv2 Filter 505 ~ 509

0x06D Conv2 Filter 510 ~ 511

0x06E Conv2 Bias 0 ~ 127

0x06F Conv2 Bias 128 ~ 255

0x070 Conv2 Bias 256 ~ 383

0x071 Conv2 Bias 384 ~ 511

0x072 FC1 Bias

0x073 FC1 0 Weight0

0x074 FC1 0 Weight1

0x075 FC1 1 Weight0

0x076 FC1 1 Weight1

...

0x171 FC1 127 Weight0

0x172 FC1 127 Weight1

0x173 FC2 Bias

0x174 FC2 Weight0

0x175 FC2 Weight1

...

0x17D FC2 Weight9
