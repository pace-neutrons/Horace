# The serialiser

In order to efficiently transfer MATLAB information between storage, be it via networked interaction (such as MPI) or to disc efficiently, the information is first "serialised" into a representation. This document details the operation of the serialisers defined in:
```
<HERBERT_ROOT>/herbert_core/utilities/misc/hlp_serialise
<HERBERT_ROOT>/herbert_core/utilities/misc/hlp_deserialise
<HERBERT_ROOT>/_LowLevelCode/cpp/cpp_communicator/serialiser/c_serialise
<HERBERT_ROOT>/_LowLevelCode/cpp/cpp_communicator/serialiser/c_deserialise
```

The serialised format has recently been updated to be more consistent and to have greater capabilities such as serialising arrays of structs/objects.

For reference, the old format is also detailed below

# New format

## Standard header format

The new style has a standardised header format depending on the shape of the data (with the exception of function handles).
This format allows extension to support arrays of objects and structs in a way which the old serialiser couldn't.
It also greatly simplifies the tag structure and allows it to align with the C++ MEX API data types.
Data in these cases is serialised in the linearised order as defined by `data(:)` and the array reshaped by the deserialiser.

This standard format for the header is as follows:
Rank |     tag    | dim1 | dim2 | ... 
-----|------------|------|------|-----
NULL | 32 + type  | 0    |      |     
0    |    type    |      |      |     
1    | 32 + type  | nElem|      |     
2    | 64 + type  | dim1 | dim2 |     
N    | N<<5 + type| dim1 | dim2 | ... 


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
Simple data (tags 0-12) are serialised as:

Rank |     tag    | dim1 | dim2 | ... | Data
-----|------------|------|------|:---:|------
NULL | 32 + type  | 0 
0    |    type    |      |      |     | Data
1    | 32 + type  | nElem|      |     | Data
2    | 64 + type  | dim1 | dim2 |     | Data
N    | N<<5 + type| dim1 | dim2 | ... | Data

#### Complex Data
Complex numerical data (tags 13-22) are serialised as:

Rank |     tag    | dim1 | dim2 | ... |    Data   |   ...
-----|------------|------|------|:---:|-----------|----------
NULL | 32 + type  | 0    |      |     |           |
0    |    type    |      |      |     | Real Data | Imag Data
1    | 32 + type  | nElem|      |     | Real Data | Imag Data
2    | 64 + type  | dim1 | dim2 |     | Real Data | Imag Data
N    | N<<5 + type| dim1 | dim2 | ... | Real Data | Imag Data

#### Sparse data
Sparse numeric data (tags 29-31) are serialised as:

Rank |   Type  |     tag  | dim1 | dim2 | Data | ... |    ...    | ...
-----|---------|----------|------|------|:----:|:---:|-----------|------
2    | Real    | 64 + type| dim1 | dim2 |   i  |  j  | Data      |
2    | Bool    | 64 + type| dim1 | dim2 |   i  |  j  | Data      |
2    | Complex | 64 + type| dim1 | dim2 |   i  |  j  | Real Data | Imag Data

Based on `sparse(i,j,data)` [MATLAB documentation][sparse]

__NB.__ only rank-2 sparse arrays are permitted in MATLAB

__NB.__ Due to storing dimensions as `uint32` data, rather than `double`, sizes of sparse arrays are limited to (2^32)-1

#### Struct data
Structured tree data (tag 24) uses the standard header format:

Rank |     tag    | dim1 | dim2 | ... | Data
-----|------------|------|------|:---:|------
NULL | 32 + type  | 0 
0    |    type    |      |      |     | Data
1    | 32 + type  | nElem|      |     | Data
2    | 64 + type  | dim1 | dim2 |     | Data
N    | N<<5 + type| dim1 | dim2 | ... | Data


Where data is formatted as follows:

nFields | length(fieldName1) | length(fieldName2) | ... | fieldName1 | fieldName2 | ... | struct2cell(data)
--------|--------------------|--------------------|:---:|------------|------------|:---:|------------------

nFields and fieldName lengths are serialised as `uint32`

