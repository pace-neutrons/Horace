function wout = replicate (win,wref,varargin)
% Make a higher dimensional dataset from a lower dimensional dataset by
% replicating the data along the extra dimensions of a reference dataset.
%
%   >> wout = replicate (win, wref,varargin)
%
% Input:
% ------
%   win     sqw object or array of sqw objects all with the same dimensionality
%           to be replicated. The signal, error and npix arrays of this
%           object will be replicated over the extra dimensions of the
%           reference dataset and win pixels values are just ignored.
%
%   wref    Reference dataset structure to use as template for expanding the
%           input structure. Can be a dnd or sqw dataset.
%           - The plot axes of win must also be plot axes of wref, and the number
%           of points along these common axes must be the same, although the
%           numerical values of the coordinates need not be the same.
%           - The data is expanded along the plot axes of wref that are
%           integration axes of win.
%           - The annotations etc. are taken from the reference dataset.
% Optional:
% '-set_pix'
%        -- if provided, wref object should be sqw objects with pixels.
%           In this case result would be sqw object(s) with pixels set
%           to reproduce replicated image, defined by dnd part of input sqw
%           object.
%
% Output:
% -------
%   wout    Output dataset object (or array of objects). Depending on wref
%           object type (dnd, pixelles sqw or sqw) it is dnd,dnd or sqw
%           object with the same dimensionality as wref and win image(s)
%           replicated to additional dimensions.
%           If '-set_pix' key is provided it is sqw object (wref must be
%           sqw object with pixels) which also has the same pixels as
%           wref. The pixels signal and error in this case are set to form
%           the replicated image.
%
% Original author: T.G.Perring
%

% Do some tests on win and wref
% -----------------------------
% If came from replicate method of a dnd class, then win will be dnd-type sqw object
% Otherwise, could be any sort of object, so check it is an sqw or dnd object

ndim=dimensions(win(1));
for i=2:numel(win)
    if dimensions(win(i))~=ndim
        error('HORACE:replicate:invalid_argument',...
            'Check first input argument - an array of sqw objects must all have the same dimensionality')
    end
end
[ok,mess,set_pix] = parse_char_options(varargin,'-set_pix');
if ~ok
    error('HORACE:sqw:invalid_argument',mess);
end

% If came from replicate method of a dnd class, then wref will be dnd-type sqw object
% Otherwise, could be any sort of object, so check it is an sqw or dnd object, and convert to dnd-type sqw object
if ~(isscalar(wref) && isa(wref,'SQWDnDBase'))
    error('HORACE:replicate:invalid_argument',...
        'The second argument must be a scalar dnd or sqw object, actually it has %d elements and its type is %s',...
        numel(wref),class(wref));
else
    if isa(wref,'sqw')
        wref_dnd_type = wref.data;
    else
        wref_dnd_type = wref;
    end
end


% Perform replication
% -------------------
if set_pix && wref.has_pixels()
    wout = repmat(wref,size(win));
else
    wout = repmat(wref_dnd_type,size(win));  % wout will be a dnd-type sqw object
end

for i=1:numel(win)
    dnd_obj = dnd(win(i));
    rep_obj = replicate(dnd_obj,wref_dnd_type);
    if set_pix
        if has_pixels(wref)
            wout(i).data.s = rep_obj.s;
            wout(i).data.e = rep_obj.e;
            page_op = PageOp_sigvar_set();
            page_op.in_replicate = true;
            page_op = page_op.init( wout(i));
            wout(i)       = sqw.apply_op( wout(i),page_op);
        else
            if isa(wref,'DnDBase')
                explanation ='sqw_ref_object is a dnd object';
            else
                explanation ='sqw_ref_object is sqw object without pixels';
            end
            warning('HORACE:invalid_argument', ...
                '-set_pix key is provided as input of replicate(sqw_rep,sqw_ref_object,"-set_pix"), but %s', ...
                explanation)
            wout(i) = rep_obj;
        end
    else
        wout(i) = rep_obj;
    end
end
