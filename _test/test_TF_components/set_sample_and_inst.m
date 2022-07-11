function wout = set_sample_and_inst(win,sample,varargin)
% Add or replace instument and sample information to an sqw object in a convenient single function
%
%   >> wout = set_sample_and_inst (win,sample,instrument)
%
%   >> wout = set_sample_and_inst (win,sample,inst_func,arg1,arg2,...)
%
% Provided as a simple function for the test routines only - it is designed to keep
% the existing test scripts working. Normally, use set_sample and set_instrument
%
% EXAMPLES:
%   >> wout = set_sample_and_inst (win,sample,instrument);
%   >> wout = set_sample_and_inst (win,sample,@maps_instrument,'-efix',600,'S')
%
%
% Input:
% ------
%   win             Input sqw object
%
%   sample          Sample object (IX_sample object) or structure
%                   Note: only a single sample object can be provided. That is,
%                  there is a single sample for the entire sqw data set.
%                   If the sample is any empty object, then the sample is set
%                  to the default empty structure.
%
%   instrument      Instrument object or structure, or array of objects or
%                  structures, with number of elements equal to the number of
%                  runs contributing to the sqw object(s).
%                   If the instrument is any empty object, then the instrument
%                  is set to the default empty structure.
%
% *OR*
%   inst_func       Function handle to generate instrument object or structure
%                  Must be of the form
%                       inst = my_func (p1, p2, ...)
%                  where p1,p2, ... are parameters to be passed to the 
%                  instument definition function, in this case called my_func,
%                  which in this example will be passed as @my_func.
%
%   arg1, arg2,...  Arguments to be provided to the instrument function.
%                  The arguments must be:
%                   - scalars, row vectors (which can be numerical, logical,
%                     structure, cell array or object), or character strings.
%                   - Multiple arguments can be passed, one for each run that
%                     constitutes the sqw object, by having one row per run
%                     i.e
%                       scalar      ---->   column vector (nrun elemnents)
%                       row vector  ---->   2D array (nrun rows)
%                       string      ---->   cell array of strings
%
%                  Certain arguments win the sqw object can be referred to by
%                  special strings;
%                       '-efix'     ---->   use value of fixed energy in the
%                                           header block of the sqw object
%
%
% Output:
% -------
%   wout            Input sqw object with the instrument and sample fields
%                  replaced in the header


wout = set_sample (win, sample);
wout = set_instrument (wout, varargin{:});
