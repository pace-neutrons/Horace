[<-previous](./0021-errors-and-warnings.md) |
next->

# 22 - Use keyword args in Python and MATLAB

Date: 2021-Feb-16

## Status

Proposal

## Context

As we will increasingly be calling Horace functions from both MATLAB and Python,
introducing consistency in how arguments are passed will simplify user interaction with the toolkit in both environments. 

MATLAB and Python have different argument passing conventions,
e.g. Python does not support flags such as `-flag`,
and MATLAB and Python deal with keyword arguments in similar, but different ways. 

This document reviews this in detail, and recommends a convention for function arguments.


### Python

Currently, we don’t have an established syntax for Python. Because we have a clean slate it makes sense to only have a Pythonic syntax using required positional, optional positional, and optional keyword/value pairs

```python
def function_name(a, b, *args, **kwargs):
	# body

function_name(a, b, c, d, keyword_1=val_1, keyword_2=val_2, …)
```
Any argument may be specified as `value` or `name=value`.
All arguments to the right of an argument which has been provided as a name/value pair must follow that syntax.
The order of named arguments is not fixed.

Python does not natively support flag arguments, and they are not used in the core language. They are supported in a small number of Python libraries, notably `matplotlib` that was modelled on the MATLAB API. Many of these have been removed in more recent releases of the library. Flag arguments may be implemented on any function as optional string arguments with custom handling.


### Matlab

The Horace/Herbert source uses a wide range of API syntax:

- `flagname` and `-flagname` flag arguments
- true and false flags: `flagname` (`true`) and `noflagname` (`false`)
- key-value pairs `'keyword', value, ...`
- positional parameters
- optional parameters interspersed with positional parameters in some functions

The key-value pair syntax is equivalent to the Pythonic syntax, e.g. `function_name(a, b, c, d, ‘keywordA’, valA, ‘keywordB’, true, …)`.

The mix of `-flagname` and `flagname` introduces complexity into argument parsing - specifically identifying if a string argument `flagname` is a flag or a keyword argument.

Inclusion of negated flags allows inconsistent, ambiguous or multiplicitous arguments to be defined, complicating the user experience, e.g. `-disable-x` vs `-nodisable-x` vs `-enable-x` vs `-noenable-x` vs `-x`

## Decision

The MATLAB APIs must support positional, optional flag and keyword arguments:

- flag arguments will be prefixed with `-`
- flag arguments will default to `false` if not passed
- flag arguments passed as keywords will have Boolean values (`True` / `true`) rather than a string value (`'true'`)
- if the same parameter is passed as both a flag and keyword argument with inconsistent values an error will be raised, otherwise the parameter is set to the passed value
- support for negated flags, prefixed with `no`, will be removed. All flags will map to `true` when specified. Flag names may include the `no` prefix to make their meaning clear, e.g. `-nopix` will suppress pixel handling in that function
- flag arguments may be truncated to the minimum unambiguous string for all flags defined on that function e.g. `-flagname`, `-flag`, `-f` are all valid. No other abbreviations will be supported
- keyword arguments may not be abbreviated.

The Python API will use ordered (mandatory) positional, optional positional and keyword arguments in the function definition.

All optional arguments must appear between the positional and keyword arguments.


## Consequences

- The Python-MATLAB wrapper can be simply implemented, passing the Python `*args` and `**kwargs`directly to MATLAB as an array by unpacking the arguments
- The simple wrapper allows flags to be passed from Python, although this is not a Pythonic syntax. This ability will not be "officially" supported
- The following calls are all equivalent:
```python
wrapped_function_name(a, b, flagname=True)
wrapped_function_name(a, b, 'flagname', True)
wrapped_function_name(a, b, '-flagname')
```
```matlab
function_name(a, b, '-flagname');
function_name(a, b, 'flagname', true);
```

- MATLAB argument parsing will be solely responsible for the processing of arguments

- MATLAB argument parsing will need to manage flags passed in both 'flag' and 'keyword' form

- All MATLAB functions which currently support optional arguments out of order must be updated, either creating a new function name with the alternate signature (e.g. `cut` with no projection) or additional keyword arguments (e.g. `lattice` in `dispersion_plot`)
- The inclusion of optional arguments alongside flags/keyword arguments allows the possibility of ambiguity in argument parsing e.g. 

```matlab
function_name(req, opt1, opt2, varargin)
% req required argument
% opt1 optional argument
% opt2 optional argument
% -flagname flag argument (may be passed as 'flagname' keyword)
```

A call from MATLAB to

```matlab
function_name(1, "flagname", true)
```
or from Python

```python
wrapped_function_name(1, "flagname", True)
```
could reasonably be interpreted as

```matlab
req = 1; opt1 = "flagname"; opt2 = True; flagname = false (default)
```
rather than the intended
```matlab
req = 1; opt1 = undefined; opt2 = undefined; flagname = true
```
