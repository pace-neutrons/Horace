function wout=rebin_sqw(win,varargin)
%
% Rebin data in an sqw object, either with the boundaries specified by
% another object, or with a specified set of [lo,step,hi].
% Because a rebinnable sqw can have dimensionality 1-3, we have to do tests
% for quite a large number of scenarios. NB we decide not to do rebins on
% d0d (pointless).
%
% When working with sqw objects we can use the "MSlice approximation", i.e.
% that the size of the pixels is much smaller than the size of the bins, so
% that we just put all of the spectral weight from a given pixel into then
% bin where we find it's centre.
%
% wout=rebin_sqw(win,[lo1,step1,hi1],[lo2,step2,hi2],...) - rebin between
% specified limits with a given step size.
%
% wout=rebin_sqw(win,step1,step2,...) - rebin with a given step size.
%
% wout=rebin_sqw(win,w2) - rebin using the bin boundaries of object w2,
% which is either an sqw of the same dimensionality, or a dnd.
%
%
% RAE 21/1/10


win=sqw(win);

if ~is_sqw_type(win)
    %what we should actually do here is go to the dnd-rebin of correct
    %dimensionality
    error('Horace error: input object must be sqw type with detector pixel information');
end

if nargin==2
    if isa(win,'sqw') && (isa(varargin{1},'sqw') || ...
            isa(varargin{1},'d1d') || isa(varargin{1},'d2d') || isa(varargin{1},'d3d')) 
            route=1;%rebinning using the boundaries of a template object (more tests required)
    elseif isvector(varargin{1})
        route=2;
    else
        error('Horace error: check the format of input arguments');
    end
elseif nargin==3
    %Rebinninig using 2 vectors
    if (isvector(varargin{1}) || isempty(varargin{1})) && ...
            (isvector(varargin{2}) || isempty(varargin{2}))
        route=3;
    else
        error('Horace error: check the format of input arguments');
    end
elseif nargin==4
    %Rebinning using 3 vectors
    if (isvector(varargin{1}) || isempty(varargin{1})) && ...
            (isvector(varargin{2}) || isempty(varargin{2})) && ...
            (isvector(varargin{3}) || isempty(varargin{3}))
        route=4;
    else
        error('Horace error: check the format of input arguments');
    end    
else
    error('Horace error: check the format of input arguments');
end

% Turn off horace_info output, but save for automatic cleanup on exit or cntl-C (TGP 30/11/13)
info_level = get(hor_config,'horace_info_level');
cleanup_obj=onCleanup(@()set(hor_config,'horace_info_level',info_level));
set(hor_config,'horace_info_level',-1);

