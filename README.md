# BasicCPU
This project was built by Lukas Brazdeikis, Haliunaa Munkhuu, and Raphael Do between August 2022 and December 2022.

This is a project representing a single core, 1 wide 5 stage processor. This processor is able to run assembly I and J type instructions. The CPU has the following stages built: Instruction, Decode, Execute (with integer ALU), Writeback, and Memory. 

This project was initially written in Structural Intel Verilog, but has been converted to Behavioral Intel Verilog. We lost the original version. This means that the original project we wrote was done by building all microarchitectural pieces with logic gates. The original version of the code did not use any "syntactic sugar" like assign, +, <<, if-else, for loops, etc.
