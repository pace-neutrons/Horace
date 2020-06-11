[<-previous](0011-version-project-with-cmake.md) | [next->](0013-use-jenkins-for-secrets-management.md)

# 12 - Use network storage for large data files

Date: 2020-Apr-01

## Status

Accepted

## Context

Horace and Herbert will require access to large `sqw` and sets of `nxspe` data files as source data and "expected" results for unit and system testing.

These data files are too large to store in GitHub along side the test code, but will not change frequently.

Similar data files are also required for Euphonic testing.

## Decision

The data will be stored in STFC hosted SAN (storage area network).

Tests will read the data from this network storage location, either by copying the files locally or reading the remote file.

## Consequences

- Test data files can be shared between the PACE projects (Euphonic, Horace/Herbert).
- Test data will be created in such a way as to be re-usable between projects where sensible.
- The stored data will include source `nxspe` files to ensure that the generated `sqw` files and any subsequent cuts can be recreated in the event of file format updates.
- Copying the data locally before use or reading the data remotely during the tests both have performance implications. The best alternative should be selected in each case.
- All Jenkins build agents and developers must have read access to the data.
- Developers will need write access to the SAN to manage the data content.
- Data will *NOT* be accessible to any third-party developers (i.e. those without access to the RAL network) without the creation of a public gateway (c.f. Mantid mirrors).
