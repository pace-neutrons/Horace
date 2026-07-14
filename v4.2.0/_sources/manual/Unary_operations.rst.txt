################
Unary operations
################

A unary operation is one that is performed on a single object, with no additional inputs. A single object is returned.

unary plus
==========

Unary plus. Returns the input object ``win`` with no modification.

::

   wout = +win


Equivalent to ``wout = uplus(win)``

unary minus
===========

Unary minus. Returns the intensity field of the input object multiplied by -1, i.e. ``wout = -1  win``.

::

   wout = -win


Equivalent to ``wout = uminus(win)``


Trigonometric and hyperbolic functions
======================================

With the form

::

   wout = function(win)


where ``function`` is any of the following, trigonometric or hyperbolic operations may be performed on dnd or sqw objects.

- ``acos`` - arc cosine
- ``acosh`` - arc cosh
- ``acot`` - arc cot
- ``acoth`` - arc coth
- ``acsc`` - arc cosec
- ``acsch`` - arc cosech
- ``asec`` - arc sec
- ``asech`` - arc sech
- ``asin`` - arc sine
- ``asinh`` - arc sinh
- ``atan`` - arc tangent
- ``atanh`` - arc tanh
- ``cos`` - cosine
- ``cosh`` - cosh
- ``cot`` - cot
- ``coth`` - coth
- ``csc`` - cosec
- ``csch`` - cosech
- ``sec`` - sec
- ``sech`` - sech
- ``sin`` - sine
- ``sinh`` - sinh
- ``tan`` - tangent
- ``tanh`` - tanh


Other mathematical functions
============================

Using the same syntax as above, one can perform the following operations:

- ``exp`` - exponential
- ``log`` - natural logarithm
- ``log10`` - logarithm base 10
