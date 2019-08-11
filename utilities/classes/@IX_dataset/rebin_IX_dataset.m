function [wout,ok,mess] = rebin_IX_dataset (win, integrate_data, point_integration_default, iax, descriptor_opt, varargin)
% Rebin an IX_dataset object or array of IX_dataset objects along one or more axes
%
%   >> [wout,ok,mess] = rebin_IX_dataset (win, integrate_data, point_integration_default, iax, isdescriptor,...
%                                            range_1, range_2, ..., point_integration)
% OR
%   >> [wout,ok,mess] = rebin_IX_dataset (win, integrate_data, point_integration_default, iax, isdescriptor,...
%                                            wref, point_integration)
%
% Input:
% ------
%   win                 IX_dataset, or array or IX_dataset(s) (n=1,2,3)
%
%   integrate_data      Integrate(true) or rebin (false)
%   point_integration_default   Default averaging method for axes with point data (ignored by any axes with histogram data)
%                         true:  Trapezoidal integration
%                         false: Point averaging
%   iax                 Array of axis indices (chosen from 1,2,3... to a maximum of ndim) to be rebinned or integrated
%                      It is assumed that the input is valid.
%   descriptor_opt      Options that describe the interpretation of rebin/integration intervals. Fields are:
%                               empty_is_full_range     true: [] or '' ==> [-Inf,Inf];
%                                                       false ==> [-Inf,0,Inf]
%                               range_is_one_bin        true: [x1,x2]  ==> one bin
%                                                       false ==> [x1,0,x2]
%                               array_is_descriptor     true:  interpret array of three or more elements as descriptor
%                                                       false: interpet as actual bin boundaries
%                               bin_boundaries          true:  intepret x values as bin boundaries
%                                                       false: interpret as bin centres
%   range_1, range_2    Arrays of rebin/integration intervals, one per rebin/integration axis. Depending on isdescriptor,
%                      there are a number of different formats and defaults that are valid.
%                       If win is one dimensional, then if all the arguments can be scalar they are treated as the
%                      elements of range_1
%         *OR*
%   wref                Reference dataset from which to take bins. Must be a scalar, and the same class as win
%                      Only those axes indicated by input argument iax are taken from the reference object.
%
%   point_integration   Averaging method if point data (if not given, then uses default determined by point_integration_default above)
%                        - character string 'integration' or 'average'
%                        - cell array with number of entries equalling number of rebin/integration axes (i.e. numel(iax))
%                          each entry the character string 'integration' or 'average'
%                       If an axis is a histogram data axis, then its corresponding entry is ignored
%
% Output:
% -------
%   wout                IX_dataset_nd object or array of objects following the rebinning/integration
%
%   ok                  True if no problems, false otherwise
%   mess                Error message; empty if ok

[wout,ok,mess] = rebin_IX_dataset_(win,integrate_data, point_integration_default, iax, descriptor_opt, varargin{:});
