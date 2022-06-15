# Serialiable interfaces
Date: 2022-06-01

## Objectives and problems to solve.
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

1. The object has an empty constructor.
2. The object has a public interface which allows to define(assign) to an empty object any contents the non-empty object may have,defining in this way any valid non-empty object.

If such assumptions are satisfied, we may define *serializable* objects, which need to define only handful of class-specific methods, but would immediately have number of very useful generic features. The class diagram describing such object is presented on the **Fig 1**:

<center>![Serialiable. Main Interface](../diagrams/serializable_main_interface.png)</center>

**Fig 1:** Main interface and methods of **serializable** class.

The parent class, presented on the fig, allows easy construction and maintenance of standardized serializable objects by defining the following abstract methods:

**Table 1:**

| Method | Description |
|-----|---------|
|  classVersion | returns the number, which describes current class version. E.g. 1 - for version 1|
| saveableFields | returns list of property names, defining class' public interface |

As soon as these properties are defined, one can use other class methods to serialize/deserialize objects and convert them into structure. The main features of the available methods are summarized in the Tables 2:
** Table 2:**

| Method | Description |
|-----|---------|
|  `struct = to_bare_struct(obj)` | returns structure, with the field names equal to the names returned by `saveableFields` method and values, defined by the values of these fields. If the values are the serializable objects themselves, they converted into correspondent structures recursively|
| `obj = from_bare_struct(obj,data)` | sets the values of the public properties of the serializable interface from the structure, obtained from *to_bare_struct* method |
| `data = to_struct(obj)` | converts `obj` or array of `obj` into the `data` structure using `to_bare_struct` method and adds additional information about the class name and the size and shape of the `obj` array if relevant. |
| *Static:* | |
| `obj = from_struct(data)` | reverse of `to_struct` method, recovering the object or array of objects from the `data`, generated by the `to_struct` method |

Standard loadobj/saveobj and serialize/deserialize methods use the data obtained from the methods described in **Table-2** or the methods themselves to provide/use input for/from Matlab save/load methods or serialize/deserialize methods to save/load data to/from `.mat` files or transform the objects from/to linear arrays of bytes for communications over linear pipes. The serialize/deserialize routines use Herbert-defined serialize/deserialize methods over the structures obtained using to_struct/from_struct methods. 

Two remaining methods provided on the **Fig 1** namely static `loadobj` and `from_old_struct` methods need overloading if/when you need to support loading of the versions of a class, which are different from the the current class version. By default, a standard `loadobj` method exists and this method expects to receive the structure, produced by `to_struct` method. `to_struct` method adds information about the class name, so generic `loadobj` extracts this information and recovers the class. If this information is missing, which may happen when you loading a class structure, generated before the object become `serializable`, you need to overload `loadobj` to provide the empty instance of the class, as described by the code snippet below:
```Matlab
        methods(Static)
            function obj = loadobj(S)
                % boilerplate loadobj method, calling generic method of
                % saveable class. Put it as it is replacing the
                "ChildClass" name by the name of the class the loadobj is
                the method of.
                obj = ChildClass();
                obj = loadobj@serializable(S,obj);
            end
        end
```
By default, the method `from_old_struct` calls `from_bare_struct` method, so it does not need overloading if the structure of your class public interface have not changed. 
If it have changed, it need overloading with the code, converting the old information, stored in the previous class structure into the information, necessary to define new class.

## Interdependent properties problem.

All serializable interface described above and used inside the code is build under assumption that you define class value by assigning the values of the properties one by one. 
All public setters run checks of the validity of the values one wants to assign to the properties and throw exceptions if the input values are invalid. This assumption causes one problem with interdependent properties. For example, arrays `s`,`e`, and `npix` of a `dnd` or `sqw` object need to be the same shape and size arrays. If you are modifying, say, empty `dnd` object assigning `s`, `e` and `npix` one after another, the first assignment would be always invalid, as the sizes of two other arrays are different from the first one while initial object was containing empty data. 

There is number of ways, one can deal with this issue. After discussion, we have decided to select the following approach, summarized on the **Fig 2** describing the interface  used to validate interdependent properties. 

<center>![serializable Validation Interface](../diagrams/Serializable_validation_interface.png)</center>

**Fig 2:** Validation interface for **serializable** class.

 Any interdependent properties for a child of the *serializable* class, which has interdependent properties, have to overload `[ok,mess,obj] = check_combo_arg(obj)` method. This method verifies validity of interdependent properties. Each setter for interdependent properties runs this method within the code snippet:
 ```Matlab
    function obj = set.an_interdependent_prop(obj,val)
        check_general_acceptance_of_input_throw_if_invalid(val);
        if obj.check_combo_arg_
            [ok,mess,obj] = check_combo_arg(obj,val)
            if ~ok
                error('HORACE:interdependent_properties_validation_error',message)
            end
        end
    end
 ```
 
Before the properties are set within the serializable class one by one, the *serializable* code sets the protected property **check_combo_arg_** to false, so the check is not occurring. The code then sets the property **check_combo_arg_** to true and runs check method: *check_combo_arg* after all interdependent properties have been set, throwing if *check_combo_arg* returns false. As the result, user can snot change interdependent properties in a wrong way and needs to use constructor or serializable interface to set defined class with interdependent properties. 

There is other way of setting interdependent properties assuring their validity, namely defining the methods, which allow setting all interdependent properties at once. E.g. setting `s`, `e`, `npix` array may be performed by introducing property `se_npix` with validates and sets all three properties together. This method may be more efficient from point of view of serializing data so will be used where it is justified and convenient.

## Standard serializable class constructor form.

As a *serializable* class has public interface, fully described by the list of properties, returned by *saveableFields* method, it makes sense to define standard constructor, which use this interface to define the contents of the serializable class. The constructor would have the form:
```Matlab
    obj = class_name(positional_val1,positional_val2,positional_val3,... '-key1',val1,'-key2',val2,...);
```
where positional_val1, positional_val2... are the values, one would set up to the public properties of the *serializable* interface in the order, these properties names are returned by *saveableFields* method. The `keys` then would be the names of these properties, following by the requesting values. 

To facilitate creation of such constructors, the *serializable* class has a method:

```Matlab
 [obj,remains] = set_positional_and_key_val_arguments(obj,...
                param_names_list,varargin);
```

where `param_names_list` is the list of the property names. Then, a standard constructor for a serializable object would have a form:

```Matlab
    function obj = an_serializable_obj(varargin)
        prop_names = obj.saveableFields();
        obj = set_positional_and_key_val_arguments(obj,...
                param_names_list,varargin{:});
    end
```

## Generic eq operator.

As serializable classes have public interfaces with values fully defining the state of the object, to compare serializable objects is reasonable to define `eq` operator, which would work by comparing the values, retrieved from public properties provided by *saveableFields* method of the serializable interface.

To avoid code duplication, such operator should be defined directly on *serializable* interface.