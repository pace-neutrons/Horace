% Remove a dimension from the square matrix (or stacked matricies) M,
% by projecting it onto the remaining dimensions.
% Usage:
%   M' = integrate_project(M,i) for  0 < i < size(M,1) 
% 
%   If M is a (d,d) matrix then M' is a (d-1,d-1) matrix with elements
%   corresponding to 1:d != i.
%
% This algorithm uses external C++ code to perform the projections in
% parallel, if possible. If not requested, or not possible, it falls back
% to equivalent MATLAB code (which is 3 orders of magnitude slower).
% 
%
function Mp=integrate_project(M,i)
d = size(M,1);
assert(size(M,2)==d,'M should be one or more square matricies.');
m = size(M,3); % might be one, which should be OK
assert(i>0 & i<=d, 'i should be a valid subindex into each matrix');

castto = 'UInt64';
d = cast(d,castto);
m = cast(m,castto);
i = cast(i,castto);

castdbl ='double';
M = cast(M,castdbl);

config = hor_config();
if config.use_mex
    try
    Mp = cppIntegrateProject(d,m,M,i);
    catch 
        warning('Executing mex file failed.')
        config.use_mex=false;
    end
end
if ~config.use_mex
    if m==1
        Mp=matlab_integrate_project(d,M,i);
    else
        Mp=zeros([d-1,d-1,m]);
        for j=1:m
            Mp(:,:,j)=matlab_integrate_project(d,M(:,:,j),i);
        end
    end
end
end
%==========================================================================
function Mp = matlab_integrate_project(d,M,i)
if d == 1
    Mp=M;
    return;
end
k=(1:d)~=i;
b=(M(k,i)+M(i,k)')/2;
Mp= M(k,k) - (b*b')/M(i,i);
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