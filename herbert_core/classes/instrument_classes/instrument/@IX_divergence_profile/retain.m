function ok = retain (obj, angles)
% Retain angle samples from a divergence profile after rejection
%
%   >> ok = retain (obj, angles)
%
% Uses rejection ratio from the probability distribution with repect to a 
% uniform distribution
%
% Input:
% ------
%   obj     IX_divergence_profile object
%   angles  Array of angles (radians)
%
% Output:
% -------
%   ok      Logical array with the same size as angles; true if the
%           corresponding point is retained, false if rejected


if ~isscalar(obj), error('Method only takes a scalar object'), end
ok = retain (pdf_table(obj), angles);
