[<-previous](./0022-use-keyword-args.md) |
next->

# 23 - Error Identifier Format

Date: 2021-Mar-24

## Status

Accepted

## Context

Currently throughout PACE, different error identifiers are used to reference the same error.
This makes it difficult in cases of specific try-catch (as described in [ADR 21](./0021-errors-and-warnings.md)) to know what to compare against.

Examples include:
```
herbert_core/applications/multifit/@mfclass/fit.m                                             : Herbert:mfclass:invalid_argument
herbert_core/classes/data_loaders/@rundata/private/gen_runfiles_.m                            : GEN_GRUNFILES:invalid_arguments
herbert_core/utilities/general/catstruct.m                                                    : catstruct:InvalidArgument
herbert_core/classes/data_loaders/parse_arg.m                                                 : PARSE_ARG:wrong_arguments

herbert_core/classes/data_loaders/@rundata/get_par.m                                          : RUNDATA:invalid_argument
herbert_core/classes/data_loaders/@rundata/get_rundata.m                                      : RUNDATA:invalid_arguments

herbert_core/utilities/maths/noisify.m                                                        : HERBERT:noisify
herbert_core/utilities/misc/objdiff.m                                                         : YMA:OBJDIFF:NotEnoughInputs
herbert_core/utilities/xml_io_tools/xmlwrite_xerces.m                                         : xml:FileNotFound
herbert_core/admin/matlab_nbits.m                                                             : MATLAB:NBITS

_test/shared/matlab_xunit_ISISextras/@TestCaseWithSave/private/get_ref_dataset_.m             : TestCaseWithSave:invalid_argument
_test/shared/matlab_xunit_ISISextras/@TestCaseWithSave/private/instantiate_methods_to_save_.m : TEST_CASE_WITH_SAVE:invalid_argument

erbert_core/classes/MPIFramework/@iMessagesFramework/iMessagesFramework.m                     : iMESSAGES_FRAMEWORK:invalid_argument
herbert_core/classes/MPIFramework/@iMessagesFramework/iMessagesFramework.m                    : MESSAGES_FRAMEWORK:invalid_argument
herbert_core/classes/MPIFramework/@iMessagesFramework/private/mix_messages_.m                 : iMESSAGES_FRAMEWOR:invalid_argument
```
From which it should be obvious that this is not a consistent scheme for error identification, even within the same set of routines.

As MATLAB standards do not enforce a particular style of error statement 
(though it does encourage certain forms [see here](https://uk.mathworks.com/help/matlab/ref/mexception.html#mw_e5712c7f-3862-42fa-9a8f-8de992cdc6d4)),
this document seeks to outline the format an error identifier should take as well as establish a list of standard common error identifiers.

Also due to the fact that MATLAB has changed its method of error identification between versions in the past, this document establishes its scheme based on the most recent currently used version (2020b).

## Decision

Following discussions it was decided that it would be useful to have a standard format with 3 components, in the following format
(expanding upon that initially outlined in [ADR 21](./0021-errors-and-warnings.md)).


```matlab
error('(HORACE|HERBERT):(function_name|ClassName):error_identifier')
```

This scheme is based on the current (2020b) MATLAB error identifiers common to many functions.

- `HORACE` or `HERBERT` should be in all caps.
- The `function_name` and `ClassName` should exactly match that of the parent function/class, including casing.
- The `error_identifier` should be in `lower_snake` case and should succinctly identify the error message, using one of
     the following names if the error falls within their remit.
     **NB.** This is in contrast to the usual MATLAB format which uses `lowerCamelCase`, but is in keeping with the majority
     of identifiers currently used in PACE.

| Identifier         | Issue                                                                                         |
| :----------------- | :-------------------------------------------------------------------------------------------- |
| `invalid_argument` | Argument fails validation, there are insufficient arguments or argument is an unexpected flag |
| `invalid_output`   | Insufficient outputs                                                                          |
| `not_implemented`  | Called function is virtual/abstract                                                           |
| `not_available`    | Method or function is not available on current system or current Horace/Herbert configuration |
| `array_mismatch`   | Array dimensions are incompatible (will usually be identified by MATLAB's error)              |
| `file_not_found`   | File not found on system                                                                      |
| `io_error`         | Issues with opening, reading or writing files                                                 |
| `runtime_error`    | Unspecified issues, caused by running valid code under specific circumstances                 |
|                    | (e.g. caught from mex code and propagated to MATLAB)                                          |
| `parallel_error`   | Unspecified issues, caused by working with parallel cluster or MPI framework                  |
|                    | (e.g. caught from mex code and propagated to MATLAB)                                          |
| `system_error`     | Issues when calling system (shell) functions from MATLAB                                      |

## Consequences

In future error identifiers should be written to follow these guidelines and in cases where surrounding code is being updated an effort should be made to
correct error identifiers which do not fall under these rules.

Having a defined set of guidelines will make:
- Aid developers with quickly identifying error source
- Make catching errors by identifier easier
- Aid new developers in how to contribute to PACE
- Make conversion to any new error format standard easier

It will also:
- Require updating of legacy code
