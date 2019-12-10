

# 2. Generic projection design ideas

Date: 2019-12-10

## Status

Draft

## User requests and current design.

 Current sqw objects contain 4D images expressed, roughly speaking, in an hkl-dE coordinate system.
 hkl vectors can be non-orthogonal, but the sqw object implementation for non-orthogonal coordinate system is not
 obvious. 
 
 The initial coordinate system of the sqw object is implicitly defined during [gen_sqw](http://horace.isis.rl.ac.uk/Generating_SQW_files)
 operation. The `gen_sqw` contains `alatt, angdeg,u, v, psi, omega, dpsi, gl, gs` block
 describing the crystal lattice parameters and the goniometer position, implicitly defining hkl coordinate system 

 > *is the image system non-orthogonal if lattice is non-orthogonal (answer in the code, but not in the docs)?

 > *how this non-orthogonal system is displayed (e.g. if one rebins 2 spare dimensions)?
 
 Another coordinate system is currently defined by [CutSQW operation](http://horace.isis.rl.ac.uk/Manipulating_and_extracting_data_from_SQW_files_and_objects)
 where `proj` contains two vectors, describing a coordinate system, rotated and shifted w.r.t. the original coordinate system.

 There are samples of other coordinate system usages (e.g. [gen_sqw_cylinder_test](https://github.com/pace-neutrons/Horace/blob/master/horace_core/gen_sqw_cylinder_test.m) 
 and [gen_sqw_powder_test](https://github.com/pace-neutrons/Horace/blob/master/horace_core/gen_sqw_powder_test.m))
 but they are not suitable for a user who is not looking in the details of the code implementation. 
 
 User need to be able to define and use sqw object, containing image expressed in other types of standard coordinate
 system, e.g. cylindrical or spherical system. User should be able to easily define such coordinate system and make
 sub-objects (cuts) of given sqw object in any other available coordinate system.
 
 The interface for this operation should be the same as for `CutSQW` operation, but the `proj` should define the axis of 
 the alternative coordinate system and its location v.r.t. the initial SQW object coordinate system. 
 
 > *what about initial sqw object? Can (should) we produce it in other coordinate system.

## Design requests.

 - We need to separate sqw object into smaller objects with well defined features, that can be unit tested and easy 
   understandable by developers.
 - We should try to encapsulate expensive operations within sub-classes not to transfer substantial data over
   classes interface, to avoid substantial performance overheads.
 

## Decision