switch route
    case 1
        %rebinning with a template object. this is the most complicated
        %case
        w2=sqw(varargin{1});
        ndimsin=dimensions(win); ndims2=dimensions(w2);
        if ndimsin~=ndims2
            error('Horace error: dimensionality of object to be rebinned and template object must be the same');
        end
        %must check that the (hyper) plane described by the data axes for
        %both objects is the same. Simplest case is that they have the same
        %axes, but in principle it is OK if we just have the same plane.
        %e.g. a 2d object could be rebinned from (1,0,0)/(0,1,0) to
        %(1,1,0)/(-1,1,0)
        u1=win.data.u_to_rlu; u2=w2.data.u_to_rlu;
        if ndimsin==1
            crossprod=cross(u1([1:3],win.data.pax(1)),u2([1:3],w2.data.pax(1)));
            if all(crossprod<1e-5)
                %have parallel axes, so can proceed
                min1=min(win.data.p{1}); max1=max(win.data.p{1});
                min2=min(w2.data.p{1}); max2=max(w2.data.p{1});
                themin=min([min1 min2]); themax=max([max1 max2]);
                thestep=w2.data.p{1}(2)-w2.data.p{1}(1);
                xbin=[themin,thestep,themax];
                wtmp=get(win);
                wtmp.data.pix=win.data.pix;
                wtmp.data.p{1}=[themin:thestep:(themax+thestep-eps)]';
                wtmp.data.s=zeros(length(wtmp.data.p{1}) - 1,1);
                wtmp.data.e=wtmp.data.s; wtmp.data.npix=wtmp.data.s;
                wtmp.data.npix(1)=sum(win.data.npix);
                wtmp=sqw(wtmp);
                wout=cut(wtmp,xbin);
            else
                error('Horace error: for rebin of 1-dimensional objects both must have the same axes');
            end  
        elseif ndimsin==2
            v11=u1([1:3],win.data.pax(1)); v12=u1([1:3],win.data.pax(2));
            v21=u2([1:3],w2.data.pax(1)); v22=u2([1:3],w2.data.pax(2));
            crossprod1=cross(v11,v12); crossprod2=cross(v21,v22);
            crossprod=cross(crossprod1,crossprod2);
            %
            %NB - realise crossprod will be zero if one of the vectors is
            %made of zeros (i.e. one of the axes is energy)
            energy_axis=false;
            if (u1(4,win.data.pax(1))==1 || u1(4,win.data.pax(2))==1) && ...
                    (u2(4,w2.data.pax(1))==1 || u2(4,w2.data.pax(2))==1)
                energy_axis=true;
            end
            %
            if all(crossprod<1e-5) && ~energy_axis
                %have parallel planes, because normal to planes are
                %parallel/antiparallel. need to get minima and maxima along
                %the 2 axes:
                minx2=min(min(w2.data.p{1})); maxx2=max(max(w2.data.p{1}));
                miny2=min(min(w2.data.p{2})); maxy2=max(max(w2.data.p{2}));
                %
                %Need to convert min/max of win into co-ordinate frame of w2.
                [xtmp,ytmp,stmp,etmp,ntmp]=convert_bins_for_shoelace(d2d(win),d2d(w2));
                minx1=min(min(xtmp)); maxx1=max(max(xtmp));
                miny1=min(min(ytmp)); maxy1=max(max(ytmp));
                %
                thexmin=min([minx1 minx2]); thexmax=max([maxx1 maxx2]);
                theymin=min([miny1 miny2]); theymax=max([maxy1 maxy2]);
                thexstep=w2.data.p{1}(2)-w2.data.p{1}(1);
                theystep=w2.data.p{2}(2)-w2.data.p{2}(1);
                xbin=[thexmin,thexstep,thexmax];
                ybin=[theymin,theystep,theymax];
                %
                wout=get(win);%needs to be structure array because in some of the intermediate
                %steps we need to make an object that would be inconsistent
                %with the sqw construct (e.g. number of bins inconsistent
                %with size of signal array).
                
                %We must also ensure that the output object's u_to_rlu
                %matrix is correct:
                newu=win.data.u_to_rlu;
                newu([1:3],win.data.pax(1))=v21;
                newu([1:3],win.data.pax(2))=v22;
                wout.data.u_to_rlu=newu;
                %
                wout.data.pix=win.data.pix;
                wout.data.p{1}=[thexmin:thexstep:(thexmax+thexstep-eps)]';
                wout.data.p{2}=[theymin:theystep:(theymax+theystep-eps)]';
                wout.data.s=zeros(length(wout.data.p{1})-1,length(wout.data.p{2})-1);
                wout.data.e=wout.data.s;
                wout.data.npix=wout.data.s;
                wout.data.npix(1,1)=sum(sum(win.data.npix));%hack to ensure no failure of sqw construct
                wout=sqw(wout);%convert from structure array to sqw object
                %
                wout=cut(wout,xbin,ybin);
            elseif all(crossprod<1e-5) && energy_axis
                %One of the 2 axes is energy. this simplifies things,
                %because it means that the non-energy axes must be the
                %same. Can test this by noticing that cross products for
                %all pairs of vectors should be zero.
                set1=1e-5.*(round(1e5.*[v11 v12])); set2=1e-5.*(round(1e5.*[v21 v22]));
                if ~isequal(set1,set2) && ~isequal(set1,circshift(set2,[0,-1]))
                    error('Horace error: check axes of the 2 2d objects are consistent for rebinning');
                end
                minx1=min(win.data.p{1}); maxx1=max(win.data.p{1});
                miny1=min(win.data.p{2}); maxy1=max(win.data.p{2});
                minx2=min(w2.data.p{1}); maxx2=max(w2.data.p{1});
                miny2=min(w2.data.p{2}); maxy2=max(w2.data.p{2});
                thexmin=min([minx1 minx2]); thexmax=max([maxx1 maxx2]);
                theymin=min([miny1 miny2]); theymax=max([maxy1 maxy2]);
                xstep=w2.data.p{1}(2)-w2.data.p{1}(1);
                ystep=w2.data.p{2}(2)-w2.data.p{2}(1);
                xbin=[thexmin,xstep,thexmax];
                ybin=[theymin,ystep,theymax];
                %
                wout=get(win);
                wout.data.p{1}=[thexmin:xstep:(thexmax+xstep-eps)]';
                wout.data.p{2}=[theymin:ystep:(theymax+ystep-eps)]';
                wout.data.s=zeros(length(wout.data.p{1})-1,length(wout.data.p{2})-1);
                wout.data.e=wout.data.s; wout.data.npix=wout.data.s;
                wout.data.npix(1,1)=sum(sum(win.data.npix));
                %
                wout=sqw(wout);%convert back to sqw from structure array
                %
                wout=cut(wout,xbin,ybin);
            else
                error('Horace error: for rebin of 2-dimensional objects both must have same data plane');
            end
        elseif ndimsin==3
            %This is going to be pretty complicated...
            v11=u1([1:3],win.data.pax(1)); v12=u1([1:3],win.data.pax(2));
            v13=u1([1:3],win.data.pax(3));
            v21=u2([1:3],w2.data.pax(1)); v22=u2([1:3],w2.data.pax(2));
            v23=u2([1:3],w2.data.pax(3));
            %
            %Check if one of the axes is energy. Should be the final column
            energy_axis=false;
            if (isequal(v13,[0;0;0]) && ~isequal(v23,[0;0;0])) || ...
                    (~isequal(v13,[0;0;0]) && isequal(v23,[0;0;0]))
                error('Horace error: only one 3-dimensional object has an energy axis');
            elseif isequal(v13,[0;0;0]) && isequal(v23,[0;0;0])
                energy_axis=true;
            end
            %
            if energy_axis
                %can do the same check here as with 2-dimensional case
                crossprod1=cross(v11,v12); crossprod2=cross(v21,v22);
                crossprod=cross(crossprod1,crossprod2);
                if all(crossprod<1e-5)
                    %have parallel planes, because normal to planes are
                    %parallel/antiparallel. need to get minima and maxima along
                    %the 2 axes:
                    minx2=min(min(w2.data.p{1})); maxx2=max(max(w2.data.p{1}));
                    miny2=min(min(w2.data.p{2})); maxy2=max(max(w2.data.p{2}));
                    minz2=min(min(w2.data.p{3})); maxz2=max(max(w2.data.p{3}));
                    %
                    %Need to convert min/max of win into co-ordinate frame of w2.
                    %makes a 2d dataset with same x/y range as win
                    wtmp=cut(win,[],[],[-Inf,Inf]);
                    w2tmp=cut(w2,[],[],[-Inf,Inf]);
                    [xtmp,ytmp,stmp,etmp,ntmp]=convert_bins_for_shoelace(d2d(wtmp),d2d(w2tmp));
                    minx1=min(min(xtmp)); maxx1=max(max(xtmp));
                    miny1=min(min(ytmp)); maxy1=max(max(ytmp));
                    %
                    thexmin=min([minx1 minx2]); thexmax=max([maxx1 maxx2]);
                    theymin=min([miny1 miny2]); theymax=max([maxy1 maxy2]);
                    thexstep=w2.data.p{1}(2)-w2.data.p{1}(1);
                    theystep=w2.data.p{2}(2)-w2.data.p{2}(1);
                    xbin=[thexmin,thexstep,thexmax];
                    ybin=[theymin,theystep,theymax];
                    %
                    %Deal with energy axis on its own:
                    minz1=min(min(win.data.p{3})); maxz1=max(max(win.data.p{3}));
                    thezmin=min([minz1 minz2]); thezmax=max([maxz1 maxz2]);
                    thezstep=win.data.p{3}(2)-win.data.p{3}(1);
                    zbin=[thezmin,thezstep,thezmax];
                    %
                    wout=get(win);
                    %
                    %See 2d case for reasoning for the following 4 lines:
                    newu=win.data.u_to_rlu;
                    newu([1:3],win.data.pax(1))=v21;
                    newu([1:3],win.data.pax(2))=v22;
                    wout.data.u_to_rlu=newu;
                    %
                    wout.data.pix=win.data.pix;
                    wout.data.p{1}=[thexmin:thexstep:(thexmax+thexstep-eps)]';
                    wout.data.p{2}=[theymin:theystep:(theymax+theystep-eps)]';
                    wout.data.p{3}=[thezmin:thezstep:(thezmax+thezstep-eps)]';
                    wout.data.s=zeros(length(wout.data.p{1})-1,length(wout.data.p{2})-1,length(wout.data.p{3})-1);
                    wout.data.e=wout.data.s;
                    wout.data.npix=wout.data.s;
                    wout.data.npix(1,1,1)=sum(sum(sum(win.data.npix)));
                    wout=sqw(wout);%convert back to sqw from structure array
                    %
                    wout=cut(wout,xbin,ybin,zbin);
                else
                    error('Horace error: for rebin of 3-dimensional objects both must have same data hyper-plane');
                end
            else
                %it is more complicated. Probably best thing to do is to
                %work out the extent of the q co-ords direct from the pix
                %array. The Matlab funciton "qr" will be quite useful here.
                set1=[v11 v12 v13]; set2=[v21 v22 v23];
                coords=win.data.pix([1:3],:);%we can do this because energy is not an axis