__NB.__ For struct arrays `struct2cell` produces a Rank-(N+1) cell array, this means that for struct arrays, the limit on rank is 6.

#### Cell array
Cell array data (tag 23) are serialised as:

Rank |     tag    | dim1 | dim2 | ... | Data
-----|------------|------|------|:---:|------
NULL | 32 + type  | 0 
0    |   type     |      |      |     | Data
1    | 32 + type  | nElem|      |     | Data
2    | 64 + type  | dim1 | dim2 |     | Data
N    | N<<5 + type| dim1 | dim2 | ... | Data

Where `data` is the concatenation of the serialisation of each element.

#### Object Array
Object array data (tag 23) are serialised as:

Rank |     tag    | dim1 | dim2 | ... |Data|     ...            |    ...     |   ...   |  ...
-----|------------|------|------|:---:|----|--------------------|------------|---------|------
NULL | 32 + type  | 0    |      |     | 33 | length(class_name) | class_name |         |
0    |    type    |      |      |     | 33 | length(class_name) | class_name | ser_tag | Data |
1    | 32 + type  | nElem|      |     | 33 | length(class_name) | class_name | ser_tag | Data |
2    | 64 + type  | dim1 | dim2 |     | 33 | length(class_name) | class_name | ser_tag | Data |
N    | N<<5 + type| dim1 | dim2 | ... | 33 | length(class_name) | class_name | ser_tag | Data |

Where
`33` is a 1-D char tag, 
`length(class_name)` is stored as a `uint32`, 
`class_name` is a char string, 
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

Handle type         |   tag   | value
--------------------|---------|-------
Simple/Class simple | 32 + 25 | 57
Anonymous           | 64 + 25 | 89
Scoped              | 96 + 25 | 121

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
  support the BCILAB argument reporting protocol (e.g., by using arg_define).
- New MATLAB objects need to be reasonably friendly to serialization; either they support
  construction from a struct, or they support saveobj/loadobj(struct), or all their important
  properties can be set via set(obj,'name',value).

## Old vs New
- Standardisation of tags means fewer magic numbers
- Alignment of tag information with those of C++ MEX API
- Support for struct-arrays and object-arrays rather than scalars
- Standardisation allows unification of several functions (serialising chars and logicals, and in the case of C++ complexes) improving maintainability

## Old Format



### Tags

Tag | Meaning
----|-----------------------------
0   | char string
1   | scalar double
2   | scalar single
3   | scalar int8
4   | scalar uint8
5   | scalar int16
6   | scalar uint16
7   | scalar int32
8   | scalar uint32
9   | scalar int64
10  | scalar uint64
17  | double
18  | single
19  | int8
20  | uint8
21  | int16
22  | uint16
23  | int32
24  | uint32
25  | int64
26  | uint64
33  | cell
34  | cell scalars
35  | cell scalars mixed complexity
36  | cell strings
37  | empty cell 
38  | cell empty prototype class
39  | cell bools
128 | struct
130 | sparse_real
131 | sparse_complex
132 | char array
133 | logical
134 | object
135 | self serialised object
150 | function_handle*
151 | function_simple
152 | function_anon
153 | function_scoped
200 | emptystring

\* unused

### Limitations
- Java objects cannot be serialized
- Arrays with more than 255 dimensions have their last dimensions clamped
- Handles to nested/scoped functions can only be deserialized when their parent functions
  support the BCILAB argument reporting protocol (e.g., by using arg_define).
- New MATLAB objects need to be reasonably friendly to serialization; either they support
  construction from a struct, or they support saveobj/loadobj(struct), or all their important
  properties can be set via set(obj,'name',value)
- In anonymous functions, accessing unreferenced variables in the workspace of the original
  declaration via eval(in) works only if manually enabled via the global variable
  tracking.serialize_anonymous_fully (possibly at a significant performance hit).
  note: this feature is currently not rock solid and can be broken either by Ctrl+C'ing
        in the wrong moment or by concurrently serializing from MATLAB timers.

[tag]: #tag-format
[sparse]: https://uk.mathworks.com/help/matlab/ref/sparse.html
