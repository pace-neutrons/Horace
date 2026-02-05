#Symmetry operations in Horace
Date: 2026-02-05


#Overview of operations

Horace allows to define various symmetry operations and apply them to `sqw` objects. 
If done correctly, with proper account for symmetry of the system, symmetry operations
improve statistics and substantially simplify the data analysis as scientist concentrates
on physically significant areas of dataset.


The symmetry operations in Horace are defined by `Symop` family of classes, which 
define simple, i.e. reflection (`SymopReflection`) and rotation (`SymopRotation`) transformations
and also partial support for generic symmetry transformations, 
defined by special unary transformation matrix `SymopGeneral`.

All Crystal lattice related symmetry transformations may be described by specially 
constructed 3x3 transformation matrices, available on the web. Horace accesses
these transformations by accessing Python library available at https://github.com/spglib/spglib
using `get_syms` utility which interfaces this library (has to be installed for MATLAB's Python
separately) and returns set of transformations, provided by the library for given lattice.

To apply symmetry transformation to `sqw` object, one need to identify symmetry-equivalent image areas
and apply transformations, which will move all symmetry related pixels from all areas into single (main) 
symmetry area. Horace allows to do this in two 



