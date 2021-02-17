[<-previous](./0020-use-c-mex-api.md) |
next->

# 21 - Use keyword args in Python and MATLAB

Date: 2021-Feb-16

## Status

Proposal

## Context

### Python 

Currently, we don’t have an established syntax for Python. Because we have a clean slate it makes sense to only have a Pythonic syntax using required positional, optional positional, and optional keyword/value pairs

```python
def function_name(a, b, *args, **kwargs):
	# body
```

 e.g. `function_name(a, b, c, d, keyword_1=val_1, keyword_2=val_2, …)`

Python does not natively support flag arguments, and they are not used in the core language. They are supported in a small number of Python libraries, notably `matplotlib`, which was modelled on the MATLAB API, and may be implemented on any  function as optional string arguments with custom handling.


### Matlab 

The Horace/Herbert source uses a wide range of API syntax:

- `flagname` and `-flagname` flag arguments
- true and false flags: `flagname` (`true`) and `noflagname` (`false`)
- key-value pairs `'keyword', value, ...`
- positional parameters
- optional parameters interspersed with positional parameters in some functions

The key-value pair syntax is equivalent to the Pythonic syntax, e.g. `function_name(a, b, c, d, ‘keywordA’, valA, ‘keywordB’, true, …)`.

The mix of `-flagname` and `flagname` introduces complexity into argument parsing - specifically identifying if a string argument `flagname` a flag or a keyword argument?


## Decision

The MATLAB APIs will support positional, optional flag and keyword arguments:

- flag arguments will be prefixed with `-`
- if the same parameter is passed as both a flag and keyword argument an error will be raised if their values are inconsistent
- flag arguments may be negated, specified as `-noflagname` (`false`) or `-flagname` (`true`). An error will be raised if this prefix would lead to an ambiguity with another flag argument e.g. defining`-nodes` (use nodes) and `-des`
- flag arguments may be abbreviated

The Python API will use positional, optional and keyword arguments.

All optional arguments must appear between the positional and keyword arguments. 

## Consequences

- The Python-MATLAB wrapper can be simply implemented, passing the Python `*args` and `**kwargs`directly to MATLAB as an array
- The simple wrapper allows flags to be passed from Python, although this is not a Pythonic syntax. This ability not be "officially" supported.
- The following calls are all equivalent:
```python
wrapped_function_name(a, b, flagname=true)
wrapped_function_name(a, b, 'flagname', 'true')
wrapped_function_name(a, b, '-flagname')
```
```matlab
function_name(a, b, '-flagname');
function_name(a, b, 'flagname', 'true');
```

- MATLAB argument parsing will be solely responsible for process of arguments
- MATLAB argument parsing will need to manage flags passed in both 'flag' and 'keyword' form
- All MATLAB functions which currently support optional arguments out of order must be updated, either creating a new function name with the alternate signature (e.g. `cut` with no projection) or additional keyword arguments (e.g. `lattice` in `dispersion_plot`)