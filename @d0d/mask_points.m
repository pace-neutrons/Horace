function [sel,ok,mess] = mask_points (win, varargin)
% Determine the points to keep on the basis of ranges and mask array.
% Does NOT find array elements with zero error bars, NaN data values etc. This is
% a job to be performed inside the generic fit routine.
%
% Syntax:
%   >> sel = mask_points (win, 'keep', xkeep, 'xremove', xremove, 'mask', mask)
%
% or any selection (in any order) of the keyword-argument pairs e.g.
%   >> sel = mask_points (win, 'mask', mask, 'xremove', xremove)
%
% Input:
% ------
%   win     Input sqw object
%
%   xkeep   Ranges of display axes to retain for fitting. A range is specified by an array
%           of numbers which define a hypercube.
%           For example in case of two dimensions:
%               [xlo, xhi, ylo, yhi]  
%           or in the case of n-dimensions:
%               [x1_lo, x1_hi, x2_lo, x2_hi,..., xn_lo, xn_hi]
%
%              e.g. 1D: [50,70]
%                   2D: [1,2,130,160]
%
%           More than one range can be defined in rows,
%               [Range_1; Range_2; Range_3;...; Range_m]
%             where each of the ranges are given in the format above.
%
%   xremove Ranges of display axes to remove from fitting.
%
%   mask    Mask array of same number of elements as data array: 1 to keep, 0 to remove
%               Note: mask will be applied to the stored data array
%              according as the projection axes, not the display axes.
%              Thus permuting the display axes does not alter the
%              effect of masking the data. The mask array works
%              consistently with the input required by the mask method.
%
% Output:
% -------
%   sel     Mask array of same shape as data. true for bins to keep, false to discard.
%
% 
%  Advanced use: in addition the following two arguments, if present, suppress failure or the
%  display of informational messges. Instead, the messages are returned to be used as desired.
%
%   ok      =true if worked, =false if error
%
%   mess    messages: if ok=true then informational or warning, if ok=false then the error message
                                                         

% Original author: T.G.Perring
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

[sel,ok,mess] = mask_points (sqw(win), varargin{:});
