## Questions

1) is it necessary that the V4 API be 100% compatibly with the V3? That would require multiple function wrappers to be implemented in the class masking push of functionality down into helper functions.

2) ~~Do we need to support the legacy `fit*` and `multifit_legacy*` APIs in the new SQW objects?~~ 
		*No: confirmed by Toby 19-Nov*

3) The SQW and DND class interfaces define a full arithmetic (plus, divide etc.) overloading the MATLAB operators. These manipulations are done in-memory for the full dataset. There is a requirement to implement file-backed operations, where the data for the arguments are specified by file-name not passed as a preloaded data object.

This needs to be clarified -- what is the purpose of this change:

1. remove lines of code for users, so there is no need to load data from file and then manipulate, simply manipulate
2. support operations on larger file sizes i.e. data sets that are too big to load in to memory

Target API for these file backed operations: 
     - `plus(a, filename)`, `plus(filename1, filename2)`?
          - does this return a new SQW object with the file headers from the loaded file appropriately modified data or create a new file containing the updated data and return that name?

4) Can the SQW refactor be done without a parallel update to the file format / switch to HDF5?

