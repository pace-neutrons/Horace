# Design for a container for compressed (unique instances of) instruments, samples or detectors within the experiment_info object in an SQW object

## Background

### Need to remove duplicate objects

SQW objects store instrument, sample and 
detector instances for use with Tobyfit. 
Previously the instruments and samples were 
stored one per run in the header structure, 
while detector information was stored as 
a single struct in detpar. 

For large numbers of multiple runs, if 
the instrument or sample was the same for all runs, 
the information would be duplicated many times 
within the SQW. When reduced-size copies 
- cuts - of the SQW are made, this 
duplication would increase.

By contrast, the detpar information was previously a 
singleton within the SQW. It will also be duplicated 
by making cuts, which would be undesirable - 
Toby has identified detector as the largest 
of our three categories and the one most 
needing removal of duplicates. 

Additionally, 
there are rare occasions when at least two detectors 
are used, one with some runs, one with the rest; 
this possibility was not catered for in the previous 
SQW structure. A start has been made on allowing multiple detectors 
in an SQW object by restructuring the detpar information into a 
single `experiment_info` object of class `Experiment`. Detector information 
is stored in `experiment_info` inthe array `detector_arrays`, 
which is an array of `IX_detector_array` objects. These 
are also now one per run.

The instruments now are collected in the same way in one container, 
currently a cell array, as are samples, in a separate 
cell array. All three of these containers currently have one 
item per run, so that there is no compression, i.e. removal of
duplicate objects, in `experiment_info`.


### Strategy to remove duplicates

To perform this duplicate removal, either these existing (cell-)arrays
need to be reconfigured to contain indices to non-duplicate objects
in separate containers, or alternatively to replace these arrays with
specialised containers which will allow both functions to be performed.

This document focuses on the design of the specialist container which 
holds the unduplicated objects. The strategy for referencing from the
single original object to its duplicates has been discussed elsewhere.
In outline, the possibilities are 
(a) to convert all duplicated object classes to handle classes, or
(b) to rely on the copy-on-write (CoW) mechanism to prevent objects being
duplicated when apparently copied - the object "copies" will not 
actually become separate instances until one of them is changed.
Currently handle classes are not used extensively in Horace and 
option (b) may be sufficient, so it is the current candidate.

However, it is important to note that there are two cases where
copying of actual instances must be prevented. One is
(a) when objects are copied from one SQW object to another. Handle
classes are trivially not duplicated here, and  CoW objects are effectively
not duplicated here. However if a container compresses the object into a
different format, as shown in the implementation described below, this
handle or CoW link may be lost. 

The other case is (b) when SQW objects
are written to file. In this case, the objects must be stored separately
from the SQW objects written to file. This is because there is no
connection between an SQW and its cuts once the cut has been made,
and any handle or CoW relationships between SQW component objects 
is lost when the SQW objects are written to file. Consequently, when 
the objects are restored from file, they must be written to a central
location where duplicates can be removed.

It is proposed that this location be static data in the component object
classes. As Matlab does not directly support static data, this will be
indirectly implemented; the implementation is discussed in more detail
below.

This document will confine itself to instruments from 
this point on, but the issue is general 
across all three categories. 

To enable the instrument information to be compressed 
easily, we have decided to replace the 
instrument cell array with a container class designed 
by us in which the objects can easily be compressed.

### Use cases

#### Adding and retrieving an object to and from the container

When data for a new SQW object collected as, say, a set of `nxspe` files,
each file will describe its own instrument, sample and detector. When these
are used by `gen_sqw` to construct an SQW object, each will be added to 
the relevant container (instrument, sample or detector) after construction
into the relevant component object, and the container
will either store the object or find its duplicate already in the container.
In either case it will provide an index for the item added. Indices of
non-duplicate objects in the container will remain internal and not 
exposed by the interface. Thus for N runs, the e.g. instrument container 
will appear externally to contain N instruments as before, indexed by run 
number. However internally the container will find the relevant 
non-duplicate instrument and return that.

#### Copying instruments to cuts

When a cut is created, the `experiment_info` object is duplicated in
the new cut SQW. In principle, this duplicates the instruments. If the
instruments are either handles or CoW classes, in practice these 
mechanisms prevent an actual copy from being made.

If the original SQW and cut SQW are written to file as mentioned above
this connection will be broken. Consequently when the file-stored
SQW objects are read back into memory, the objects should be read
back into a common area to remove duplicates and restore the relationship.

