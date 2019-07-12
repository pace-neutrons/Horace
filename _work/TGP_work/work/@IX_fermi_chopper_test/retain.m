function ok = retain (obj, t)
% Retain time samples from a fermi chopper pulse shape after rejection
%
%   >> ok = retain (obj, t)
%
% Uses rejection ratio from the probability distribution with repect to a 
% uniform distribution
%
% Input:
% ------
%   obj     IX_fermi_chopper object
%   t       Array of times (microseconds)
%
% Output:
% -------
%   ok      Logical array with the same size as t; true if the
%           corresponding point is retained, false if rejected

if ~isscalar(obj), error('Method only takes a scalar object'), end
ok = retain (pdf_table(obj), t);
