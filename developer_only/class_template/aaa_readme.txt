Generic methods for any class
=============================

Canonical methods (Required specific methods in brackets):
--------------------------------------------------------------

display
  * display_single (specific, private method)

get

set
  * fieldnames_comments (optional) (specific, private method)	

isvalid
  * checkfields (specific, private function)
    Must have first input and first two output arguments with format:
          [ok,message,...]=checkfields(struct_in,...)
    Can have further arguments as desired for a particular class

struct

subsasgn

subsref


Optional specific, private function:
------------------------------------
classname  (just returns name of class)

(This function is needed for operator arithmetic)



Note:
-------
The function checkfields may be called by the constructor.

isvalid will only take an object, so cannot be called by the constructor. However,
we want to make sure that the isvalid method performs exactly the same checks.


