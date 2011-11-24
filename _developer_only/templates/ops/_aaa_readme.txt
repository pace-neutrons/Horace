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
(specific methods indicated by *):

   * [nd, sz] = dimensions (obj)   [Required] (specific, public method)
   Return the number of dimensions and size. Not necessarily the size of
   a matlab array: this gives the 'public' number of dimensions and size,
   but the private arrays may be different. The rules are:
    - If empty object, nd=[], sz=[]          (nb: []==zeros(0,0)) 	*** OR SHOULD IT RETURN nd IF E.G. IX_DATASET_1D?
    - If 0D    object, nd=0,  sz=zeros(1,0) 
	- if 1D    object, nd=1,  sz=n1
	- If 2D    object, nd=2,  sz=[n1,n2]
	- If 3D    object, nd=3,  sz=[n1,n2,n3]     even if n3=1
	- If 4D    object, nd=4,  sz=[n1,n2,n3,n4]  even if n4=1
	    :

   
   * w = sigvar(obj)               [Required] (specific, public method)
   Create a sigvar object from an object of the class

   
   * sz = sigvar_size(obj)         [Required] (specific, public method)
   Return the conventional Matlab array size of the signal array that will
   be created by sigvar method.
   This should return the same result as tmp=sigvar(obj); sz=size(tmp.s)
   However, it may be that this is an expensive operation, but sz can be
   determined straightforwardly from the object without creating the sigvar
   object.

   
   * w = sigvar_set(w,obj)         [Required] (specific, public method)
   Set signal and variance fields for according to the contents of a sigvar
   object.


   These will be used by the private methods below.


In the private methods directory:
---------------------------------

 Methods:
   binary_op_manager 			[Required] (generic, private method)

   * binary_op_manager_single   [Required] (specific, private method)
   May need to edit the provided template for the class.

   * unary_op_manager        	[Required] (specific, private method)
   May need to edit the provided template for the class.

 Functions:
 ----------
  * classname 					[Required] (specific, private function)
  
	Returns name of class as a character string. Needed by unary_op_manager and
	binary_op_manager_single.
	
	**IMPORTANT NOTE** If a class is split across several directories (i.e. there are several
    instances of @my_class, for example for tidy organisation) then classname.m
	must live in the same private folder as binary_op_manager, binary_op_manager_single
	and unary_op_manager.

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
