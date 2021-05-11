function wout=rebin_horace_1d(win,varargin)

% Rebin d1d (or sqw of dnd-type) data.
%
% wout=rebin_horace_1d(win,[lo,step,hi]) - rebin data between lo and hi
% with specified bin width. Data outside range lo->hi are discarded.
%
% wout=rebin_horace_1d(win,step) - rebin all data with specified bin width
%
% wout=rebin_horace_1d(win,w2) - rebin data in win with the bin boundaries
% of w2. The x-axis of w2 must be parallel to the x-axis of win.
%
% RAE 21/1/10
%


[ndims,~]=dimensions(win);

if ndims~=1
    error('HORACE:rebin_horace_1d:invalid_argument', 'Rebinning currently only implemented for d1d, d2d, and sqw objects');
end

if nargin==2
    if isa(win,'d1d') && (isa(varargin{1},'d1d') || isa(varargin{1},'sqw'))
        [ndims2,~]=dimensions(varargin{1});
        if ndims2~=1
            error('HORACE:rebin_horace_1d:invalid_argument', 'Can only rebin a d1d object with another d1d or a 1-dimensional sqw');
        end
        route=1;
    elseif isvector(varargin{1})
        if numel(varargin{1})==1
            route=2;%rebin x with only bin width specified
        elseif numel(varargin{1})==3
            route=3;%rebin x with bin width and range specified.
        else
            error('HORACE:rebin_horace_1d:invalid_argument', 'Check the format of input arguments');
        end
    else
        error('HORACE:rebin_horace_1d:invalid_argument', 'Check the format of input arguments');
    end
else
    error('HORACE:rebin_horace_1d:invalid_argument', 'Check the format of input arguments');
end

%Extract useful parameters from the input dataset:
xin_vec=win.data_.p{1};
inmin_x=min(xin_vec);
inmax_x=max(xin_vec);

% xout is populated in each branch of the switch
xout = [];

%Now alter inputs such that the generic routine can deal with them. This
%depends on what route we are taking...
switch route
    case 1
        %
        w2 = d1d(varargin{1}); %if varargin{1} is already d1d then this does nothing.
        %If it is an sqw then we convert to the equivalent d1d;
        [ok,same_axes,mess]=check_rebinning_axes_1d(win, w2);
        if ~ok
            error(mess);
        end
        %
        if same_axes
            %
            if isequal(win.data_.u_to_rlu(:, win.data_.pax(1)), w2.data_.u_to_rlu(:, w2.data_.pax(1)))
                xout=w2.p{1};
                %Now check that the output range fully encompasses the input data.
                outmin_x=min(xout);
                outmax_x=max(xout);
                outbin_x=xout(2)-xout(1);
                lo_x=min([inmin_x outmin_x]); hi_x=max([inmax_x outmax_x]);
                xout=[(lo_x-outbin_x+eps):outbin_x:(hi_x+outbin_x-eps)]';
            else
                error('HORACE:rebin_horace_1d:array_mismatch', '1d objects must have the same x-axis');
            end
        else
            error('HORACE:rebin_horace_1d:array_mismatch', '1d objects must have same x-axis projection');


        end
    case 2
        xout=[(inmin_x-varargin{1}+eps):varargin{1}:(inmax_x+varargin{1}-eps)]';
        %Need to check that this does cover full range, i.e. no rounding error
        if max(xout)<inmax_x
            xout=[xout; xout(end)+varargin{1}];
        end
    case 3
        xout=[(varargin{1}(1)-varargin{1}(2)-eps):varargin{1}(2):(varargin{1}(3)+varargin{1}(2)-eps)]';
end

% Build the return d1d object
[sout, eout, nout]=rebin_1d_general(xin_vec, xout, win.data_.s, win.data_.e, win.data_.npix);
wout=d1d(win);
wout.data_.p{1}=xout(:,1);
wout.data_.s=sout;
wout.data_.e=eout;
wout.data_.npix=nout;
wout.data_.title=[wout.data_.title,' REBINNED '];

end

