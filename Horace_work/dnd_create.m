function wout = dnd_create(data)
% Create a 0,1,2,3 or 4 dimensional dataset object from an input data structure
%
%   >> wout = dnd_create(data)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring


if isfield(data,'pax')
    ndim=length(data.pax);
    if ndim==0
        wout = d0d(data);
    elseif ndim==1
        wout = d1d(data);
    elseif ndim==2
        wout = d2d(data);
    elseif ndim==3
        wout = d3d(data);
    elseif ndim==4
        wout = d4d(data);
    else
        error ('ERROR: Data structure must have fields of a 0,1,2,3 or 4 dimensional dataset object')
    end
else
    error ('ERROR: Data structure must have fields of a 0,1,2,3 or 4 dimensional dataset object')
end
