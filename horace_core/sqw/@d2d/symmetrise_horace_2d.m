function wout=symmetrise_horace_2d(win,varargin)
%
% Symmetrise d2d (or sqw of d2d-type) data_.
%
% NOTE THAT THIS ROUTINE IS SLOOOOOOOOOOOOOOOOOW, BECAUSE IT USES A RATHER
% COMPLICATED "SHOELACE" ALGORITHM TO ENSURE THAT REBINNING OF THE
% SYMMETRISED DATA IS DONE CORRECTLY.
%
% Syntax:
%    1) wout = symmetrise_horace_2d(win,[xval,yval]) - reflect data about
%       xval and yval. e.g. if xval=1 then x=-1 --> x=3 etc. If no
%       reflection is required for a given axis then specify xval/yval as
%       NaN.
%       e.g. wout = symmetrise_horace_2d(win,[0,NaN]) reflects data about
%       x=0. No y-reflection performed.
%
%    2) wout = symmetrise_horace_2d(win,v1,v2,v3)
%    OR wout = symmetrise_horace-2d(win,v1,v2)   - reflect data about a
%    plane specified by the vectors v1,v2,v3. If no v3 specified then v3 is
%    set to be [0,0,0].
%        v1 and v2 are two vectors which lie in the reflection plane.
%        e.g. to reflect x-->-x, need v1=[0,1,0] and v2=[0,0,1] etc.
%        v3 is a vector which specifies the offset of this plane from the
%        origin. So for v1=[0,1,0] and v2=[0,0,1], putting v3=[1,0,0] would
%        result in reflections such as x=-1 --> x=3.
%
% RAE 22/1/10
%


[ndims, ~]=dimensions(win);

if ndims~=2
    error('Horace error: symmetrise_horace_2d only works for 2-dimensional data');
end

if isa(win,'sqw') && has_pixels(win)
    error('Horace error: symmetrise_horace_2d method is for d2d-type data only');
end

%First determine what kind of symmetrisation we are doing:
if nargin==2
    if isnumeric(varargin{1}) && numel(varargin{1})==2
        route=1;%case where we have a vector input (2 midpoints)
    else
        error('Horace error: check form of input arguments for symmetrise_horace_2d');
    end
elseif nargin==3
    if isnumeric(varargin{1}) && numel(varargin{1})==3 && ...
            isnumeric(varargin{2}) && numel(varargin{2})==3
        route=2;
        varargin{3}=[0 0 0];%special case where v3 is not specified, so assumed to be origin
    else
        error('Horace error: check form of input arguments for symmetrise_horace_2d');
    end
elseif nargin==4
    if isnumeric(varargin{1}) && numel(varargin{1})==3 && ...
            isnumeric(varargin{2}) && numel(varargin{2})==3 && ...
            isnumeric(varargin{3}) && numel(varargin{3})==3
        route=2;
    else
        error('Horace error: check form of input arguments for symmetrise_horace_2d');
    end
else
    error('Horace error: check form of input arguments for symmetrise_horace_2d');
end

