function wout=combine_horace_2d(w1,w2,varargin)
%
% Combine two d2d (or sqw of d2d-type) datasets.
%
% NOTE THAT THIS ROUTINE IS SLOOOOOOOOOOOOOOOOOW, BECAUSE IT USES A RATHER
% COMPLICATED "SHOELACE" ALGORITHM TO ENSURE THAT REBINNING OF THE
% COMBINED DATA IS DONE CORRECTLY.
%
% wout = combine(w1,w2)
% Combine the datasets w1 and w2. The bins and projection axes of the
% output object will be the same as those of w1.
%
% wout = combine(w1,w2,[tolx,toly])
% Combine the datasets w1 and w2. The projection axes of the output object
% will be the same as those of w1. The bin widths will be given by tolx and
% toly for x and y-axis respectively. If no change of bin width is required
% then set tol=NaN. e.g. [tolx,toly]=[NaN,0.1] results in no change of bin
% width for x-axis, y-axis bin width changed to 0.1
%
% RAE 22/1/10
% 


[ndims1,sz1]=dimensions(w1);
[ndims2,sz2]=dimensions(w2);

if ndims1~=2 || ndims2~=2
    error('Horace error: ensure both objects have the same dimensionality')   
end

if isa(w1,'sqw') && isa(w2,'sqw')
    if is_sqw_type(sqw(w1)) && is_sqw_type(sqw(w2))
        error('Horace error: d1d method cannot be used for 2 sqw objects with pixel info. Logic flaw');
    end
end

w1=sqw(w1); w2=sqw(w2);%convert to sqw to make the following easier

%First set of cases is where no tolerance is specified
if nargin==2
    route=1;
elseif nargin==3
    tol=varargin{1};
    if ~isnumeric(tol)
        error('Horace error: the combining tolerance should be specified by a scalar');
    elseif numel(tol)~=2
        error('Horace error: the combining tolerance should be specified by a 2-element vector');
    end
    route=2;
else
    error('Horace error: check number and format of input arguments');
end

