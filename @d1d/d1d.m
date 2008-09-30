function w = d1d (varargin)
% Create a 1D Horace dataset ('d1d')
%
% Syntax:
%   >> w = d1d (filename)       % Create object from a file
%
%   >> w = d1d (din)            % Create from a structure with valid fields
%                               % Structure array will output an array of objects
%
% Or:
%   >> w = d1d (u0,u1,p1)       % u0 is offset of origin of dataset,
%                                 u1 vector that defines projection axis in rlu,
%                                 p1 gives start,step and finish for the axis
%   >> w = d1d (u0,p1)          % As above, but assumes that the missing axis is energy
%   >> w = d1d (lattice, u0,...)% Give lattice parameters (a,b,c,alf,bet,gam)
%
% Input parameters in more detail:
% ----------------------------------
%   u0      Vector of form [h0,k0,l0] or [h0,k0,l0,en0]
%          that defines an origin point on the manifold of the dataset.
%          If en0 omitted, then assumed to be zero.
%   u1      Vector [h1,k1,l1] or [h1,k1,l1,en1] defining a plot axis. Must
%          not mix momentum and energy components e.g. [1,1,2], [0,2,0,0] and
%          [0,0,0,1] are valid; [1,0,0,1] is not.
%           If u1 is omitted, then it is assumed to be [0,0,0,1] i.e. the
%          energy axis.
%
%   lattice Defines crystal lattice: [a,b,c,alpha,beta,gamma]

% Original author: T.G.Perring
%
% $Revision: 126 $ ($Date: 2007-02-28 13:37:17 +0000 (Wed, 28 Feb 2007) $)

ndim_request = 1;
class_type = 'd1d';
inferiorto('sqw');

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargin==1 && isa(varargin{1},class_type)     % already object of class
    w = varargin{1};
    return
end

if nargin==0
    w = sqw(ndim_request); % default constructor
else
    w = sqw(varargin{:});
    if dimensions(w)~=ndim_request
        error(['Input arguments inconsistent with requested dimensionality ',num2str(ndim_request)])
    end
end

w=class(w.data,class_type);
