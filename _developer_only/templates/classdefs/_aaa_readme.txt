====================================================================================
Generic methods for any class
====================================================================================

Alteration history
------------------
15 august 2009 (T.G.Perring):
     - isvalid.m altered
     - checkfields.m additional third output argument.


====================================================================================
Description
====================================================================================

Canonical methods (specific methods indicated by *):
--------------------------------------------------------------

<class constructor>		[Required] (specific, method)
	Call checkfields as the ultimate arbiter of the validity of the 
	contents of an object.

display
  * display_single      [Required] (specific, private method)

get

set
  * fieldnames_comments [Optional] (specific, private method)	

isvalid
  * checkfields         [Required] (specific, private method)

    Must have first input and first three output arguments with format:

          [ok,message,w_out...]=checkfields(w_in,...)

       where w_in can be a structure or object of the class.
       w_out can be an altered version of the input structure or object that must
       have the same fields. For example, if a column array is provided for a field
       value, but one wants the array to be a row, then checkfields could take the
       transpose. If the facility is not wanted, simply include the line w_out=w_in.

    Because checkfields must be in the folder defining the class, it
    can change fields of an object without calling set.m, which means
    that we do not get recursion from the call that set.m makes to 
    isvalid.m and the consequent call to checkfields.m ...
      
    Can have further arguments as desired for a particular class

struct

subsasgn

subsref


Notes:
-------
The function checkfields may be called directly by the constructor.

isvalid will only take an object, so cannot be called by the constructor. However,
we want to make sure that the isvalid method performs exactly the same checks.


