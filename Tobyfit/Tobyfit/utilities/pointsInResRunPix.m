% pointInResRunPix(nCell,span,Y,Yrun,Yhead,Ylist,X,M,V,Xrun,Xcell,frac)
%
% Determine the Y points within resolution for each of the X pixels.
% 
% Input:
% 	nCell	the number of neighbourhood cells along each dimension: (1,dim)
% 	span	the span for each dimension -- could be easily calculated from nCell: (1,dim)
% 
% 	Y		the point(s) to check: (dim,n)
% 	Yhead	the head of a linked list putting points into cells: (1,prod(nCell))
% 	Ylist	the list of a linked list putting points into cells: (n,1)
% 
% 	X		the pixel(s) to check: (dim,m)
% 	M		the pixel resolution gaussian widths: (dim,dim,m)
% 	V		the pixel resolution volumes: (m,1)
% 	Xcell	the linear cell index for each pixel: (m,1)
% 
% 	frac	the fractional probability for deciding if a point is within resolution
% 
% Output:
% 	iPx		indicies into X: (1,m); some permutation of 1:m
% 	nPt		the number of points within resolution for each pixel: (1,m)
% 	fst		the first index into iPt of a point within resolution for each pixel: (1,m)
% 	lst		the last index into iPt of a point within resolution for each pixel: (1,m)
% 	iPt		indicies into Y for all points within resolution of *a* pixel: between (1,0) and (1,m*n)
% 	VxR		the value of V(i)*R(i)[Y-X(i)] for eaxh point in iPt: same sized as iPt

function [iPx,nPt,fst,lst,iPt,VxR]=pointsInResRunPix(nCell,span,Y,Yrun,Yhead,Ylist,X,M,V,Xrun,Xcell,frac)
castto = 'UInt64';
t =     cast(prod(nCell),castto);
cells = cast(nCell,castto);
spans = cast(span,castto);
yrun  = cast(Yrun(:),castto);
yhead = cast(Yhead,castto);
ylist = cast(Ylist,castto);
xrun  = cast(Xrun,castto);
xcell = cast(Xcell,castto);

castdbl ='double';
y = cast(Y,castdbl);
x = cast(X,castdbl);
m = cast(M,castdbl);
v = cast(V,castdbl);
f = cast(frac,castdbl);
    
config = hor_config();
if config.use_mex
    try
    [iPx,nPt,fst,lst,iPt,VxR]=cppPointsInResRunPix(t,cells,spans,y,yrun,yhead,ylist,x,m,v,xrun,xcell,f);
    catch
        warning('Executing mex file failed.')
        config.use_mex=false;
    end
end
if ~config.use_mex
    [iPx,nPt,fst,lst,iPt,VxR]=point_in_run_resolution_with_prob_xcell(span,cells,y,yead,ylist,x,m,v,xcell,f);
end
        
end

% function ids = identify_types(types,objs)
%     cell_ids = cellfun(@(y)find(cellfun(@(x)strcmpi(x,class(y)),types)),objs,'UniformOutput',false);
%     notfnd = cellfun(@isempty,cell_ids);
%     if any(notfnd)
%         cell_ids{notfnd}=0;
%     end
%     ids = cat(1,cell_ids{:});
% end
% function typ = promote_type(varargin)
%     inttypes = {'Int8','UInt8','Int16','UInt16','Int32','UInt32','Int64','UInt64'};
%     intprmts = {'UInt8','UInt8','UInt16','UInt16','UInt32','UInt32','UInt64','UInt64'};
%     flttypes = {'single','double'};
%     if any( cellfun( @(x)strcmpi(x,class(varargin{1})),inttypes) )
%         % At least the first input is an integer 
%         classidx = identify_types(inttypes,varargin);
%         if any(classidx==0)
%             error('Mixed Integer and Non-integer types?')
%         end
%         % As long as all integers are positive, they can be promoted along
%         % inttypes
%         typ = intprmts{ max(classidx) };
%     elseif any( cellfun( @(x)strcmpi(x,class(varargin{1})),flttypes) )
%         % At least the first input is a floating point number 
%         classidx = identify_types(flttypes,varargin);
%         if any(classidx==0)
%             error('Mixed floating point and Non-floating point types?')
%         end
%         typ = flttypes{ max(classidx) };
%     else
%         typ = 'any';
%     end
% end