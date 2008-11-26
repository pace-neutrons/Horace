Unary and binary arithmetic operations
=======================================
Binary operations:

   +   -   ./   .*   .^


Unary operations:

   +w   -w


Standard unary functions:

   tan, cos, asech, sqrt  etc.




In class directory, place the methods:
---------------------------------------

   plus, minus, mrdivide, mtimes, mpower
   uplus,  uminus

   acos, acosh, acot, ... sin, sqrt, tan, tanh


 In addition place the following methods in the public methods directory:

   [nd, sz] = dimensions (obj)   (will need to edit for particular class)

   w = sigvar(obj)               (Create a sigvar object for particular class)

   sz = sigvar_size(obj)         (get conventional Matlab array size for signal)

   obj = sigvar_set(w,obj)       (Set signal and variance fields for class)

   These will be used by the private methods binary_op_manager amd
   binary_op_manager_single (see below).




In the private methods directory:
---------------------------------

 *Methods:
   binary_op_manager 

   binaray_op_manager_single   (may need to edit for particular class)

   unary_op_manager            (may need to edit for particular class)



 *Function:
   name = classname  (edit for the particular class)


Notes:
======
The routines acos, acosh... tanh and  minus, plus ...uminus are the same as
 those in the sigvar directory.

binary_op_manager, binary_op_manager_single are the same too, although in
@sigvar an identical structure is not necessary, as this class is at the 
bottom of the operator chain. For the sake of completeness they are 
the generic methods too.

In the case of @sigvar, there are operators cos_single, acosh_single...
but these are *NOT* needed by other classes.