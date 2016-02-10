; Calculate the condition bits & find the opcode(unless nv)
; (c) 2015 Jose Rivas-Garcia & Julia Goldman

t1 =  I31&I30&i29 
t2 =  I31&i30&I29&I2 
t3 =  I31&i30&i29&i2 
t4 =  i31&I30&I29&I3&I0 
t5 =  i31&I30&I29&i3&i0 
t6 =  i31&I30&i29&I2&I3&I0 
t7 =  i31&I30&i29&I2&i3&i0 
t8 =  i31&i30&I29&I3&i0 
t9 =  i31&i30&I29&i3&I0 
t11 = i31&i30&i29&i2 
t10 = i31&i30&i29&i3&I0 
t12 = i31&i30&i29&I3&i0 
            
t23 = i23
t24 = i24
t25 = i25
t26 = i26
t27 = i27
t28 = i28

o0 = t23 | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 | t10 | t11 | t12
o1 = t24 | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 | t10 | t11 | t12
o2 = t25 | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 | t10 | t11 | t12
o3 = t26 | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 | t10 | t11 | t12
o4 = t27 | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 | t10 | t11 | t12   
o5 = t28 | t1 | t2 | t3 | t4 | t5 | t6 | t7 | t8 | t9 | t10 | t11 | t12
