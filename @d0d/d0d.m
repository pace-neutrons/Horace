function w = d0d (varargin)
% Create a 0D dataset
%
% Syntax:
%   >> w = d0d (u0)         % u0 is offset of origin of dataset,
%
%   >> w = d0d (lattice, u0)% Give lattice parameters (a,b,c,alf,bet,gam)
%
%   >> w = d0d (din)        % din is a structure with valid fields for the dataset
%
% Input parameters in more detail:
% ----------------------------------
%   u0      Vector of form [h0,k0,l0] or [h0,k0,l0,en0]
%          that defines an origin point on the manifold of the dataset.
%          If en0 omitted, then assumed to be zero.
%
% *OR*
%   din     Input structure with necessary fields to create a 0D dataset.
%          Type >> help dnd_checkfields for a full description of the fields
%
% Output:
% -------
%   w       A 0D dataset class with precisely the same fields

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

ndim_req = 0;
class_type = 'd0d';
superiorto('spectrum');

if nargin==0    % make default dataset of requisite dimension
    w = class(dnd_makefields(ndim_req),class_type);
    return
else
    if nargin==1 && strcmp(class(varargin{1}),class_type)
        w = din;
    elseif nargin==1 && isstruct(varargin{1})
        [ndim, mess] = dnd_checkfields(din);
        if ~isempty(ndim)
            if ndim==ndim_req
                w = class (din, class_type);
            else
                error (['ERROR: Fields correspond to ',num2str(ndim),'-dimensional dataset'])
            end
        else
            error (mess)
        end
    else
        [d,mess] = dnd_makefields(ndim_req,varargin{:});
        if ~isempty(d)
            w = class(d,class_type);
        else
            error(mess)
        end
    end
end
