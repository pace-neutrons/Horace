function [proj, pbin, opt,args] = process_and_validate_cut_inputs(obj,ndims, return_cut, varargin)
% Take cut parameters in any possible form (see below)
% and return the standard form of the parameters.
% Inputs:
% ndims      -- number of dimensions in the input data object to cut
%
% return_cut -- if true, cut should be returned as requested, if false, cut
%               would be written to file
%
% varargin   -- any of the following:
%   >> {data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin}
%
%   >> {..., '-nopix'}      % output cut is dnd structure (i.e. no
%                                   % pixel information is retained)
%
%   >>{...,  filename}  % save cut to named file
%
% where:
% ------
%   data_source     Data source: sqw file name or sqw-type object
%                  Can also be a cell array of file names or an array of
%                  sqw objects.
%
%   proj           Data structure containing details of the requested projection
%                  or the structure, which defines projection
%
%   p1_bin          Binning along first Q axis
%   p2_bin          Binning along second Q axis
%   p3_bin          Binning along third Q axis
%   p4_bin          Binning along the energy axis:
%   with any of the following formats:
%           - [] or ''          Plot axis: use bin boundaries of input data
%           - [pstep]           Plot axis: sets step size; plot limits
%                               taken from the extent of the data. If pstep
%                               is 0, step is also taken from input data
%                               (equivalent to [])
%           - [plo, phi]        Integration axis: range of integration
%           - [plo, pstep, phi] Plot axis: minimum and maximum bin centers
%                              and step size
%                              For example, [106, 4, 116] will define a plot
%                              axis with bin edges 104-108, 108-112, 112-116.
%                              if step is 0,                                
%           - [plo, rdiff, phi, rwidth]
%                                Integration axis: minimum range center,
%                                distance between range centers, maximum range
%                                center, range size for each cut.
%                                When using this syntax, an array of cuts is
%                                outputted. The number of cuts produced will
%                                be the number of rdiff sized steps between plo
%                                and phi; phi will be automatically increased
%                                such that rdiff divides phi - plo.
%                                For example, [106, 4, 113, 2] defines the
%                                integration range for three cuts, the first
%                                cut integrates the axis over 105-107, the
%                                second over 109-111 and the third 113-115.
%   args            Cell array of any other arguments not related to main
%                   binning

[~, proj, pbin, opt, args] = cut_sqw_parse_inputs_(obj, ...
 ndims, return_cut, varargin{:});