%==
switch route
    case 1
        [ok,same_axes,mess]=check_rebinning_axes(w1,w2);
        if ~ok
            error(mess);
        end
        %
        if same_axes
            %
            [irange,uoff]=calculate_integration_range(w1,w2);
            %
            if isequal(w1.data.u_to_rlu(:,w1.data.pax(1)),w2.data.u_to_rlu(:,w2.data.pax(1)))
                [x1,y1]=ndgrid(w1.data.p{1},w1.data.p{2});
                [x2,y2]=ndgrid(w2.data.p{1},w2.data.p{2});
                s1=w1.data.s; s2=w2.data.s;
                e1=w1.data.e; e2=w2.data.e;
                n1=w1.data.npix; n2=w2.data.npix;
                [xout,yout,sout,eout,nout]=combine_2d(x1,y1,s1,e1,n1,x2,y2,s2,e2,n2,[]);
                %Now need to construct the output d2d:
                wout=d2d(w1);
                getout=get(wout);
                getout.p{1}=xout(:,1); getout.p{2}=yout(1,:)';
                getout.s=sout; getout.e=eout; getout.npix=nout;
                getout.title=[wout.title,' COMBINED '];
                getout.iint=irange;
                getout.uoffset=uoff;
                wout=d2d(getout);
            else
                %have same axes, but y-axis of w1 is x-axis of w2, and v.v.
                [x1,y1]=ndgrid(w1.data.p{1},w1.data.p{2});
                [x2,y2]=ndgrid(w2.data.p{2},w2.data.p{1});
                s1=w1.data.s; s2=w2.data.s';
                e1=w1.data.e; e2=w2.data.e';
                n1=w1.data.npix; n2=w2.data.npix';
                [xout,yout,sout,eout,nout]=combine_2d(x1,y1,s1,e1,n1,x2,y2,s2,e2,n2,[]);
                %Now need to construct the output d2d:
                wout=d2d(w1);
                getout=get(wout);
                getout.p{1}=xout(:,1); getout.p{2}=yout(1,:)';
                getout.s=sout; getout.e=eout; getout.npix=nout;
                getout.title=[wout.title,' COMBINED '];
                getout.iint=irange;
                getout.uoffset=uoff;
                wout=d2d(getout);
                %
            end
        else
            [irange,uoff]=calculate_integration_range(w1,w2);
            %data plane is the same, but the axes are different. So need
            %shoelace rebin. Require an object that has the data plane of
            %w1, but the full range of both datasets.
            w2tmp=rebin_horace_2d(d2d(w2),d2d(w1));
            w1tmp=rebin_horace_2d(d2d(w1),w2tmp);
            %now have 2 objects that have the same data range
            %can add the signals and errors in the appropriate way.
            s1=w1tmp.s; e1=w1tmp.e; n1=w1tmp.npix;
            s2=w2tmp.s; e2=w2tmp.e; n2=w2tmp.npix;
            e1_old=e1; e2_old=e2;%absolute errors, not fractional.
            e1=e1./s1; e2=e2./s2;
            e1(isnan(e1) | isinf(e1))=0;
            e2(isnan(e2) | isinf(e2))=0;
            biggest=[max(max(s1)) max(max(s2))];
            e1=e1+((e1==0).*1e5.*max(biggest));
            e2=e2+((e2==0).*1e5.*max(biggest));
            sout=(s2./e2 + s1./e1)./(1./e2 + 1./e1);
            eout=1./(1./e2 + 1./e1);
            nout=n1+n2;
            nout(e1_old==0 & e2_old==0)=0;
            sout(e1_old==0 & e2_old==0)=0;
            eout(e1_old==0 & e2_old==0)=0;
            %
            %Convert fractional error back to absolute error:
            eout=eout.*sout;
            wout=w1tmp;
            wout.s=sout; wout.e=eout; wout.npix=nout;
            wout.iint=irange;
            wout.uoffset=uoff;
            wout.title=[w1.data.title, ' COMBINED'];
            
        end
    case 2
        [ok,same_axes,mess]=check_rebinning_axes(w1,w2);
        if ~ok
            error(mess);
        end
        %
        if same_axes
            %
            [irange,uoff]=calculate_integration_range(w1,w2);
            %
            if isequal(w1.data.u_to_rlu(:,w1.data.pax(1)),w2.data.u_to_rlu(:,w2.data.pax(1)))
                [x1,y1]=ndgrid(w1.data.p{1},w1.data.p{2});
                [x2,y2]=ndgrid(w2.data.p{1},w2.data.p{2});
                s1=w1.data.s; s2=w2.data.s;
                e1=w1.data.e; e2=w2.data.e;
                n1=w1.data.npix; n2=w2.data.npix;
                [xout,yout,sout,eout,nout]=combine_2d(x1,y1,s1,e1,n1,x2,y2,s2,e2,n2,tol);
                %Now need to construct the output d2d:
                wout=d2d(w1);
                getout=get(wout);
                getout.p{1}=xout(:,1); getout.p{2}=yout(1,:)';
                getout.s=sout; getout.e=eout; getout.npix=nout;
                getout.title=[wout.title,' COMBINED '];
                getout.iint=irange;
                getout.uoffset=uoff;
                wout=d2d(getout);
            else
                %y-axis of w1 is x-axis of w2, and v.v.
                [x1,y1]=ndgrid(w1.data.p{1},w1.data.p{2});
                [x2,y2]=ndgrid(w2.data.p{2},w2.data.p{1});
                s1=w1.data.s; s2=w2.data.s';
                e1=w1.data.e; e2=w2.data.e';
                n1=w1.data.npix; n2=w2.data.npix';
                [xout,yout,sout,eout,nout]=combine_2d(x1,y1,s1,e1,n1,x2,y2,s2,e2,n2,tol);
                %Now need to construct the output d2d:
                wout=d2d(w1);
                getout=get(wout);
                getout.p{1}=xout(:,1); getout.p{2}=yout(1,:)';
                getout.s=sout; getout.e=eout; getout.npix=nout;
                getout.title=[wout.title,' COMBINED '];
                getout.iint=irange;
                getout.uoffset=uoff;
                wout=d2d(getout);
                %
            end
        else
            [irange,uoff]=calculate_integration_range(w1,w2);
            %data plane is the same, but the axes are different. So need
            %shoelace rebin. This has the extra compication of requiring
            %tolerance. Must work out the the full data range of the
            %combined dataset in terms of the axes of w1.
            w2tmp=rebin_horace_2d(d2d(w2),d2d(w1));
            w1tmp=rebin_horace_2d(d2d(w1),w2tmp);
            %now have 2 objects that have the same data range
            %can add the signals and errors in the appropriate way.
            tolx=tol(1); toly=tol(2);
            if isnan(tolx)
                tolx=[];
            end
            if isnan(toly)
                toly=[];
            end
            
            w2tmp=rebin_horace(w2tmp,tolx,toly);
            w1tmp=rebin_horace(w1tmp,tolx,toly);
            s1=w1tmp.s; e1=w1tmp.e; n1=w1tmp.npix;
            s2=w2tmp.s; e2=w2tmp.e; n2=w2tmp.npix;
            e1_old=e1; e2_old=e2;%absolute errors, not fractional.
            e1=e1./s1; e2=e2./s2;
            e1(isnan(e1) | isinf(e1))=0;
            e2(isnan(e2) | isinf(e2))=0;
            biggest=[max(max(s1)) max(max(s2))];
            e1=e1+((e1==0).*1e5.*max(biggest));
            e2=e2+((e2==0).*1e5.*max(biggest));
            sout=(s2./e2 + s1./e1)./(1./e2 + 1./e1);
            eout=1./(1./e2 + 1./e1);
            nout=n1+n2;
            nout(e1_old==0 & e2_old==0)=0;
            sout(e1_old==0 & e2_old==0)=0;
            eout(e1_old==0 & e2_old==0)=0;
            %
            %Convert fractional error back to absolute error:
            eout=eout.*sout;
            wout=w1tmp;
            wout.s=sout; wout.e=eout; wout.npix=nout;
            wout.iint=irange;
            wout.uoffset=uoff;
            wout.title=[w1.data.title, ' COMBINED'];
            
            
        end
        
end
