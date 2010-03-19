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


[ndims,sz]=dimensions(win);

if ndims~=1
    error('Horace error: rebinning currently only implemented for d1d, d2d, and sqw objects');
end

if nargin==2
    if (isa(win,'d1d') && isa(varargin{1},'d1d'))
            route=1;%WE MAY WANT TO MAKE THIS TAKE SQW OBJECTS AS W2
    elseif isvector(varargin{1})
        if numel(varargin{1})==1
            route=2;%rebin x with only bin width specified
        elseif numel(varargin{1})==3
            route=3;%rebin x with bin width and range specified.
        else
            error('Horace error: check the format of input arguments');
        end
    else
        error('Horace error: check the format of input arguments');
    end
else
    error('Horace error: check the format of input arguments');
end

%Extract useful parameters from the input dataset:
xin_vec=win.p{1};
inmin_x=min(xin_vec);
inmax_x=max(xin_vec);

%Now alter inputs such that the generic routine can deal with them. This
%depends on what route we are taking...
switch route
    case 1
        %
        w2=varargin{1};
        [ok,same_axes,mess]=check_rebinning_axes_1d(win,w2);
        if ~ok
            error(mess);
        end
        %
        if same_axes
            %
            if isequal(win.u_to_rlu(:,win.pax(1)),w2.u_to_rlu(:,w2.pax(1)))
                xout=w2.p{1};
                %Now check that the output range fully encompasses the input data.
                outmin_x=min(xout);
                outmax_x=max(xout);
                outbin_x=xout(2)-xout(1);
                lo_x=min([inmin_x outmin_x]); hi_x=max([inmax_x outmax_x]);
                xout=[lo_x:outbin_x:hi_x]';
                [sout,eout,nout]=rebin_1d_general(xin_vec,xout,win.s,win.e,win.npix);
                %Now need to construct the output d1d:
                wout=win;
                getout=get(wout);
                getout.p{1}=xout(:,1);
                getout.s=sout; getout.e=eout; getout.npix=nout;
                getout.title=[wout.title,' REBINNED '];
                wout=d1d(getout);
            else
                error('Horace error: 1d objects must have the same x-axis');
            end
        else
            error('Horace error: 1d objects must have same x-axis projection');
            
            
        end
    case 2
        xout=[inmin_x:varargin{1}:inmax_x]';
        %Need to check that this does cover full range, i.e. no rounding
        %erro
        if max(xout)<inmax_x
            xout=[xout; xout(end)+varargin{1}];
        end
        [sout,eout,nout]=rebin_1d_general(xin_vec,xout,win.s,win.e,win.npix);
        wout=win;
        getout=get(wout);
        getout.p{1}=xout(:,1);
        getout.s=sout; getout.e=eout; getout.npix=nout;
        getout.title=[wout.title,' REBINNED '];
        wout=d1d(getout);
    case 3
        xout=[varargin{1}(1):varargin{1}(2):varargin{1}(3)]';
        [sout,eout,nout]=rebin_1d_general(xin_vec,xout,win.s,win.e,win.npix);
        wout=win;
        getout=get(wout);
        getout.p{1}=xout(:,1);
        getout.s=sout; getout.e=eout; getout.npix=nout;
        getout.title=[wout.title,' REBINNED '];
        wout=d1d(getout);
    
end
