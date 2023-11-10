Unary and binary arithmetic operations
=======================================
Binary operations:

   +    plus
   -    minus
   /    mrdivide
   \    mldivide
   *    mtimes  
   ^    mpower


Unary operations:

   -w   uminus
   +w   uplus


Standard unary functions:

   tan, cos, asech, sqrt  etc.


Note: the reason why mldivide is included is because in a binary operation
involving two objects of the same type, the attributes other than the signal
and error arrays will be progragated from the lefthand object. If we want to
divide A by B as A\B, then the attributes of A will be propagated. if we
perform B\A, then if the manipulation of the signal and error arrays is
inverted in the code of mldivide.m as compared to mrdivide.m, then the
output signal and errors will be the same as A/B but the attributes of 
B will be propagated.


In class directory, place the methods:
---------------------------------------

   plus, minus, mrdivide, mldivide, mtimes, mpower
   uplus,  uminus

   acos, acosh, acot, ... sin, sqrt, tan, tanh


 In addition place the following methods in the public methods directory:

   [nd, sz] = dimensions (obj)   (will need to edit for particular class)

   w = sigvar(obj)               (Create a sigvar object for particular class)

   sz = sigvar_size(obj)         (conventional Matlab array size for signal)

   w = sigvar_set(w,obj)         (Set signal and variance fields for class)


   These will be used by the private methods binary_op_manager amd
   binary_op_manager_single (see below)




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
