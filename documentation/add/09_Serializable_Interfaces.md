# Serialiable interfaces
Date: 2022-06-01

## Objectives:
Current Horace SQW objects use its native proprietary (though open source) binary file format to store sqw objects and allow fast access to these objects. The problem is in accessing pixel information in fact the data, containing all data records from a weeks long inelastic scattering neutrons experiments. The main reason for introducing such format is that these data can not fit to memory of common computers (average size of the files would be ~50Gb but 500Gb files are not so uncommon), so we need to keep these data on a disk and provide efficient ways of accessing and processing them. 

In addition to that, users often work with parts of the whole experiment data, containing the areas of the interests for the user. These data can often, though not always, fit into memory and users want to store their areas of interest for further usage. The data in memory are presented as Matlab `sqw` objects so users often use Matlab proprietary file format, which allows efficient binary store/restore operations for a Matlab classes.

To satisfy users requests, we in fact support two independent binary file formats. Each format is best suited for subset of user needs. 

The fact that the data are binary and proprietary creates some problems for users. To access native Horace file format, users need deep understanding of Horace, as the binary objects are reflection of sqw objects in memory and these objects have complex structure necessary for storing complex experimental data. The 
