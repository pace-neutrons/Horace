function w = d3d (varargin)
% Create a 3D Horace dataset ('d3d')
%
% Syntax:
%   >> w = d3d (filename)       % Create object from a file
%
%   >> w = d3d (din)            % Create from a structure with valid fields
%                               % Structure array will output an array of objects
%
% Or:
%   >> w = d3d (u1,p1,u2,p2,u3,p3)
%                               % u1,u2,u3 vectors define projection axes in rlu,
%                                 p1,p2,p3 give start,step and finish for the axes
%   >> w = d3d (u0,...)         % u0 is offset of origin of dataset,
%   >> w = d3d (lattice,...)    % Give lattice parameters [a,b,c,alf,bet,gam]
%   >> w = d3d (lattice,u0,...) % Give u0 and lattice parameters
%
% Input parameters in more detail:
% ----------------------------------
%   lattice Defines crystal lattice: [a,b,c,alpha,beta,gamma]
%   u0      Vector of form [h0,k0,l0] or [h0,k0,l0,en0]
%          that defines an origin point on the manifold of the dataset.
%          If en0 omitted, then assumed to be zero.
%   u1      Vector [h1,k1,l1] or [h1,k1,l1,en1] defining a plot axis. Must
%          not mix momentum and energy components e.g. [1,1,2], [0,2,0,0] and
%          [0,0,0,1] are valid; [1,0,0,1] is not.
%   p1      Vector of form [plo,delta_p,phi] that defines limits and step
%          in multiples of u1.
%   u2,p2   For second plot axis
%   u3,p3   For third plot axis


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


ndim_request = 3;
class_type = 'd3d';
inferiorto('sqw');

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargin==1 && isa(varargin{1},class_type)     % already object of class
    w = varargin{1};
    return
end

if nargin==0
    w = sqw('$dnd',ndim_request); % default constructor
else
    w = sqw('$dnd',varargin{:});
    if dimensions(w)~=ndim_request
        error(['Input arguments inconsistent with requested dimensionality ',num2str(ndim_request)])
    end
end

w=class(w.data,class_type);
