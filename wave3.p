; Compute the condition bits & find the opcode. If the opcode will not run, then set all return bits high (return 111111)
; (c) 2015 Jose Rivas-Garcia & Julia Goldman

; The bottom 4 bits (i0 to i3) are the flags that were set during the previous instruction.
; The top 3 bits (i29 to i31) define what type of conditional we are trying to match. 
; In order (from 000 to 111), these are: always, never, =, =/=, <, <=, >=, and >.

; These are compared to the flags raised by the previous instruction that set them.
; The flags are as follows:
; i0 is signed overflow (V), i1 is carry (C), i2 is zero (Z), i3 is negative (N).

; NOTE: Capital I before a bit # represents the inverse of that particular bit

; This first AND gate recognizes the never condition. (001)
t1 =  I31&I30&i29 

; The following all recognize the other conditions. However, t2 to t12 will only be high if the condition is NOT met.
; NOTE: Since the "always" condition always runs the instruction, we do not attempt to recognize it and just return the opcode.

; This recognizes the equal condition. The condition is not met if Z is low.
t2 =  I31&i30&I29&I2 

; This recognizes the =/= condition. The condition is not met if Z is high.
t3 =  I31&i30&i29&i2 

; These recognizes the < condition. The condition is not met if V = N.
t4 =  i31&I30&I29&I3&I0 
t5 =  i31&I30&I29&i3&i0 

; These recognizes the <= condition. The condition is not met if (V = N AND Z = 0).
t6 =  i31&I30&i29&I2&I3&I0 
t7 =  i31&I30&i29&I2&i3&i0 

; These recognizes the >= condition. The condition is not met if (V =/= N).
t8 =  i31&i30&I29&I3&i0 
t9 =  i31&i30&I29&i3&I0 

; This recognizes the > condition. The condition is not met if (Z= 1 OR N =/= V).
t10 = i31&i30&i29&i3&I0 
t11 = i31&i30&i29&i2 
t12 = i31&i30&i29&I3&i0 
            
; Get the opcode (the instruction that is to be simulated)            
t23 = i23
t24 = i24
t25 = i25
t26 = i26
t27 = i27
t28 = i28

; o0 to o5 will either return the opcode found in t23 - t28 OR will return 111111. 
; If the latter case is returned, then this signifies that the conditions were NOT met,
; and the instruction should not be run. In our program, this signifies a jump back to the 
; start of our loop, skipping the instruction passed to this PLA.

o0 = t23 | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 | t10 | t11 | t12
o1 = t24 | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 | t10 | t11 | t12
o2 = t25 | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 | t10 | t11 | t12
o3 = t26 | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 | t10 | t11 | t12
o4 = t27 | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 | t10 | t11 | t12
o5 = t28 | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 | t10 | t11 | t12
