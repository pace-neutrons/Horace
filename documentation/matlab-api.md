# MATLAB API discussion

This document is intended to describe the means by which argument flags should be passed into PACE MATLAB programs.
This is discussed in conjunction with an observation that a migration towards a Python interface is intended in the near future.


## Current Use in Language
### MATLAB
MATLAB uses a mixture of flag and keyword value args. Examples from the standard language include, which mostly seem to revolve around interactions with the underlying system:
```
load(filename,'-ascii')
whos('-file','durer.mat')
checkcode('-id', filename)
```

Although Herbert's variant of `matlab_xunit` based `runtests` uses flags:
```
runtests(tests, '-verbose')
```
Core MATLAB seems to have made a move more towards keyword-value
```
arrayfun(@()(), list, 'UniformOutput', true)
runtests(pwd,'IncludeSubfolders',true)
runtests(tests, 'LoggingLevel', matlab.unittest.Verbosity.VERBOSE)
```

### Python
Python's main method of handling variable arguments is to use the standard `*args` and `**kwargs` arguments.

```
def function_name(*args):
    for arg in args:
        print(arg)

function_name(1,2,3,4)

def function_name(**kwargs):
    if kwargs.get('header', False):
        print(header)
        del kwargs['header']
    for arg in kwargs.items():
        print(arg)

function_name(a=1, header='Hello World', b=4)
```
Any Python argument can be treated like a keyword argument.
```
def function_name(a,b,c):
    print(a, b, c)

function_name(1,c=2,b=1) # A is positional
```

Python also allows default (optional) arguments
```
def function_name(a=17):
    print(a)

function_name(31) # 31
function_name()   # 17
```

Any or all of these can be used in combination with each other.

### Parsers

### `inputParser`
Built-in `inputParser` supports positional, optional and required or optional key-value arguments

### `parse_arguments`
PACE's `parse_arguments` supports positional, required and optional key-value pairs (`'name', value`) and flags ( `-flagname`, `-noflagname`, unique substring)

| Type of Arg | `inputParser` | `parse_arguments` |
|:-----------:|:-------------:|:-----------------:|
| Positional  |      Y        |        Y          |
| Required    |      Y        |        Y          |
| Optional    |      Y        |        Y          |
| Key-value   |      Y        |        Y          |
| Flag        |      X        |        Y          |

## Options

### Dash flags `-(no)flagname`

Allow flags with dashes in MATLAB

#### MATLAB

```
function_name(a, b, c, '-flagname')
function_name(a, b, c, '-noflagname')
```

#### Python

```
def function_name(a, b, c, flagname = true) #default
def function_name(a, b, *args, **kwargs)
    if any(arg.startswith('-') for arg in args): # Handle
    # args = [value-of-c, ...]
    # kwargs = {filename: true, ...}
```
As Python does not allow args starting with `-`, this will require some way of handling the flag.
```
def function_name(a, -flag) # ERROR
```

This can either be by passing flags through as a string pre-parsing the input before the call to MATLAB to be handled by `*args`
```
def function_name(a, b, *args, **kwargs)
    if any(arg.startswith('-') for arg in args if isinstance(arg, string)): # Handle
```
Or passed directly through as one of args.
```
def function_name(a, b, *args, **kwargs):
    call_MATLAB(a, b, *args, **kwargs)
```

Which would be called as:
```
function_name(a, b, '-flag')
```

Or by passing in through dict form to be handled by `**kwargs` (nobody would do this).
```
function_name(a, b, **{'-flag':True})
```

This will depend on the ultimate interface `call_MATLAB` has.

#### Pros and Cons

##### Pros

- Less typing for the average user?
```
function_name(a, '-flag')
function_name(a, 'flag', 1)
function_name(a, '-noflag')
function_name(a, 'flag', 0)
```
- Python can just pass args directly into the MATLAB call in principle

##### Cons

- Raises questions about the separation between arguments and flags are additional arguments to be labelled as flags?
- Not Pythonic way of doing things
- Requires special parsing of `-`'d args using own parser
- MATLAB seems to be moving towards keyword-value scheme
- Potentially inconsistent, ambiguous or multiplicitous arguments (in terms of `-disable-x` vs `-nodisable-x` vs `-enable-x` vs `-noenable-x` vs `-x`)
- Requires mixed syntax for passing keyword values anyway

#### Transition implications