#### Different instruments in different runs

The example proposed in comments on Horace PR-790 is the case where 
two Fermi chopper instruments are combined e.g. in MAPS and MARI runs.
It is presumed that this change cannot occur within a run; each run
will have a single instrument with appropriate chopper. The `experiment_info`
object's instrument container will contain a separate instrument for each
run. As MAPS and MARI have different instruments, these will be applied to
the appropriate runs in `experiment_info` and as they are not identical,
they will just be stored separately without duplicate removal.

#### Different detectors

The example proposed in comments on Horace PR-790 is the case where we 
combine runs obtained on the same instrument, e.g. old LET and new LET,
where the detector converage has changed. In the new `experiment_info` 
object, we can now have separate detectors for different runs, so that 
runs on the old LET will have the old detector information in `detector_arrays`
while runs on the new LET will have the new detector information.
## Container design

### Current storage method

The current container for instruments is a cell array. 
Alternatives previously used and considered were 
mixin.Heterogeneous arrays. These allowed arrays to be 
used with the multiplicity of possible instrument 
sub-classes such as IX_inst_DGfermi and IX_inst_DGdisk. 
These stopped being used as they were apparently not 
working with serializable. Neither of these alternatives 
encapsulates the instrument collection such that the 
container's own methods can compress and index its contents.

### Design criteria

The new container needs to have 2 sets of properties:

1. it must be able to add and remove elements such that 
addition will not add a duplicate of an instrument already 
in the container, and to index the unduplicated contents 
such that the correct instrument will be returned for a given run.
2. it must be able to store heterogeneous objects such as 
IX_inst_DGfermi and IX_inst_DGdisk such that scans for 
duplicates are made only on objects of the same subclass.

### New design

This design is based on Duc's design given in Horace PR-790.

#### Basic design

The container will store unique objects in a cell array `stored_objects`, to
allow for the storage of heterogenous types or sub-types.
Optionally the container will also specify a base class
such that only sub-class objects of this base class can be
stored. If this is not given then the container may store objects
of any type. The base class if any is specified on construction
and may not be changed thereafter.

New objects are added to the container using the `add` method.
Each such object is given an index based on the number of additions
which have already taken place; the n-th addition will yield an 
object with index n, which may be retrieved using the `get(n)` method.
It is not possible to remove objects - it is assumed all are relevant
to the the relevant SQW object.

Internally, the container checks whether a duplicate of this object
is already present in the container. The internal index for this 
duplicate, if it exists, is stored in an array `idx` for each object added.
`idx(n)` is the index of the duplicate in the cell array. If there is 
no duplicate, then the added object is stored for the first time.

#### Checking for duplicates

The container hashes the objects using a `java.security.MessageDigest` 
instance of type `MD5`. This is given a stream conversion of the object
and uses the `MessageDigest`'s digest method to create a hash which is 
a vector of type `uint8`. This vector is stored separately in an array
`stored_hashes` at the same position as the object is in `stored_objects`.
Object comparison is made by comparing the hash vectors of the two objects
to be compared.

The default function for stream conversion is currently the undocumented
function `getByteStreamFromArray`. As this may be retired by Matlab at an
unpredictable future date, the container constructor allows the user to
specify an alternative. The Herbert serializable function `hlp_serialise`
can perform this function.

If the container class is refactored to allow the whole hashing functionality
to be extracted as a separate class, then alternatively the currently
available `object_lookup` function could also be used to detect duplicates.


### Previous designs

One previous design has been documented.

#### Design #1

To meet the second design criterion, it was proposed that the 
container will internally have a struct with one element for 
each subclass type of instruments. That is, a struct of the form:

'''
contents = struct();
contents.IX_inst_DGfermi = IX_inst_DGfermi.empty;
contents.IX_inst_DGdisk = IX_inst_DGdisk.empty
```

The `classname`method can then be applied to the incoming object to 
determine which array, and hence which field of `contents`should be 
used to store it.

Alternatively, a `container.Map` could be used in place of the struct. 
It is suggested that the serializability of `contents`is the important 
criterion for this choice, and that serializing struct will be more 
beneficial for code use than `container.Map` but that is a matter for discussion
and testing.

In this design the `object_lookup` method was to be used to detect duplicates.


