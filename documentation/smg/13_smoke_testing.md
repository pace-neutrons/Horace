# Smoke Testing

**This document is incomplete**

This document records a basic set of smoke tests.
These tests should be carried out before releasing a package to users.

## List of smoke tests

1. Calling `horace_init` from within Matlab:

    - shows the Herbert and Horace headers (which contain the correct version).
    - adds all directories inside `Horace/` and `Herbert/` to the Matlab path.

2. Loading an `sqw` file raises no errors.

3. Calling `herbert_version` and `horace_version` returns the correct version
strings.

4. Calling a mex function with no input or output arguments returns the same
version string as `horace_version`.
This ensures the mex DLL is compiled correctly and exports the correct symbols.

**This document is incomplete**
