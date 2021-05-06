function wout=rebin_horace_2d(win,varargin)
%
% Rebin a d2d (or sqw of d2d-type) object.
%
%
% NOTE THAT THIS ROUTINE IS SLOOOOOOOOOOOOOOOOOW, BECAUSE IT USES A RATHER
% COMPLICATED "SHOELACE" ALGORITHM TO ENSURE THAT REBINNING OF THE
% DATA IS DONE CORRECTLY.
%
% wout = rebin_horace_2d(win,xbin,ybin) - rebin win with binning specified
% by xbin and ybin.
%
% Can have xbin or ybin = [] - no rebinning performed along specified axis
%          xbin or ybin = [wid] - rebin data along specified axis with bins
%          of width wid.
%          xbin or ybin = [lo,wid,hi] - rebin data along specified axis
%          with bins of width wid, retaining only data in the range lo->hi.
%          Data outside the limits specified by lo and hi are discarded.
%
% Alternatively: wout=rebin_horace_2d(win,w2) - rebin win with the bin
% boundaries specified by w2. Note that w2 can have different projection
% axes to w1. e.g. win has x/y of [h,0,0]/[0,k,0], w2 has x/y of
% [h,h,0]/[-k,k,0].
%
% RAE 22/1/10
%

[ndims,sz]=dimensions(win);

if ndims~=2
    error('Horace error: rebinning currently only implemented for d1d, d2d, and sqw objects');
end

if nargin==2
    if isa(win,'d2d') && (isa(varargin{1},'d2d') || isa(varargin{1},'sqw'))
        [ndims2,sz]=dimensions(varargin{1});
        if ndims2~=2
            error('Horace error: can only rebin a d2d object with another d2d or a 2-dimensional sqw');
        end
        route=1;
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
elseif nargin==3
    %various possibilities
    if isvector(varargin{1}) && isvector(varargin{2})
        if numel(varargin{1})==1 && numel(varargin{2})==1
            route=4;%rebin x and y, with only bin widths specified
        elseif numel(varargin{1})==3 && numel(varargin{2})==3
            route=5;%rebin x and y, with range specified for x and y
        elseif numel(varargin{1})==1 && numel(varargin{2})==3
            route=6;%rebin x and y, with range specified for y but not x
        elseif numel(varargin{1})==3 && numel(varargin{2})==1
            route=7;%rebin x and y with range specified for x but not y
        else
           error('Horace error: check the format of input arguments');
        end
    elseif isempty(varargin{1}) && isvector(varargin{2})
        if numel(varargin{2})==3
            route=8;%rebin y only, with range and width specified
        elseif numel(varargin{2})==1
            route=9;%rebin y only, with just bin width specified
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
xin_vec=win.p{1}; yin_vec=win.p{2};
inmin_x=min(xin_vec); inmin_y=min(yin_vec);
inmax_x=max(xin_vec); inmax_y=max(yin_vec);
[xin,yin]=ndgrid(xin_vec,yin_vec);

