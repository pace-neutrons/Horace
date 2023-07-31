Singleton implementation in a unique_references_container

The unique_references_container class in ...\herbert_core\utilities\classes\@unique_references_container\unique_references_container.m
provides a container where
- the container mimics a cell array of objects for subscripting
- only the unique objects are stored; there are no duplicates, reducing memory footprint
- an index array idx(i) relates the stored object in position i to the relevant stored unique object.

In this it mimics the unique_objects_container ...herbert_core\utilities\classes\@unique_objects_container\unique_objects_container.m

Additionally, the pool of unique objects is shared between multiple containers in a singleton container (a unique_objects_container)
so that when a modified duplicate of the container is made (such an an SQW cut) the singleton is shared between original and modified
duplicate so that no extra storage for the "duplicated" objects is needed.

The implementation of the singleton follows the standard pattern for Matlab described in
https://uk.mathworks.com/matlabcentral/fileexchange/24911-design-pattern-singleton-creational
This singleton implementation works for a singleton class with one only class and one only instance.
 
However, in the case of unique_references_container, what we need is
- Multiple containers (e.g. for instruments or detectors), each templated by their contained data type
- For each data type, a singleton container containing the compressed data
- Methods of accessing the singletons as if they were ordinary cell arrays, separately for each container.
 
The unique_references_container combines all of these. 
For a container of a given type e.g IX_inst
the container has a singleton instance of unique_objects_container for that type (as well as singleton instances for other types.)
 
The singleton is accessed via the static method `global_container(...)` (corresponds to above design pattern method `instance()`).
Singleton instances of all types are stored in a struct which is the persistent variable `glcontainer`, 
corresponding to `uniqueInstance` in the above example.
For type `IX_inst` the singleton’s name is `GLOBAL_NAME_INSTRUMENTS_CONTAINER`.
The singleton is stored in the struct as the field `glcontainer.GLOBAL_NAME_INSTRUMENTS_CONTAINER`.
Other types will have other struct fields.
The name is not the same as `IX_inst` to allow other singleton containers for `IX_inst` if that is required.
 
The singleton global container is created using 
```
glc = global_container(‘init’, GLOBAL_NAME_INSTRUMENTS_CONTAINER,’IX_inst’)
```
which returns the new singleton. This corresponds to instance() for the case where the singleton is not yet instantiated.
 
The singleton global container is accessed using 
```
glc = global_container(‘value’, GLOBAL_NAME_INSTRUMENTS_CONTAINER)
```
 which returns the singleton. This corresponds to `instance()` in the case where the singleton has been instantiated. 
 As the singleton is now exposed within the container and has its methods for getting and setting the data as a `unique_objects_container`, 
 a `getSingletonData()` method is not separately required.
 
If the singleton global container has been modified by the internal methods of `unique_references_container`, 
then the modified value `glc` of the singleton is returned to the struct using 
`global_container(‘reset’, GLOBAL_NAME_INSTRUMENTS_CONTAINER,glc)` where `glc` was modified after one of the two previous calls. 
As `glc` is already available at the calling point, it is not returned by this call. 
This corresponds to `setSingletonData()` and an update of `uniqueInstance`, since here the singleton is not a handle class.
 
Additional code within the `global_container()` method deals with  the need to maintain the struct for multiple data types.
 
The singletons are only used within the `unique_references_container` and are not exposed to its users. 
The non-static methods of `unique_references_container` have the same functionality as `unique_objects_container`, 
e.g, add, replace, subsref, subsasgn etc. except that they store the data in the singletons rather than cellarrays. 
They track the indices in the singleton for each non-unique object stored in the outer `unique_references_container`.
 