- Requires potential workaround in Python
- Requires keeping `parse_arguments` up to date and functional

### Keyword args
#### MATLAB

`inputParser` or PACE's `parse_arguments` would also work here in principle.

MATLAB keyword arguments are commonly passed through as:

```
function_name(a, b, c, 'flagname', true)
function_name(a, b, c, 'flagname', false)
```

#### Python

Python keyword arguments are commonly passed through as:

```
function_name(a, b, c, flagname = true)
function_name(a, b, c, flagname = false)
```

If `call_MATLAB` is implemented along the lines of:
```
def call_MATLAB(func, *args, **kwargs):
    call_matlab_function = print # For purposes of running this
    args = list(args)
    for arg in kwargs.items(): # Accumulate kwargs into args to unpack
        args += [*arg]
    call_matlab_function(func, *args)
```
It is trivial to map Python kwargs to MATLAB keyword-values


#### Pros and Cons

##### Pros

- Can eventually use built-in MATLAB parser (should be kept stable).
- More Pythonic and should lead to a consistent interface between the two.
- Easier to standardise (single, consistent syntax)

##### Cons

- If we use built-in MATLAB parser, out of our control if further functionality needed or may not be kept stable by matlab

#### Transition implications

- Requires implementation similar to that as noted above
- Replace `parse_arguments` flag parser temporarily with variant printing deprecation warning and allow both syntaxes to coexist for a period

## Proposal

- Use positional parameters for core data
- Use optional parameters where appropriate
- Use key-value arguments for remaining arguments, including  rather than flag/no-flag arguments

The use of `[-][no]flagname` is not supported in Python, other than as one or more "string value optional arg" and is not Pythonic. The conversion for MATLAB flag-type args could be handled in the Python <-> MATLAB wrapper as there's a well defined mapping between key/value and flag syntax.

# Appendix

## Definitions

### Flags
Flags are a common way of distinguishing arguments from operating modes and are used in many standard programs such as POSIX compliant programs and Windows command line tools to allow extension of operation without limiting the operands of a particular function or requiring a separate program.

e.g.
```
ls -l --sort=size *.txt
dir /w /o:s *.txt
```
Here, `-l` and `/w` are flags, which set a relevant operation mode to `true`. `--sort=size` and `/o:s` are flags which set an internal variable to a particular value as described by their argument.
If not separated by some extra marker (`-` in POSIX, `/` in Windows), these would instead by interpreted as arguments to the program.

### Positional arguments
Positional arguments are arguments which appear at a particular position in a function signature or call.
These are usually mapped one-to-one or many-to-one from signature to call.
e.g
Signature:
```
MATLAB: function function_name(arg1, arg2, varargin)
PYTHON: def function_name(arg1, arg2, *varargin)
```
Both would be called as
```
function_name(a, b, c, d, ...)
```
Where `a` maps to `arg1`, `b` to `arg2`, `c` and `d` to a list (cell array in MATLAB, tuple in Python) `varargin`.

### Keyword-Value Pairs
Keyword value pairs are a common means of allowing a variable number of arguments without requiring that they be in any particular order. Typically they follow positional arguments.
e.g.
Signature:
```
PYTHON: def function_name(**kwargs)
```
Called as
```
function_name(a=1,b=2)
```
`a` and `b` are stored (unordered) in a Python `dict` (similar to `containers.Map` in MATLAB) called `kwargs`.

In MATLAB, these are more commonly implemented through a variable count argument:
```
MATLAB: function function_name(varargin)
```
Called as
```
function_name('a', 1, 'b', 2)
```
Which may subsequently be parsed by the matlab `inputParser` (or PACE's local `parse_arguments`)

### Python's `*` and `**`
As described previously, Python's `*args` and `**kwargs` are standard ways of handling variable numbers of arguments.
Python's `*` and `**`, however, are general statements of packing and unpacking `list`s and `dict`s respectively.

Relevant here only as:
```
def function_name(a, b, c):
    print(a, b, c)

# Unpack list - For positional args
myList = [1, 2, 3]
function_name(*myList) # 1 2 3
# Unpack dict - For keyword args
myDict = {'a':3, 'b':4, 'c':5}
function_name(**myDict) # 4 5 6
```
### Title
#### MATLAB
#### Python
#### Pros and Cons
##### Pros
##### Cons
#### Transition implications