%                 [Q1,R1]=qr(set1');
                [Q2,R2]=qr(set2');
%                 coords1=(Q1*inv(R1))*coords;
                rlutrans=(2*pi./win.data.alatt)';
                coords_rlu=coords./repmat(rlutrans,1,numel(coords) /3);
                coords2=(Q2*inv(R2))*coords_rlu;
                %
                %
                min21=min(coords2(1,:)); min22=min(coords2(2,:));
                min23=min(coords2(3,:));
                max21=max(coords2(1,:)); max22=max(coords2(2,:));
                max23=max(coords2(3,:));
                step1=w2.data.p{1}(2)-w2.data.p{1}(1);
                step2=w2.data.p{2}(2)-w2.data.p{2}(1);
                step3=w2.data.p{3}(2)-w2.data.p{3}(1);
                xbins=[min21,step1,max21];
                ybins=[min22,step2,max22];
                zbins=[min23,step3,max23];
                %
                %Remember that the co-ordinates in the pix array are in
                %inverse angstroms, so must normalise by rlu:
%                 xbins=xbins./w2.data.ulen(w2.data.pax(1));
%                 ybins=ybins./w2.data.ulen(w2.data.pax(2));
%                 zbins=zbins./w2.data.ulen(w2.data.pax(3));
                %
                wout=get(win);
                %
                newu=wout.data.u_to_rlu;
                newu([1:3],win.data.pax(1))=v21;
                newu([1:3],win.data.pax(2))=v22;
                newu([1:3],win.data.pax(3))=v23;
                wout.data.u_to_rlu=newu;
                wout.data.ulen=w2.data.ulen;
                %
                wout.data.p{1}=[xbins(1):xbins(2):(xbins(3)+xbins(2)-eps)]';
                wout.data.p{2}=[ybins(1):ybins(2):(ybins(3)+ybins(2)-eps)]';
                wout.data.p{3}=[zbins(1):zbins(2):(zbins(3)+zbins(2)-eps)]';
                wout.data.s=zeros(length(wout.data.p{1})-1,length(wout.data.p{2})-1,...
                    length(wout.data.p{3})-1);
                wout.data.e=wout.data.s; wout.data.npix=wout.data.s;
                wout.data.npix(1,1,1)=sum(sum(sum(win.data.npix)));
                wout.data.pix=win.data.pix;
                wout=sqw(wout);
                %
                wout=cut(wout,xbins,ybins,zbins);
            end
            
            
        else
            error('Horace error: rebinning not yet implemented for 4-dimensional datasets. Take a cut from the raw data instead');
        end  
    case 2
        %rebinning just the x-axis
        xbin=varargin{1};
        if numel(xbin)==1
            %just specify the bin size, so need to determine upper and
            %lower extent of data.
        elseif numel(xbin)==3
            %specified [lo,step,hi]
            if xbin(1)>=xbin(3) || (xbin(3)-xbin(1))<xbin(2)
                error('Horace error: problem with specified x-bins. Must be of form [step] or [lo,sttep,hi]');
            end  
        else
            xbin=[];
        end
        %
        ndims=dimensions(win);
        if ndims==1
            wout=cut(win,xbin);
        elseif ndims==2
            wout=cut(win,xbin,[]);
        elseif ndims==3
            wout=cut(win,xbin,[],[]);
        elseif ndims==4
            wout=cut(win,xbin,[],[],[]);
        else
            error('ERROR: Dimensions of dataset is not integer in the range 1 to 4');
        end
        
    case 3
        %rebinning x and/or y-axes
        xbin=varargin{1}; ybin=varargin{2};
        if ~isempty(xbin)
            if numel(xbin)==1
                %do nothing
            elseif numel(xbin)==3
                %lo,step,hi
                if xbin(1)>=xbin(3) || (xbin(3)-xbin(1))<xbin(2)
                    error('Horace error: problem with specified x-bins. Must be of form [step] or [lo,sttep,hi]');
                end   
            else
                xbin=[];%if specified something other than [step] or [lo,step,hi] then just return input
            end
        end
        if ~isempty(ybin)
            if numel(ybin)==1
                %just a step size specified for x
            elseif numel(ybin)==3
                %lo,step,hi
                if ybin(1)>=ybin(3) || (ybin(3)-ybin(1))<ybin(2)
                    error('Horace error: problem with specified y-bins. Must be of form [step] or [lo,sttep,hi]');
                end 
            else
                ybin=[];
            end
        end
        %
        ndims=dimensions(win);
        if ndims==1
            error('Horace error: have specified 2 binning arguments for a 1-dimensional object');
        elseif ndims==2
            wout=cut(win,xbin,ybin);
        elseif ndims==3
            wout=cut(win,xbin,ybin,[]);
        elseif ndims==4
            wout=cut(win,xbin,ybin,[],[]);
        else
            error('ERROR: Dimensions of dataset is not integer in the range 1 to 4');
        end
        
    case 4
        %rebinning x and/or y and/or z axes
        xbin=varargin{1}; ybin=varargin{2}; zbin=varargin{3};
        if ~isempty(xbin)
            if numel(xbin)==1
                %just a step size specified for x
            elseif numel(xbin)==3
                %lo,step,hi
                if xbin(1)>=xbin(3) || (xbin(3)-xbin(1))<xbin(2)
                    error('Horace error: problem with specified x-bins. Must be of form [step] or [lo,sttep,hi]');
                end  
            else
                xbin=[];
            end
        end
        if ~isempty(ybin)
            if numel(ybin)==1
                %just a step size specified for x
            elseif numel(ybin)==3
                %lo,step,hi
                if ybin(1)>=ybin(3) || (ybin(3)-ybin(1))<ybin(2)
                    error('Horace error: problem with specified y-bins. Must be of form [step] or [lo,sttep,hi]');
                end 
            else
                ybin=[];
            end
        end
        if ~isempty(zbin)
            if numel(zbin)==1
                %just a step size specified for x
            elseif numel(zbin)==3
                %lo,step,hi
                if zbin(1)>=zbin(3) || (zbin(3)-zbin(1))<zbin(2)
                    error('Horace error: problem with specified z-bins. Must be of form [step] or [lo,sttep,hi]');
                end 
            else
                zbin=[];
            end
        end
        %
        ndims=dimensions(win);
        if ndims==1
            error('Horace error: have specified 2 or more binning arguments for a 1-dimensional object');
        elseif ndims==2
            error('Horace error: have specified 3 or more binning arguments for a 2-dimensional object');
        elseif ndims==3
            wout=cut(win,xbin,ybin,zbin);
        elseif ndims==4
            wout=cut(win,xbin,ybin,zbin,[]);
        else
            error('ERROR: Dimensions of dataset is not integer in the range 1 to 4');
        end
        
end


