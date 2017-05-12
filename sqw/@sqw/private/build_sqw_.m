function obj = build_sqw_(obj,varargin)
% Internal sqw class constructor


% Original author: T.G.Perring
%
% $Revision: 1358 $ ($Date: 2016-11-23 11:38:32 +0000 (Wed, 23 Nov 2016) $)


% Will normally insist that we definitely require sqw-type object unless we explicitly demand
% an dnd-type object. There are two special cases however
% - default constructor with no input arguments (for repmat to work, for example)
%      return default dnd-type object as do not want overhead of making a valid sqw-type object
% - if already sqw object of either sqw or dnd type, just act as a dummy method


% If already sqw object, then return
if nargin==1 && isa(varargin{1},'sqw')     % already sqw object
    obj=varargin{1};
    return
end




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
%   Detailed explanation goes here


end

