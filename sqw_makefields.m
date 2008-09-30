function [d, mess] = sqw_makefields (varargin)
% Create a structure for an sqw object
%
%   >> [d,message] = sqw_makefields (u0,u1,p1,u2,p2,...,un,pn)
%   >> [d,message] = sqw_makefields (u0,u1,p1,u2,p2,...,un-1,pn-1,pn)
%   >> [d,message] = sqw_makefields (lattice,u0,...)
%   >> [d,message] = sqw_makefields (ndim)
%   >> [d,message] = sqw_makefields (din)
%
% Input:
% ------
%   u0      Vector of form [h0,k0,l0] or [h0,k0,l0,en0]
%          that defines an origin point on the manifold of the dataset.
%          If en0 omitted, then assumed to be zero.
%   u1      Vector [h1,k1,l1] or [h1,k1,l1,en1] defining a plot axis. Must
%          not mix momentum and energy components e.g. [1,1,2], [0,2,0,0] and
%          [0,0,0,1] are valid; [1,0,0,1] is not.
%   p1      Vector of form [plo,delta_p,phi] that defines limits and step
%          in multiples of u1.
%   u2,p2   For next plot axis
%
%       [If un is omitted, then it is assumed to be [0,0,0,1] i.e. the energy axis]
%
%   lattice Defines crystal lattice: [a,b,c,alpha,beta,gamma]
%
%   ndim    Number of dimensions
%
%   din     Data structure; if does not have the correct top-level fields, then creates
%           a structure with correct top-level fields for an sqw object, and
%           sets d.data = din
%
% Output:
% -------
%   d       Data structure; set to empty structure if error with input.
%           If input not a structure:
%               The output should be a valid sqw data structure. 
%           If input was a structure:
%               The output may not be a valid sqw data structure, as no checks
%              are performed on the input fields.
%
%           A check should always be performed by a subsequent call to sqw_checkfields.
%           
%
%   mess    ='' if valid output structure; set to error message if not.


mess='';
fields = {'main_header';'header';'detpar';'data'};  % column

if nargin==1 && isstruct(varargin{1}) && isequal(fieldnames(varargin{1}),fields)
    d = varargin{1};
else
    d.main_header=sqw_make_main_header;
    d.header=sqw_make_header;
    d.detpar=sqw_make_detpar;
    if nargin==1 && isstruct(varargin{1})
        d.data=varargin{1};
    else
        [d.data,mess]=sqw_make_data(varargin{:});
        if ~isempty(mess)
            d=struct([]);   % there was a problem
            return
        end
    end
end
