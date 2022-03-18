# Design for a container for compressed (unique instances of) instruments, samples or detectors within the experiment_info object in an SQW object

### Background

SQW objects store instrument, sample and detector instances for use with
Tobyfit. Previously the instruments and samples were stored one per run in the
header structure, while detector information was stored as a single struct in
`detpar`.

For large numbers of multiple runs, if the instrument or sample was the same for
all runs, the information would be duplicated may times within the SQW. When
reduced-size copies of the SQW are made, e.g. as cuts, this duplication would
increase.

By contrast, the `detpar` information is a singleton within the SQW. It may be
duplicated by making cuts, which would be undesirable - Toby has identified
detector as the largest of our three categories and the one most needing removal
of duplicates. At the same time, there are rare occasions when at least two
detectors are used, one with some runs, one with the rest; this possibility is
not catered for in the previous SQW structure.

A start has been made on this by restructuring the header and detpar information
into a single `experiment_info` object of class `Experiment`. The instruments
are collected in one container, currently a cell array, as are samples, in a
separate cell array. Both of these are currently one item per run,
i.e. uncompressed. Detector information is stored in the container detector
arrays, which is an array of `IX_detector_array` objects.

This document will confine itself to instruments from this point, but the issue
is general across all three categories.

To enable the instrument information to be compressed easily, we have decided to
replace the instrument cell array with a container class designed by us in which
the objects can easily be compressed.

### Container design

The current container for instruments is a cell array. Alternatives previously
used and considered were `mixin.Heterogeneous` arrays. These allowed arrays to be
used with the multiplicity of possible instrument sub-classes such as
`IX_inst_DGfermi` and `IX_inst_DGdisk`. These stopped being used as they were
apparently not working with serializable. Neither of these alternatives
encapsulates the instrument collection such that the container's own methods can
compress and index its contents.

The new container needs to have 2 sets of properties:

1. it must be able to add and remove elements such that addition will not add a
duplicate of an instrument already in the container, and to index the
unduplicated contents such that the correct instrument will be returned for a
given run.

2. it must be able to store heterogeneous objects such as `IX_inst_DGfermi` and
`IX_inst_DGdisk` such that scans for duplicates are made only on objects of the
same subclass.

To meet the second condition, it is proposed that the container will internally
have a struct with one element for each subclass type of instruments. That is, a
struct of the form:

```matlab
contents = struct();
contents.IX_inst_DGfermi = IX_inst_DGfermi.empty;
contents.IX_inst_DGdisk = IX_inst_DGdisk.empty;
```

The `classname` method can then be applied to the incoming object to determine
which array, and hence which field of `contents`should be used to store it.

Alternatively, a `container.Map` could be used in place of the struct. It is
suggested that the serializability of `contents` is the important criterion for
this choice, and that serializing struct will be more beneficial for code use
than `container.Map` but that is a matter for discussion.
