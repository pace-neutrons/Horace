

# 2. Generic projection design ideas

Date: 2019-12-10

## Status

Draft

## User interaction and current design.

 Current sqw objects contain 4D images expressed, roughly speaking, in an hkl-dE coordinate system.
 hkl vectors can be non-orthogonal, but the sqw object implementation for non-orthogonal coordinate system is not
 obvious. 
 
 The initial coordinate system of the sqw object is implicitly defined during [gen_sqw](http://horace.isis.rl.ac.uk/Generating_SQW_files)
 operation. The `gen_sqw` contains `alatt, angdeg,u, v, psi, omega, dpsi, gl, gs` block
 describing the crystal lattice parameters and the goniometer position, implicitly defining hkl coordinate system 

 > *is the image system non-orthogonal if lattice is non-orthogonal (answer in the code, but not in the docs)?

 > *how this non-orthogonal system is displayed (e.g. if one rebins 2 spare dimensions)?
 
 After `gen_sqw` operation completed, two closely related coordinate systems are actually built within a sqw object:
 hkl-dE system of the image and Crystal Cartesian coordinate system of the object's pixels. The numbers of 
 pixels contributed into cells of hkl-dE image is used implicitly as key to access data from the object's pixels array. 
 
 Different image's coordinate system is produced by [CutSQW operation](http://horace.isis.rl.ac.uk/Manipulating_and_extracting_data_from_SQW_files_and_objects)
 where `proj` structure contains two vectors and optionally other parameters,
 describing a coordinate system, rotated and shifted w.r.t. the original hkl-dE coordinate system.

 There are samples of other coordinate system usages (e.g. [gen_sqw_cylinder_test](https://github.com/pace-neutrons/Horace/blob/master/horace_core/gen_sqw_cylinder_test.m) 
 and [gen_sqw_powder_test](https://github.com/pace-neutrons/Horace/blob/master/horace_core/gen_sqw_powder_test.m))
 but they are not suitable for a user who is not looking in the details of the code implementation. 
 
 User need to be able to define and use sqw object, containing image expressed in other types of standard coordinate
 system, e.g. cylindrical or spherical system. User should be able to easily define such coordinate system and make
 sub-objects (cuts) of given sqw object in any other available coordinate system.
 
 The interface for this operation should be the same as for `CutSQW` operation, but the `proj` should define the axis of 
 the alternative coordinate system and its location v.r.t. the initial SQW object coordinate system. 
 
 > *what about initial sqw object? Can (should) we produce it in other coordinate system?
 
 A DnD object (n-number of actual dimensions e.g. D1D or D3D) is used to encapsulate hkl-dE image or its various 
 projections (cuts). Number of properties e.g. `p, iax, pax,` used to describe the actual geometry of a the image.
 The actual relation between this geometry and the geometry of the pixels array is, again, defined implicitly
 within the algorithm, which runs the transformation (`cutSQW`).

## Design requests.

 - We need to separate sqw object into smaller objects with well defined features, that can be unit tested and easy 
   understandable by developers.
 - We should try to encapsulate expensive operations within sub-classes not to transfer substantial data over
   classes interface, to avoid substantial performance overheads.
 

## Redesign plan.
To satisfy the user request and achieve the design goals we should:

1.Extract geometry properties into separate class (e.g. `axis_block`) and make the geometry explicit.
  Look through `cut`-type of algorithms and plotting routines to identify the operations, performed 
  on the sqw-object "geometry"-type of properties.
  
2.Modify plot functions to work using the "geometry" interface.

3.Modify `cut`-type algorithms to work through interface to this properties.

4.Make the transformation from one geometry to another geometry explicit. Encapsulate this transformation 
   within a projection class and rewrite `cut`-type of algorithms in the terms of this interface.
   Given current understanding of the code operations, a new projection should provide the methods:
   - `get_contributing_bins` which would work on old projections and return pixels, which may 
      contribute into new projection ranges.
   - `get_geometry`/`get_transformation` - the method to return new geometry of a projection w.r.t. the pixels geometry.
   - `bin_pixels` which would work on the pixels and arrange them according to the grid, defined by the new
      geometry
      
   The pixel block, in turn, should be able to provide:
   - `get_pix_for_bins` method, returning pixels for the bins, provided by `get_contributing_bins` method.

All subclasses and interfaces defined this way should be unit-testable.