%Now do the symmetrisation:
switch route
    case 1
        %this is the case where we have specified one or two midpoints.
        midpoint=varargin{1};
        [xin,yin] = ndgrid(win.data_.p{1}, win.data_.p{2});
        [xout,yout,sout,eout,nout] = symmetrise_2d(xin, yin,...
            win.data_.s, win.data_.e, win.data_.npix, midpoint);
        wout = d2d(win);
        wout.data_.p{1} = xout(:,1);
        wout.data_.p{2} = yout(1,:)';
        wout.data_.s = sout;
        wout.data_.e = eout;
        wout.data_.npix = nout;
    case 2
        %We need to check here whether the symmetrisation plane specified
        %actually correpsonds to the above case. If it does then we can
        %save time by using the faster routine above.
        [speedup,midpoint]=compare_sym_axes(win,varargin{1},varargin{2},varargin{3});
        if speedup
            %can use the routine from case 1
            [xin,yin]=ndgrid(win.data_.p{1},win.data_.p{2});
            [xout, yout, sout, eout, nout] = symmetrise_2d(xin, yin, ...
                win.data_.s, win.data_.e, win.data_.npix, midpoint);
            wout = d2d(win);
            wout.data_.p{1} = xout(:,1);
            wout.data_.p{2} = yout(1,:)';
            wout.data_.s = sout;
            wout.data_.e = eout;
            wout.data_.npix = nout;
        else
            %realise that we have to restrict ourselves to symmetrisation
            %planes that are pendicular to the data plane, so that the
            %operation of them results in points which are still in the
            %original data plane.
            %
            %Also discover that in the case where the symmetrisation plane
            %is a diagonal, and we end up with parallel lines for the
            %rebin/combine part, we get errors because the shoelace method
            %cannot cope with such situations very well. There should
            %therefore be an extra case where we check if the symm plane is
            %a diagonal, and if so we can deal with it differently.
            [ok, mess] = test_symmetrisation_plane(win, varargin{1}, varargin{2}, varargin{3});
            [diag, type] = test_symmetrisation_plane_diagonal(win, varargin{1}, varargin{2}, varargin{3});
            if ok
                if diag
                    %the symmetrisation plane was a diagonal. This means
                    %that the reflected data will have the same axes as the
                    %original data, so we can use the linear rebining code
                    %to combine them.
                    [xin,yin]=ndgrid(win.data_.p{1},win.data_.p{2});
                    v1=varargin{1}; v2=varargin{2}; v3=varargin{3};

                    [xout, yout, sout, eout, nout] = symmetrise_2d_diag(xin, yin, ...
                        win.data_.s, win.data_.e, win.data_.npix, v1, v2, v3, type, win);
                    wout=d2d(win);
                    wout.data_.s=sout;
                    wout.data_.e=eout;
                    wout.data_.npix=nout;
                    wout.data_.p{1}=xout(:,1);
                    wout.data_.p{2}=yout(1,:)';
                    %
                else
                    %get bin boundaries in shoelace format
                    [xin,yin,sin,ein,nin]=convert_bins_for_shoelace(win,[]);
                    %Must now calculate the reflection matrix in terms of the
                    %base co-ordinate system:
                    v1=varargin{1}; v2=varargin{2}; v3=varargin{3};
                    [R,trans] = calculate_transformation_matrix(win,v1,v2,v3);
                    %Do the reflection:
                    [xr,yr,sr,er,nr]=reflect_data_bins(xin,yin,sin,ein,nin,R,trans);
                    %Now we collect the data and reflected data, and throw away
                    %info from both sets that is to the lhs of the reflection
                    %plane:
                    [xinright,yinright,sinright,einright,ninright]=discard_lhs(win,xin,yin,sin,ein,nin,...
                        v1,v2,v3);
                    [xrright,yrright,srright,erright,nrright]=discard_lhs(win,xr,yr,sr,er,nr,...
                        v1,v2,v3);
                    %We must do shoelace rebinning on what is left. But first
                    %we must make an output grid that covers all of the data_.
                    xinlo=min(min(xinright)); xrlo=min(min(xrright));
                    yinlo=min(min(yinright)); yrlo=min(min(yrright));
                    xinhi=max(max(xinright)); xrhi=max(max(xrright));
                    yinhi=max(max(yinright)); yrhi=max(max(yrright));
                    xstep=win.data_.p{1}(2)- win.data_.p{1}(1);
                    ystep=win.data_.p{2}(2) - win.data_.p{2}(1);

                    xoutbin=[min([xinlo xrlo]):xstep:(max([xinhi xrhi])+xstep-eps)];%extra bit to avoid
                    %problems with rounding errors
                    youtbin=[min([yinlo yrlo]):ystep:(max([yinhi yrhi])+ystep-eps)];
                    xtmp=[]; ytmp=[];
                    for i=1:(length(youtbin)-1)
                        newx=[xoutbin(1:end-1); xoutbin(2:end); xoutbin(2:end); xoutbin(1:end-1)];
                        xtmp=[xtmp newx];
                        newy=repmat([youtbin(i); youtbin(i); youtbin(i+1); youtbin(i+1)],1,numel(xoutbin)-1);
                        ytmp=[ytmp newy];
                    end
                    [soutin,eoutin,noutin]=rebin_shoelace(xinright,yinright,sinright,einright,...
                       ninright,xtmp,ytmp);
                    [soutr,eoutr,noutr]=rebin_shoelace(xrright,yrright,srright,erright,...
                        nrright,xtmp,ytmp);
                    %this seems to have worked, although it is dreadfully slow.

                    sout=zeros(length(xoutbin)-1,length(youtbin)-1);
                    eout=sout;
                    nout=sout;
                    soutrt=sout;
                    eoutrt=eout;
                    noutrt=nout;

                    len_p1m1 = length(xoutbin) - 1;
                    len_p2m1 = length(youtbin) - 1;

                    for i=1:len_p2m1
                        sout(:,i)=soutin((1:len_p1m1) + (i-1)*len_p1m1);
                        eout(:,i)=eoutin((1:len_p1m1) + (i-1)*len_p1m1);
                        nout(:,i)=noutin((1:len_p1m1) + (i-1)*len_p1m1);
                        soutrt(:,i)=soutr((1:len_p1m1) + (i-1)*len_p1m1);
                        eoutrt(:,i)=eoutr((1:len_p1m1) + (i-1)*len_p1m1);
                        noutrt(:,i)=noutr((1:len_p1m1) + (i-1)*len_p1m1);
                    end
                    %
                    eout=eout./sout;
                    eoutrt=eoutrt./soutrt;
                    eout(isnan(eout) | isinf(eout))=0;
                    eoutrt(isnan(eoutrt) | isinf(eoutrt))=0;
                    eout=eout+((eout==0).*1e16);
                    eoutrt=eoutrt+((eoutrt==0).*1e6);
                    %
                    sfinal=((sout./eout)+(soutrt./eoutrt))./(1./eout + 1./eoutrt);
                    efinal=1./(1./eout + 1./eoutrt); efinal=efinal.*sfinal;
                    nfinal=nout+noutrt;
                    %
                    wout=d2d(win);
                    wout.data_.p{1}=xoutbin';
                    wout.data_.p{2}=youtbin';

                    wout.data_.s=sfinal;
                    wout.data_.e=efinal;
                    wout.data_.npix=nfinal;

                    wout.data_.title=[wout.data_.title,' SYMMETRISED '];
                end
            else
                error(mess);
            end
        end
end




