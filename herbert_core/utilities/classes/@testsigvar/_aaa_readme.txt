Use this class as the template for any other class that imlements unary and binary
operations on data with associated variances.

Not all the methods defined in this class are needed for binary operations.

Some methods are fully generic, others need to be edited for class specific
behaviour.



Private methods to manage unary and binary operations:
======================================================
[Note to developers if these are edited in sigvar and testsigvar to improve functionality:
 binary_op_manager and unary_op_manager must be identical, but binary_op_manager_single
 behaves uniquely : it must apply sigvar to float arrays]
 
    binary_op_manager          	Entirely generic - should be the same in all classes.

    binary_op_manager_single   	Defines the structure, but inside each branch of the
								if...elseif...end structure the call may be class
								dependent.
								[Note that sigvar has a slightly different operation
								from other classes: it must apply sigvar to float
								arrays.]

    unary_op_manager           	Defines the structure, but inside the for loop the
								call may be class dependent.


Public class-dependent required methods:
========================================

Requires that objects have the following methods to find the size of the
public signal and variance arrays, create a sigvar object from those
arrays, and set them from another sigvar object.

	>> sz = sigvar_size(obj)   	Returns size of public signal and variance
                                arrays
	>> w = sigvar(obj)          Create a sigvar object from the public
                                signal and variance arrays
	>> obj = sigvar_set(obj,w)  Set signal and variance in an object from
                                those in a sigvar object


Public unary and binary arithmetic operations:
==============================================
These will be applied element by element (so no matrix manipulation is performed.

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

   acos, acosh, acot, acoth, acsc, acsch, asec, asech, asin, asinh, atan, atanh, 
    cos,  cosh,  cot,  coth,  csc,  csch,  sec,  sech,  sin,  sinh,  tan,  tanh,
   exp, log, log10, sqrt

The list does not include e.g. abs because it is only those operation that
perform operation on a signal AND variance array that are included.

Note: the reason why mldivide is included is because in a binary operation
involving two objects of the same type, the attributes other than the signal
and error arrays will be progragated from the lefthand object. If we want to
divide A by B as A\B, then the attributes of A will be propagated. if we
perform B\A, then if the manipulation of the signal and error arrays is
inverted in the code of mldivide.m as compared to mrdivide.m, then the
output signal and errors will be the same as A/B but the attributes of 
B will be propagated.

