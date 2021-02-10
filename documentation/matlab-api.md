### MATLAB


```
function_name(a, b, c, '-flagname')
function_name(a, b, c, '-noflagname')

function_name(a, b, c, 'flagname', true)
function_name(a, b, c, 'flagname', false)
```


Arguments are parsed using one of:

- built in `inputParser` supports positional, optional and required or optional key-value arguments
- TP `parse_arguments` supports positional, required and optional key-value pairs (`'name', value`) and flags ( `-flagname`, `-noflagname`, unique substring)



### Python

```
function_name(a, b, c, flagname = true)
function_name(a, b, c, flagname = false)
```

```
def function_name(a, b, c, flagname = true) #default
def function_name(a, b, *args, **kwargs)
        # args = [value-of-c, ...]
        # kwargs = {filename: true, ...}
```



### Proposal

- Use positional parameters for core data
- Use optional parameters where appropriate
- Use key-value arguments for remaining arguments, including  rather than flag/no-flag arguments



The use of `[-][no]flagname` is not supported in Python, other than as one or more "string value optional arg" and is not Pythonic. The conversion for MATLAB flag-type args could be handled in the Python <-> MATLAB wrapper as there's a well defined mapping between key/value and flag syntax.