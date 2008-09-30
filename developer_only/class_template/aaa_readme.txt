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

struct

subsasgn

subsref


Optional specific, private function:
------------------------------------
classname  (just returns name of class)


Note:
-------
The function checkfields may be called by the constructor.

isvalid will only take an object, so cannot be called by the constructor. However,
we want to make sure that the isvalid method performs exactly the same checks.


