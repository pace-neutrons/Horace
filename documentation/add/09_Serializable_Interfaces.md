# Serialiable interfaces
Date: 2022-06-01

## Objectives and problems to resolve.
Current Horace SQW objects use its native proprietary (though an open source) binary file format to store Horace `sqw` objects and allow fast access to these objects. The problem is in accessing pixel information in fact the data, containing all data records from a weeks long inelastic scattering neutrons experiments. The main reason for introducing such format is that these data can not fit to memory of common computers (average size of the files would be *~50Gb* but *500Gb* files are not so uncommon), so we need to keep these data on a disk and provide efficient ways of accessing and processing them.

In addition to that, users often work with parts of the whole experiment data, containing the areas of the interests for the user. These data can often, though not always, fit into memory and users want to store their areas of interest for further usage. The data in memory are presented as Matlab `sqw` objects so users often use Matlab proprietary file format, which allows efficient binary store/restore operations for a Matlab classes.

To satisfy users requests, we in fact support two independent binary file formats. Each format is best suited for subset of user needs.

The fact that the data are binary and proprietary causes some problems for users. To access native Horace file format, users need deep understanding of Horace, as the binary objects are reflection of sqw objects in memory and these objects have complex structure necessary for storing complex experimental data. Users who want to utilize smaller `sqw` objects stored in `.mat` files should also use Horace as restoring Matlab classes relies on Matlab knowing the definition of these classes.

1. To satisfy the request of accessing Horace data from third party applications, team have decided to change Horace file format from raw binary, to [HDF](https://www.hdfgroup.org/) file format, as this format is the industry standard for efficient storage and access to binary scientific data, accessible by number of third party applications unrelated to Matlab and Horace. The decision on making `.hdf` data [NeXus](https://www.nexusformat.org/) compatible is still pending (NeXus is an HDF-based standard format for storing the results of neutron scattering experiments).

2. Current binary file format is relatively complex and related to current structure of `sqw` classes. To satisfy the project requests we are bringing substantial changes to `sqw` objects so the file format to store these objects should also change. To maintain consistent user experience we need to support the way of reading various previous versions of the `sqw` binary files and `sqw` objects, stored in proprietary `.mat` files.

3. Additional problem to resolve is the maintenance of two independent file formats. Any changes to `sqw` objects would request changes in two independent file writers which requests additional developers efforts. It would be beneficial to avoid efforts duplication and maintain only one file format both for large (partially fitting to memory) and small (fully fitting to memory) `sqw` objects, written to disk.

## Suggested solution -- serializable interface.
To resolve issues 1-3 mentioned in the previous chapter, team decided to rely on the Matlab's standard mechanism of storing/restoring customized objects. If a Matlab object defines `saveobj/loadobj` methods, Matlab uses these methods to convert to/from binary format to convert a Matlab object into a structure or recover the object from the structure. The structure then is saved/loaded using Matlab proprietary file format. The responsibility of maintaining this format is then lies with Matlab. 

To utilize the `saveobj/loadobj` Matlab behaviour we have decided to make all Horace objects `serializable`. The custom `serializable` class defines `saveobj/loadobj` pair of methods and some additional methods, necessary to maintain class versioning (see below). 
To implement our *serializable* interface we have to make two assumptions about our objects:
1. The objects have an empty constructor. 
2. An object has a public interface which allows to define non-empty object with any contents the object may have.

If such assumpitins are satisfied, we may define *serializable* objects, which need to define only handful of class-specific methods, but would immediately number of very useful generic features. The class diagram describing such object is presented on the **Fig 1**:

<center>![Serialiable. Main Interface](../diagrams/serializable_main_interface.png)</center>

**Fig 1:** Main interface and methods of **Serializable** class.















 
