# The serialiser

In order to efficiently transfer MATLAB information between storage, be it via networked interaction (such as MPI) or to disc efficiently, the information is first "serialised" into a representation. This document details the operation of the serialisers defined in:
```
<HERBERT_ROOT>/herbert_core/utilities/misc/hlp_serialise
<HERBERT_ROOT>/herbert_core/utilities/misc/hlp_deserialise
<HERBERT_ROOT>/_LowLevelCode/cpp/cpp_communicator/serialiser/c_serialise
<HERBERT_ROOT>/_LowLevelCode/cpp/cpp_communicator/serialiser/c_deserialise
```

The serialised format has recently been updated to be more consistent and to have greater capabilities such as serialising arrays of structs/objects.

# New format

## Standard header format

The new style has a standardised header format depending on the shape of the data (with the exception of function handles).
This format allows extension to support arrays of objects and structs in a way which the old serialiser couldn't.
It also greatly simplifies the tag structure and allows it to align with the C++ MEX API data types.
Data in these cases is serialised in the linearised order as defined by `data(:)` and the array reshaped by the deserialiser.

This standard format for the header is as follows:
_Rank_ |     tag    | dim1 | dim2 | ...
-------|------------|------|------|-----
_NULL_ | 32 + type  | 0    |      |
_0_    |    type    |      |      |
_1_    | 32 + type  | nElem|      |
_2_    | 64 + type  | dim1 | dim2 |
_N_    | N<<5 + type| dim1 | dim2 | ...

__NB.__ Rank is not part of the data header, and instead is a label representing the array rank of the data to be (de)serialised. NULL is empty as in the empty string (i.e. `''`), which is not rank-0 (scalar) because it possesses no elements. In the serialised format, it is represented as a zero-length list.

Where `<<5` means bitshift left 5. (see [Tag Format][tag])
- This will be followed by the data serialised in a relevant form.
- There is no footer required as the header contains all relevant information as to the size of the serialised object.
- Tags are `uint8` data and the "magic" numbers are described in detail in the section [Tag Format][tag] below.
- Dimensions are serialised as `uint32`

The single exception to this header is that of `function_handles` which are purely scalar and the rank component of the tag is used to specify the type of function handle:

Handle type         |   tag   | value
--------------------|---------|-------
Simple/Class simple | 32 + 25 | 57
Anonymous           | 64 + 25 | 89
Scoped              | 96 + 25 | 121

## Tag format

### Tag Structure

The tag in the new format is a 1-byte (`uint8`) tag where the top 3 bits give the rank of the data, the bottom 5 give the type-tag of the data

| 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1 |
|:---:|:--:|:--:|:--:|:-:|:-:|:-:|:-:|
|  R  | R  | R  | T  | T | T | T | T |

- R - Rank
- T - Type

### Type Tags
Tag| Meaning
---|----------------------
  0| LOGICAL
  1| CHAR
  2| MATLAB_STRING
  3| DOUBLE
  4| SINGLE
  5| INT8
  6| UINT8
  7| INT16
  8| UINT16
  9| INT32
 10| UINT32
 11| INT64
 12| UINT64
 13| COMPLEX_DOUBLE
 14| COMPLEX_SINGLE
 15| COMPLEX_INT8
 16| COMPLEX_UINT8
 17| COMPLEX_INT16
 18| COMPLEX_UINT16
 19| COMPLEX_INT32
 20| COMPLEX_UINT32
 21| COMPLEX_INT64
 22| COMPLEX_UINT64
 23| CELL
 24| STRUCT
 25| FUNCTION_HANDLE
 26| VALUE_OBJECT
 27| HANDLE_OBJECT_REF
 28| ENUM
 29| SPARSE_LOGICAL
 30| SPARSE_DOUBLE
 31| SPARSE_COMPLEX_DOUBLE

### Serialisation formats in detail

#### Simple data
Simple data (type tags 0-12) are serialised as:

_Rank_ |     tag    | dim1 | dim2 | ... | Data
-------|------------|------|------|:---:|------
_NULL_ | 32 + type  | 0
_0_    |    type    |      |      |     | Data
_1_    | 32 + type  | nElem|      |     | Data
_2_    | 64 + type  | dim1 | dim2 |     | Data
_N_    | N<<5 + type| dim1 | dim2 | ... | Data

#### Complex Data
Complex numerical data (type tags 13-22) are serialised as:

_Rank_ |     tag    | dim1 | dim2 | ... |    Data   |   ...
-------|------------|------|------|:---:|-----------|----------
_NULL_ | 32 + type  | 0    |      |     |           |
_0_    |    type    |      |      |     | Real Data | Imag Data
_1_    | 32 + type  | nElem|      |     | Real Data | Imag Data
_2_    | 64 + type  | dim1 | dim2 |     | Real Data | Imag Data
_N_    | N<<5 + type| dim1 | dim2 | ... | Real Data | Imag Data

#### Sparse data
Sparse numeric data (type tags 29-31) are serialised as:

