function w = sqw (varargin)
% Create an sqw object
%
% Syntax:
%   >> w = sqw (filename)       % Create an sqw object from a file
%   >> w = sqw (din)            % Create from a structure with valid fields
%                               % Structure array will output an array of sqw objects

% For private use by d0d/d0d d0d/sqw,...d4d/d4d d4d/sqw
%   >> w = sqw ('$dnd',filename)% Create an sqw object from a file
%   >> w = sqw ('$dnd',din)     % Create from a structure with valid fields
%                               % Structure array will output an array of sqw objects
%   >> w = sqw ('$dnd',u0,u1,p1,u2,p2,...,un,pn)
%   >> w = sqw ('$dnd',u0,u1,p1,u2,p2,...,un-1,pn-1,pn)
%   >> w = sqw ('$dnd',lattice,u0,...)
%   >> w = sqw ('$dnd',ndim)
%
% Will enforce dnd-type sqw object.
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
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)

class_type = 'sqw';
superiorto('d0d','d1d','d2d','d3d','d4d');  % other Horace classes


% Will normally insist that we definitely require sqw-type object unless we explicitly demand
% an dnd-type object. There are two special cases however
% - default constructor with no input arguments (for repmat to work, for example)
%      return default dnd-type object as do not want overhead of making a valid sqw-type object
% - if already sqw object of either sqw or dnd type, just act as a dummy method

%  Must have default constructor with no input arguments (for repmat to work, for example)
if nargin==0
    w = make_sqw (true, 0);         % basic dnd-type sqw data structure
    [ok,mess,type,w]=check_sqw(w);  % Make check_sqw the ultimate arbiter of the validity of a structure
    if ok
        w = class(w,class_type);
        return
    else
        error(mess)
    end
end

% If already sqw object, then return
if nargin==1 && isa(varargin{1},class_type)     % already sqw object
    w=varargin{1};
    return
end


% Determine whether enforce sqw-type object or enforce dnd-type sqw object
if nargin>=1 && ischar(varargin{1}) && strcmpi(varargin{1},'$dnd')
    dnd_type=true;
    args=varargin(2:end);
elseif nargin>=1 && ischar(varargin{1}) && strcmpi(varargin{1},'$sqw')
    dnd_type=false;
    args=varargin(2:end);
elseif nargin==1 && isa(varargin{1},'data_sqw_dnd')
    dnd_type=varargin{1}.dnd_type;
    args=varargin;
else
    dnd_type=false;
    args=varargin;
end
narg=numel(args);


% Branch on input
if narg==1 &&( isstruct(args{1}) || isa(args{1},'data_sqw_dnd'))
    % structure input:
    % ----------------
    sz=size(args{1});
    for i=1:numel(args{1})
        [d,mess] = make_sqw (dnd_type, args{1}(i));
        if ~isempty(mess)
            if ~isscalar(args{1})
                error([mess,'\n structure array element %s'],str_compress(num2str(ind2sub(sz,i))))
            else
                error(mess)
            end
        end
        [ok,mess,type,d] = check_sqw(d);
        if ok
            if i==1
                w=class(d,class_type);
                if numel(args{1})>1
                    w=repmat(w,sz);
                end
            else
                w(ind2sub(sz,i))=class(args{1}(i),class_type);
            end
        else
            if ~isscalar(args{1})
                error([mess,'\n structure array element %s'],str_compress(num2str(ind2sub(sz,i))))
            else
                error(mess)
            end
        end
    end
    return
    
elseif narg==1 && ischar(args{1}) && length(size(args{1}))==2 && size(args{1},1)==1
    % filename: is a single row of characters
    % ----------------------------------------
    ldr = sqw_formats_factory.instance().get_loader(args{1});
    if ~dnd_type    % insist on sqw type
        if ~strcmpi(ldr.data_type,'a')   % not a valid sqw-type structure
            error('Data file does not contain valid sqw-type object')
        end
        
        w=struct();
        [w.main_header,w.header,w.detpar,w.data] = ldr.get_sqw('-legacy');
    else            % insist on dnd type
        if ~(strcmpi(ldr.data_type,'a')||strcmpi(ldr.data_type,'b+'))   % not a valid sqw or dnd structure
            error('Data file does not contain valid dnd-type object')
        end
        
        w.main_header=make_sqw_main_header;
        w.header=make_sqw_header;
        w.detpar=make_sqw_detpar;
        w.data = ldr.get_data('-nopix');
        if isa(w.data,'data_sqw_dnd')
            w.data = clear_sqw_data(w.data);
        end
    end
    [ok,mess,type,w]=check_sqw(w);   % Make check_sqw the ultimate arbiter of the validity of a structure
    if ok
        w = class(w,class_type);
        return
    else
        error(mess)
    end
    
else
    % All other cases - use as input to a bare constructor
    % ----------------------------------------------------
    [w, mess] = make_sqw (dnd_type, args{:});
    if isempty(mess)
        [ok,mess,type,w]=check_sqw(w);   % Make check_sqw the ultimate arbiter of the validity of a structure
        if ok
            w = class(w,class_type);
            return
        else
            error(mess)
        end
    else
        error(mess)
    end
    
end

