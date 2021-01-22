function [d, mess] = make_sqw (varargin)
% Create a structure for an sqw object
%
%   >> [d,message] = make_sqw (dnd_type,u0,u1,p1,u2,p2,...,un,pn)
%   >> [d,message] = make_sqw (dnd_type,u0,u1,p1,u2,p2,...,un-1,pn-1,pn)
%   >> [d,message] = make_sqw (dnd_type,lattice,...)
%   >> [d,message] = make_sqw (dnd_type,ndim)
%   >> [d,message] = make_sqw (dnd_type,din)
%
% Input:
% ------
%   dnd_type Type of sqw object required
%               =false   Enforce full sqw-type data structure
%               =true    Enforce dnd-type data structure
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
%           A check should always be performed by a subsequent call to check_sqw.
%
%
%   mess    ='' if valid output structure; set to error message if not.


mess='';
fields = {'main_header';'header';'detpar';'data'};  % column

dnd_type=varargin{1};
if nargin==2 && (isstruct(varargin{2}))
    if ~dnd_type
        if isequal(fieldnames(varargin{2}),fields)    % sqw-type top level fields
            d=varargin{2};
            if ~isa(d.data,'data_sqw_dnd')
                d.data = data_sqw_dnd(d.data);
            end
        else
            d=struct([]);   % there was a problem-
            mess='Fields of structure not compatible with sqw type structure';
        end
    elseif dnd_type  % try to interpret as dnd type
        d.main_header=make_sqw_main_header;
        d.header=make_sqw_header;
        d.detpar=make_sqw_detpar;
        if isequal(fieldnames(varargin{2}),fields)    % sqw-type top level fields, so interpret as wanting to make dnd from sqw structure
            d.data=varargin{2}.data;
        else
            if isa(varargin{2},'data_sqw_dnd')
                d.data=varargin{2};
            else
                d.data=clear_sqw_data(data_sqw_dnd(varargin{2}));
            end
        end
        % In case structure is not actually a true sqw-type structure, don't fail if fields img_range and pix do not exist
        %if isfield(d.data,'img_range'), d.data=rmfield(d.data,'img_range'); end
        %if isfield(d.data,'pix'), d.data=rmfield(d.data,'pix'); end
    end
else
    d.main_header=make_sqw_main_header;
    d.header=make_sqw_header;
    d.detpar=make_sqw_detpar;
    d.data=data_sqw_dnd(varargin{2:end});
end