_Rank_ |   Type  |     tag  | dim1 | dim2 | Data | ... |    ...    | ...
-------|---------|----------|------|------|:----:|:---:|-----------|------
_2_    | Real    | 64 + type| dim1 | dim2 |   i  |  j  | Data      |
_2_    | Bool    | 64 + type| dim1 | dim2 |   i  |  j  | Data      |
_2_    | Complex | 64 + type| dim1 | dim2 |   i  |  j  | Real Data | Imag Data

Based on `sparse(i,j,data)` [MATLAB documentation][sparse]

__NB.__ only rank-2 sparse arrays are permitted in MATLAB

__NB.__ Due to storing dimensions as `uint32` data, rather than `double`, sizes of sparse arrays are limited to (2^32)-1

#### Struct data
Structured tree data (type tag 24) uses the standard header format:

_Rank_ |     tag    | dim1 | dim2 | ... | Data
-------|------------|------|------|:---:|------
_NULL_ | 32 + type  | 0
_0_    |    type    |      |      |     | Data
_1_    | 32 + type  | nElem|      |     | Data
_2_    | 64 + type  | dim1 | dim2 |     | Data
_N_    | N<<5 + type| dim1 | dim2 | ... | Data


Where data is formatted as follows:

nFields | length(fieldName1) | length(fieldName2) | ... | fieldName1 | fieldName2 | ... | struct2cell(data)
--------|--------------------|--------------------|:---:|------------|------------|:---:|------------------

nFields and fieldName lengths are serialised as `uint32`

__NB.__ For struct arrays `struct2cell` produces a Rank-(N+1) cell array, this means that for struct arrays, the limit on rank is 6.

#### Cell array
Cell array data (type tag 23) are serialised as:

_Rank_ |     tag    | dim1 | dim2 | ... | Data
-------|------------|------|------|:---:|------
_NULL_ | 32 + type  | 0
_0_    |   type     |      |      |     | Data
_1_    | 32 + type  | nElem|      |     | Data
_2_    | 64 + type  | dim1 | dim2 |     | Data
_N_    | N<<5 + type| dim1 | dim2 | ... | Data

Where `data` is the concatenation of the serialisation of each element.

#### Object Array
Object array data (type tag 26) are serialised as:

_Rank_ |     tag    | dim1 | dim2 | ... |Data|     ...            |    ...     |   ...   |  ...
-------|------------|------|------|:---:|----|--------------------|------------|---------|------
_NULL_ | 32 + type  | 0    |      |     | 33 | length(class_name) | class_name |         |
_0_    |    type    |      |      |     | 33 | length(class_name) | class_name | ser_tag | Data |
_1_    | 32 + type  | nElem|      |     | 33 | length(class_name) | class_name | ser_tag | Data |
_2_    | 64 + type  | dim1 | dim2 |     | 33 | length(class_name) | class_name | ser_tag | Data |
_N_    | N<<5 + type| dim1 | dim2 | ... | 33 | length(class_name) | class_name | ser_tag | Data |

Where the first 3 elements of data 
(`33`,`length(class_name)`,`class_name`) are a serialised representation of the class name (see [Simple data][simpledata]),
`ser_tag` is a `uint8` tag (described below) and
`data` is the serialisation of the object by means described by `ser_tag`

###### ser_tag
The object array's `ser_tag` contains information about the means by which the object has been serialised.
It can have one of three values:

0) The object has been serialised by its own `serialize` method
1) The object has been serialised by the `saveobj` method or function
2) The object has been serialised by calling `struct` on the object

#### Function handles
Function handles are serialised differently depending on their type.
As function handles in MATLAB are purely scalar objects, the rank-component of the tag is utilised for tagging the type of function handle (thus the method to [de]serialise), these types are:

Handle type         |   tag
--------------------|--------
Simple/Class simple | 32 + 25
Anonymous           | 64 + 25
Scoped              | 96 + 25

Function handles are serialised as:
Handle type         |   tag   | data                                       | ...
--------------------|---------|--------------------------------------------|-----------------------------------------
Simple/Class simple |  57     | function name as serialised string         |
Anonymous           |  89     | anonymous function as serialised string    | relevant workspace as serialised struct
Scoped              |  121    | function parentage as serialised cell array|

### Limitations
- Java objects cannot be serialized.
- Cannot handle arrays of more than rank-7.
- Cannot handle arrays where the size of any dimension > (2^32)-1 due to serialising dimensions as `uint32`.
  __NB.__ This includes sparse matrices.
- Handles to nested/scoped functions can only be deserialized when their parent functions
  support the [BCILAB][bciref] argument reporting protocol (e.g., by using arg_define).
- New MATLAB objects need to be reasonably friendly to serialization; either they support
  construction from a struct, or they support saveobj/loadobj(struct), or all their important
  properties can be set via set(obj,'name',value).

## Old vs New
- Standardisation of tags means fewer magic numbers
- Alignment of tag information with those of C++ MEX API
- Support for struct-arrays and object-arrays rather than scalars
- Standardisation allows unification of several functions (serialising chars and logicals, and in the case of C++ complexes) improving maintainability

[tag]: #tag-format
[simpledata]: #simple-data
[sparse]: https://uk.mathworks.com/help/matlab/ref/sparse.html
[bciref]: https://sccn.ucsd.edu/wiki/Arg_define
