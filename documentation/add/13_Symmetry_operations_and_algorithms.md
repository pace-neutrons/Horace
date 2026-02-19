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
separately) and returns set of transformations, provided by the library for given lattice given
symmetry type of this lattice.

To apply symmetry transformation to `sqw` object, one need to identify symmetry-equivalent image areas
and apply transformations, which will move all symmetry related pixels from all areas into single (main) 
symmetry area. Horace allows to do this in two different ways: 1) Symmetrise whole `sqw` object using `symmetrise_sqw` algorithm and 2) Take `sqw` object and make `cut` with symmetry operations, 
which would pick up set of zones, symmetry related to the original one and apply symmetry operations to pixels, contributing into symmetry related zones to move them to the original one.

At the moment `symmetrise_sqw` works with `SymopRotation` and `SymopReflection` transformations
only, while `cut` would work with any transformation.

The core of both algorithms is set of `Symop` operations. The inheritance diagram for all symmetry operations classes used by Horace is presented on Fig.1.

![Fig.1. Symop Classes Inheritance diagram with two algorithms which use `Symop`](../diagrams/Symops_diagram.png)


#symmetrise_sqw

The algorithm is based on the concept of **irreducible zone**, defined for `SymopRotation` and `SymopReflection` only. For `SymopReflection` irreducible zone is the half-plane constrained by the reflection plane in the direction of the normal to this plane. For `SymopRotation` its the corner between two planes located at the rotation centre defined by `offset`. The angle *&theta;* between planes is equal to the rotation angle `theta_deg` defined for `symop_rotation`. Fig.2 provides example of irreducible zones for `SymopReflection` with `u=[1,0,0]`, `v=[0,1,0]` and `offset` [2,0,0] and `SymopRotation` with `offset` [1,1,0] constructed in cubic orthogonal coordinate system expressed in `rlu`.

![Fig.2. Irreducible zones for a) `SymopReflection` and b) `SymopRotation` ](../diagrams/Symops_irreducible.png)



