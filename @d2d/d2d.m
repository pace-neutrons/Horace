function w = d2d (varargin)
% Create a 2D dataset
%
% Syntax:
%   >> w = d2d (u0,u1,p1,u2,p2) % u0 is offset of origin of dataset,
%                                 u1,u2 vectors define projection axes in rlu,
%                                 p1,p2 give start,step and finish for the two axes
%
%   >> w = d2d (u0,u1,p1,p2)    % As above, but assumes that the missing axis is energy
%
%   >> w = d2d (lattice, u0,...)% Give lattice parameters (a,b,c,alf,bet,gam)
%
%   >> w = d2d (din)            % din is a structure with valid fields for the dataset
%
% Input parameters in more detail:
% ----------------------------------
%   u0      Vector of form [h0,k0,l0] or [h0,k0,l0,en0]
%          that defines an origin point on the manifold of the dataset.
%          If en0 omitted, then assumed to be zero.
%   u1      Vector [h1,k1,l1] or [h1,k1,l1,en1] defining a plot axis. Must
%          not mix momentum and energy components e.g. [1,1,2], [0,2,0,0] and
%          [0,0,0,1] are valid; [1,0,0,1] is not.
%   p1      Vector of form [plo,delta_p,phi] that defines limits and step
%          in multiples of u1.
%   u2,p2   For second plot axis; if u2 is omitted, then it is assumed to
%          be [0,0,0,1] i.e. the energy axis.
%
% *OR*
%   din     Input structure with necessary fields to create a 2D dataset.
%          Type >> help dnd_checkfields for a full description of the fields
%
% Output:
% -------
%   w       A 2D dataset class with precisely the same fields

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

ndim_req = 2;
class_type = 'd2d';
superiorto('spectrum');

if nargin==0    % make default dataset of requisite dimension
    w = class(dnd_makefields(ndim_req),class_type);
    return
else
    if nargin==1 && strcmp(class(varargin{1}),class_type)
        w = varargin{1};
    elseif nargin==1 && isstruct(varargin{1})
        [ndim, mess] = dnd_checkfields(varargin{1});
        if ~isempty(ndim)
            if ndim==ndim_req
                w = class (varargin{1}, class_type);
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
