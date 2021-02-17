[<-previous](./0020-use-c-mex-api.md) |
next->

# Handling Errors and Warnings

This document seeks to address the inconsistent error handling scheme in pace and lay down rules for how
error handling should be addressed in future development and retroactively in older code.

## Current state
Presently in PACE, there are different mechanisms being used which obscure traceback on errors and warnings these are:

- Passing error states and messages back through arguments and optionally throwing
  ```matlab
  function [data_out, fitdata, ok, mess] = fit (obj, varargin)

  if nargout<3
      throw_error = true;
  else
      throw_error = false;
  end

  [...]

  if ~ok_sim
    ok = false;
    if throw_error, error_message(mess), else, return, end
  end

  (@mfclass/fit)
  ```
- Throwing MATLAB errors and performing global catches and rethrows
  ```matlab
  try
     obj = set_bfun@mfclass (obj, varargin{:});
  catch ME
      error(ME.message)
  end

  (@mfclass_tobyfit/set_bfun)
  ```

### Issue

There is inconsistency throughout PACE about how errors and warnings are handled,
which leads to maintainability issues and confusing code as well as a decision
on the developer's part about which path to follow.

The fact that errors are not reported from where they are triggered means that the backtrace
will also report the wrong location, rendering the backtrace less useful for the developer.
It is argued that this is in order to not deter new users who will see long tracebacks, however,
the counter argument to this is that a user should be worried if they are doing erroneous operations
and should understand that the traceback is intended for the developer rather than them.

## Alternatives

There are situations in which the developer may wish to not have MATLAB explicitly error out when
a user, for example, simply inputs bad arguments. In these situations a mechanism exists for handling
known or expected exception classes.

```matlab
try
   ...
   error('PACE:errorClass', errorMessage)
catch ME
   switch ME.identifier
   case 'PACE:errorClass'
     warning("Error identified and caught")
   case {'PACE:errorClass1', 'PACE:errorClass2'}
     warning("Error is class1 or 2")
   otherwise
     rethrow(ME)
   end
end
```
**N.B.** `rethrow` will throw the original error with the original backtrace meaning that
the developer can still determine where the problem occurred. The warning, however, will trigger with a
backtrace pointing to its location, thereby known/expected exceptions will not deter the average user.

In MATLAB there are also ways to modify existing warning messages to add clarification:
```matlab
try
   C = [A; B];
catch ME
   switch ME.identifier
   case 'MATLAB:catenate:dimensionMismatch'
      msg = ['Dimension mismatch occurred: First argument has ', ...
            num2str(size(A,2)),' columns while second has ', ...
            num2str(size(B,2)),' columns.'];
        causeException = MException('MATLAB:myCode:dimensions',msg);
        ME = addCause(ME,causeException);
   end
   rethrow(ME)
end
```

## Recommendations

- Replace all handling via args (`ok`, `mess`  syntax) with try-throw-catch process
- Use `rethrow` over `throw(ME.message)` which
  1. Destroys the identifier
  2. Obscures the backtrace
- Never perform a global catch. Specific catches should be used where relevant, preferably using `switch` for clarity.
- Use a standard form for PACE thrown errors for easy identification, perhaps:
  ```matlab
  error('PACE:error', errorMessage)
  ```
- On warning messages, not only should the problem be reported, but where possible, the solution.