%Now alter inputs such that the generic routine can deal with them. This
%depends on what route we are taking...
switch route
    case 1
        %
        w2=d2d(varargin{1});%ensure we have d2d format. If was already d2d then nothing happens,
        %if varargin{1} was sqw then it is converted to d2d.
        [ok,same_axes,mess]=check_rebinning_axes(win,w2);
        if ~ok
            error(mess);
        end
        %
        if same_axes
            %
            if isequal(win.u_to_rlu(:,win.pax(1)),w2.u_to_rlu(:,w2.pax(1)))
                xout=w2.p{1}; yout=w2.p{2};
                %Now check that the output range fully encompasses the input data.
                outmin_x=min(xout); outmin_y=min(yout);
                outmax_x=max(xout); outmax_y=max(yout);
                outbin_x=xout(2)-xout(1); outbin_y=yout(2)-yout(1);
                lo_x=min([inmin_x outmin_x]); hi_x=max([inmax_x outmax_x]);
                lo_y=min([inmin_y outmin_y]); hi_y=max([inmax_y outmax_y]);
                xout=[(lo_x-eps):outbin_x:(hi_x+eps)]';%increase the size of range very slightly
                %to allow for rounding errors.
                yout=[(lo_y-eps):outbin_y:(hi_y+eps)]';
                [xnew,ynew,sout,eout,nout]=rebin_2d(xin,yin,win.s,win.e,win.npix,xout,yout);
                %Now need to construct the output d2d:
                wout=win;
                getout=get(wout);
                getout.p{1}=xnew(:,1); getout.p{2}=ynew(1,:)';
                getout.s=sout; getout.e=eout; getout.npix=nout;
                getout.title=[wout.title,' REBINNED '];
                wout=d2d(getout);
            else
                xout=w2.p{1}; yout=w2.p{2};%the x-axis of win is the y-axis of w2, and vice versa
                %Now check that the output range fully encompasses the input data.
                outmin_x=min(xout); outmin_y=min(yout);
                outmax_x=max(xout); outmax_y=max(yout);
                outbin_x=xout(2)-xout(1); outbin_y=yout(2)-yout(1);
                lo_x=min([inmin_x outmin_x]); hi_x=max([inmax_x outmax_x]);
                lo_y=min([inmin_y outmin_y]); hi_y=max([inmax_y outmax_y]);
                xout=[(lo_x-eps):outbin_x:(hi_x+eps)]';%increase the size of range
                %to allow for rounding errors.
                yout=[(lo_y-eps):outbin_y:(hi_y+eps)]';
                [xnew,ynew,sout,eout,nout]=rebin_2d(yin',xin',win.s',win.e',win.npix',xout,yout);
                %Now must construct the output d2d...
                wout=w2;
                getout=get(wout);
                getout.p{1}=xnew(:,1); getout.p{2}=ynew(1,:)';
                getout.s=sout; getout.e=eout; getout.npix=nout;
                getout.title=[win.title,' REBINNED '];
                wout=d2d(getout);
            end
        else
            %Need to use the shoelace algorithm
            %
            %Subroutine to convert co-ordinates to appropriate form for
            %shoelace rebinning - i.e. convert bin boundaries into bin
            %corners.
            [xin_sh,yin_sh,sin_sh,ein_sh,nin_sh]=convert_bins_for_shoelace(win,w2);
            %
            %Some code needed here to check that x and y of w2 actually
            %include all of the data specified by the boundaries xin_sh and
            %yin_sh. If they do not, then we must create a new object and
            %co-ordinate set that does.
            %
            xinmin=min(min(xin_sh)); xinmax=max(max(xin_sh));
            yinmin=min(min(yin_sh)); yinmax=max(max(yin_sh));
            x2min=min(w2.p{1}); x2max=max(w2.p{1}); x2diff=w2.p{1}(2)-w2.p{1}(1);
            y2min=min(w2.p{2}); y2max=max(w2.p{2}); y2diff=w2.p{2}(2)-w2.p{2}(1);
            %Now some complex steps to determine the required data range.
            %x-range:
            xlonbins=[]; xhinbins=[]; ylonbins=[]; yhinbins=[];
            if xinmin<x2min
                xlodiff=x2min-xinmin;
                xlonbins=ceil(xlodiff./x2diff);%no. of bins required to meet shortfall
            end
            if xinmax>x2max
                xhidiff=xinmax-x2max;
                xhinbins=ceil(xhidiff./x2diff);
            end
            if yinmin<y2min
                ylodiff=y2min-yinmin;
                ylonbins=ceil(ylodiff./y2diff);
            end
            if yinmax>y2max
                yhidiff=yinmax-y2max;
                yhinbins=ceil(yhidiff./y2diff); 
            end
            if isempty(xlonbins) && isempty(xhinbins)
                xnew=w2.p{1}';
            elseif ~isempty(xlonbins) && isempty(xhinbins)
                xnew=[(x2min-(xlonbins.*x2diff)):x2diff:x2max];
            elseif isempty(xlonbins) && ~isempty(xhinbins)
                xnew=[x2min:x2diff:(x2max+(xhinbins.*x2diff))];
            else
                xnew=[(x2min-(xlonbins.*x2diff)):x2diff:(x2max+(xhinbins.*x2diff))];
            end
            if isempty(ylonbins) && isempty(yhinbins)
                ynew=w2.p{2}';
            elseif ~isempty(ylonbins) && isempty(yhinbins)
                ynew=[(y2min-(ylonbins.*y2diff)):y2diff:y2max];
            elseif isempty(ylonbins) && ~isempty(yhinbins)
                ynew=[y2min:y2diff:(y2max+(yhinbins.*y2diff))];
            else
                ynew=[(y2min-(ylonbins.*y2diff)):y2diff:(y2max+(yhinbins.*y2diff))];
            end
            %now make a new object for the rebinning template:
            get3=get(w2);%structure array with correc fields
            get3.p{1}=xnew'; get3.p{2}=ynew';
            get3.s=zeros(length(xnew)-1,length(ynew)-1);
            get3.e=ones(size(get3.s)); get3.npix=ones(size(get3.s));
            w3=d2d(get3);
            %
            [xref_sh,yref_sh,sref_sh,eref_sh,nref_sh]=convert_bins_for_shoelace(w3,[]);
            
            [stmp,etmp,ntmp]=rebin_shoelace(xin_sh,yin_sh,sin_sh,ein_sh,nin_sh,xref_sh,yref_sh);
            %
            %must now convert back to ndgrid format, and put the intensity
            %in the right place.
            %
            %the order of stmp's coords is
            %(x1,y1),(x2,y1),(x3,y1),...,(xn,y1),(x1,y2),(x2,y2),...
            %ndgrid is such that xvals go down cols, yvals go across rows.
            wout=w3;
            getout=get(wout);
            for i=1:(length(w3.p{2})-1)
                sout(:,i)=stmp((1:length(w3.p{1})-1)+(i-1)*(length(w3.p{1})-1));
                eout(:,i)=etmp((1:length(w3.p{1})-1)+(i-1)*(length(w3.p{1})-1));
                nout(:,i)=ntmp((1:length(w3.p{1})-1)+(i-1)*(length(w3.p{1})-1));
            end
            getout.s=sout; getout.e=eout; getout.npix=nout;
            getout.title=[win.title,' REBINNED '];
            wout=d2d(getout);
            
            
        end
    case 2
        xout=[(inmin_x-eps):varargin{1}:(inmax_x+eps)]';
        %Need to check that this does cover full range, i.e. no rounding
        %errors.
        if max(xout)<inmax_x
            xout=[xout; xout(end)+varargin{1}];
        end
        %
        [xnew,ynew,sout,eout,nout]=rebin_2d(xin,yin,win.s,win.e,win.npix,xout,[]);
        wout=win;
        getout=get(wout);
        getout.p{1}=xnew(:,1);
        getout.s=sout; getout.e=eout; getout.npix=nout;
        getout.title=[wout.title,' REBINNED '];
        wout=d2d(getout);
    case 3
        xout=[(varargin{1}(1) - eps):varargin{1}(2):(varargin{1}(3)+eps)];
        [xnew,ynew,sout,eout,nout]=rebin_2d(xin,yin,win.s,win.e,win.npix,xout,[]);
        wout=win;
        getout=get(wout);
        getout.p{1}=xnew(:,1);
        getout.s=sout; getout.e=eout; getout.npix=nout;
        getout.title=[wout.title,' REBINNED '];
        wout=d2d(getout);
    case 4
        xout=[(inmin_x-eps):varargin{1}:(inmax_x+eps)]';
        yout=[(inmin_y-eps):varargin{2}:(inmax_y+eps)]';
        %Need to check that this does cover full range, i.e. no rounding
        %errors.
        if max(xout)<inmax_x
            xout=[xout; xout(end)+varargin{1}];
        end
        if max(yout)<inmax_y
            yout=[yout; yout(end)+varargin{2}];
        end
        [xnew,ynew,sout,eout,nout]=rebin_2d(xin,yin,win.s,win.e,win.npix,xout,yout);
        wout=win;
        getout=get(wout);
        getout.p{1}=xnew(:,1); getout.p{2}=ynew(1,:)';
        getout.s=sout; getout.e=eout; getout.npix=nout;
        getout.title=[wout.title,' REBINNED '];
        wout=d2d(getout);
    case 5
        xout=[(varargin{1}(1) -eps):varargin{1}(2):(varargin{1}(3)+eps)];
        yout=[(varargin{2}(1)-eps):varargin{2}(2):(varargin{2}(3)+eps)];
        [xnew,ynew,sout,eout,nout]=rebin_2d(xin,yin,win.s,win.e,win.npix,xout,yout);
        wout=win;
        getout=get(wout);
        getout.p{1}=xnew(:,1); getout.p{2}=ynew(1,:)';
        getout.s=sout; getout.e=eout; getout.npix=nout;
        getout.title=[wout.title,' REBINNED '];
        wout=d2d(getout);
    case 6
        yout=[(varargin{2}(1)-eps):varargin{2}(2):(varargin{2}(3)+eps)];
        xout=[(inmin_x-eps):varargin{1}:(inmax_x+eps)]';
        if max(xout)<inmax_x
            xout=[xout; xout(end)+varargin{1}];
        end
        [xnew,ynew,sout,eout,nout]=rebin_2d(xin,yin,win.s,win.e,win.npix,xout,yout);
        wout=win;
        getout=get(wout);
        getout.p{1}=xnew(:,1); getout.p{2}=ynew(1,:)';
        getout.s=sout; getout.e=eout; getout.npix=nout;
        getout.title=[wout.title,' REBINNED '];
        wout=d2d(getout);
    case 7
        xout=[(varargin{1}(1) -eps):varargin{1}(2):(varargin{1}(3)+eps)];
        yout=[(inmin_y-eps):varargin{2}:(inmax_y+eps)]';
        if max(yout)<inmax_y
            yout=[yout; yout(end)+varargin{2}];
        end
        [xnew,ynew,sout,eout,nout]=rebin_2d(xin,yin,win.s,win.e,win.npix,xout,yout);
        wout=win;
        getout=get(wout);
        getout.p{1}=xnew(:,1); getout.p{2}=ynew(1,:)';
        getout.s=sout; getout.e=eout; getout.npix=nout;
        getout.title=[wout.title,' REBINNED '];
        wout=d2d(getout);
    case 8
        yout=[(varargin{2}(1)-eps):varargin{2}(2):(varargin{2}(3)+eps)];
        [xnew,ynew,sout,eout,nout]=rebin_2d(xin,yin,win.s,win.e,win.npix,[],yout);
        wout=win;
        getout=get(wout);
        getout.p{2}=ynew(1,:)';
        getout.s=sout; getout.e=eout; getout.npix=nout;
        getout.title=[wout.title,' REBINNED '];
        wout=d2d(getout);
    case 9
        yout=[(inmin_y-eps):varargin{2}:(inmax_y+eps)]';
        %Need to check that this does cover full range, i.e. no rounding
        %errors.
        if max(yout)<inmax_y
            yout=[yout; yout(end)+varargin{2}];
        end
        [xnew,ynew,sout,eout,nout]=rebin_2d(xin,yin,win.s,win.e,win.npix,[],yout);
        wout=win;
        getout=get(wout);
        getout.p{2}=ynew(1,:)';
        getout.s=sout; getout.e=eout; getout.npix=nout;
        getout.title=[wout.title,' REBINNED '];
        wout=d2d(getout);
end

