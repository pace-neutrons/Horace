function w = sqw (varargin)
% Create an sqw object
%
% Syntax:
%   >> w = sqw (filename)       % Create an sqw object from a file
%
%   >> w = sqw (din)            % Create from a structure with valid fields
%                               % Structure array will output an array of sqw objects
%
% Or:
%   >> w = sqw (u0,u1,p1,u2,p2,...,un,pn)
%   >> w = sqw (u0,u1,p1,u2,p2,...,un-1,pn-1,pn)
%   >> w = sqw (lattice,u0,...)
%   >> w = sqw (ndim)
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
%   u2,p2   For next plot axis etc.
%           If un is omitted, it is assumed to be [0,0,0,1] i.e. the energy axis]
%
%   lattice Defines crystal lattice: [a,b,c,alpha,beta,gamma]
%
%   ndim    Number of dimensions

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

class_type = 'sqw';
superiorto('d0d','d1d','d2d','d3d','d4d');  % other Horace classes
% superiorto('spectrum','tofspectrum');      % mgenie classes
% superiorto('IXTdataset_1d','IXTdataset_2d') % Libisis classes


%  Must have default constructor with no input arguments (for repmat to work, for example)
if nargin==0
    w = sqw_makefields(0);
    [ok,mess,type,w]=sqw_checkfields(w);   % Make sqw_checkfields the ultimate arbiter of the validity of a structure
    if ok
        w = class(w,class_type);
        return
    else
        error(mess)
    end
end


% Case of filename or structure
if nargin==1
    if isa(varargin{1},class_type)    % already sqw object
        w=varargin{1};
        return
        
    elseif ischar(varargin{1}) && length(size(varargin{1}))==2 && size(varargin{1},1)==1    % is a single row of characters
        [main_header,header,detpar,data,mess,position,npixtot,type] = sqw_get (varargin{1});
        if ~isempty(mess)   % there is an error
            error(mess)
        elseif ~(strcmpi(type,'a')||strcmpi(type,'b+'))   % not a valid sqw structure
            error('Data file does not contain valid sqw object')
        end
        w.main_header=main_header;
        w.header=header;
        w.detpar=detpar;
        w.data=data;
        w = class(w,class_type);
        return

    elseif isstruct(varargin{1})
        sz=size(varargin{1});
        for i=1:numel(varargin{1})
            d = sqw_makefields(varargin{1}(i));
            [ok,mess,type,d] = sqw_checkfields(d);
            if ok
                if i==1
                    w=class(d,class_type);
                    if numel(varargin{1})>1
                        w=repmat(w,sz);
                    end
                else
                    w(ind2sub(sz,i))=class(varargin{1}(i),class_type);
                end
            else
                if ~isscalar(varargin{1})
                    error([mess,'\n structure array element %s'],str_compress(num2str(ind2sub(sz,i))))
                else
                    error(mess)
                end
            end
        end
        return
    end
end

% All other cases
[w, mess] = sqw_makefields (varargin{:});
if isempty(mess)
    [ok,mess,type,w]=sqw_checkfields(w);   % Make sqw_checkfields the ultimate arbiter of the validity of a structure
    if ok
        w = class(w,class_type);
        return
    else
        error(mess)
    end
else
    error(mess)
end
