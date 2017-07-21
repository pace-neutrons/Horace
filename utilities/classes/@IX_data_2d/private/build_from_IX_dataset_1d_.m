function obj = build_from_IX_dataset_1d_(obj,w1,varargin)
% Create an IX_dataset_2d object from an array of IX_dataset_1d objects
%
%   >> w2 = w2.IX_dataset_1d (w1)
%   >> w2 = w2.IX_dataset_1d (w1, y)
%   >> w2 = w2.IX_dataset_1d (w1, y, y_axis)
%   >> w2 = w2.IX_dataset_1d (w1, y, y_axis, y_distr)
%   >> w2 = w2.IX_dataset_1d (w1, y, y_axis, y_distr, bindata)
%
% Input:
% ------
%   w1      IX_dataset_1d or array of IX_dataset_1d
%
%   y       y-axis values (point or histogram)
%             - single array if one output IX_dataset_2d
%             - cell array of arrays if two or more output IX_dataset_2d
%
%   y_axis  Annotation and units for y-axis. See help IX_axis for full
%           range of possible syntax, but include
%               - caption e.g. 'Scattering angle'
%               - caption and units e.g. IX_axis('Energy','meV')
%           If more than one output IX_dataset_2d, then y_axis
%           can be cell array of strings or array of IX_axis objects.
%           (assumed to all be the same if not array)
%
%   y_distr Logical flag to indicate if data forms a distribution
%             - true if a distribution i.e. counts per unit y
%             - false if otherwise
%           If more than one output IX_dataset_1d, then can be a logical array
%           (assumed to all be the same if not array)
%
%   bindata Logical array indicating which IX_datset_2d is histogram (true) or
%           point data (false). Only necessary if there is ambiguity.
%           Unambiguous cases are:
%             - just one output IX_dataset_2d
%             - all output are point data or all are histogram data

% *** Actually, can work out if all point or all histogram (see code for details)

% Check arguments
% ----------------

narg=numel(varargin);
if narg>=5
    error('IX_dataset_2d:invalid_argument',...
        'Too many input arguments (max 5), got: %d',narg)
end

% if y exists, make a column cell of numeric arrays
if narg>=1 && ~isempty(varargin{1})
    y=varargin{1};
    if isnumeric(y)
        ny=1;
        nely=numel(y);
        y={y};  % make cell for later convenience
    elseif iscellnum(y)
        ny=numel(y);
        y=y(:);
        nely=cellfun(@numel,y);
    else
        error('IX_dataset_2d:invalid_argument',...
            'Check input arguments - y values must be array or cell array of arrays')
    end
else
    y=[];
end

% If y_axis exists, make a column array of IX_axis objects
if narg>=2 && ~isempty(varargin{2})
    if is_string(varargin{2})
        ny_axis=1;
        y_axis=IX_axis(varargin{2});
    elseif iscellstr(varargin{2})
        ok=cellfun(@is_string,varargin{2});
        if ~all(ok(:))
            error('IX_dataset_2d:invalid_argument',...
                'Check y_axis argument - must be string, cell array of strings, or IX_axis object(s)')
        end
        ny_axis=numel(varargin{2});
        y_axis=repmat(IX_axis,ny_axis,1);
        for i=1:ny_axis
            y_axis(i)=IX_axis(varargin{2}(i));
        end
    elseif isa(varargin{2},'IX_axis')
        y_axis=varargin{2}(:);
        ny_axis=numel(y_axis);
    else
        error('IX_dataset_2d:invalid_argument',...
            'Check y_axis argument - must be string, cell array of strings, or IX_axis object(s)')
    end
else
    y_axis=IX_axis;
    ny_axis=1;
end

% If y_distribution given, make a column array of logicals
if narg>=3 && ~isempty(varargin{3})
    if islognum(varargin{3})
        y_dist=logical(varargin{3}(:));     % make column
        ny_dist=numel(y_dist);
    else
        error('IX_dataset_2d:invalid_argument',...
            'Check bindata argument - must be logical scalar or array (or numeric array of 0 and 1)')
    end
else
    y_dist=false;
    ny_dist=1;
end

% If bindata exists, make it a numeric column vector
if narg>=4 && ~isempty(varargin{4})
    if islognum(varargin{4})
        bindata=double(varargin{4}(:));     % make column
        nbindata=numel(bindata);
    else
        error('IX_dataset_2d:invalid_argument',...
            'Check bindata argument - must be logical scalar or array (or numeric array of 0 and 1)')
    end
else
    bindata=[];
    nbindata=0;
end

% Construct arguments for construction of IX_dataset_2d
% ------------------------------------------------------
if isempty(y)
    if isempty(bindata)     % default is point data
        bindata=0;
        nbindata=1;
    end
    if ny_axis==1 && ny_dist==1 && nbindata==1
        if bindata
            y={(0:nw)+0.5};
        else
            y={1:nw};
        end
    else
        error('If do not give y values then must have single values for y_axis, y_dist and bindata')
    end
    nelyc=nw;
    
else
    nel=max([ny,ny_axis,ny_dist,nbindata]);
    if (ny==1||ny==nel) || (ny_axis==1||ny_axis==nel) || (ny_dist==1||ny_dist==nel) || (isempty(bindata)||nbindata==1||nbindata==nel)
        if ny~=nel
            y=repmat(y,nel,1);
            nely=nely*ones(nel,1);
        end
        if ny_axis~=nel
            y_axis=repmat(y_axis,nel,1);
        end
        if ny_dist~=nel
            y_dist=repmat(y_dist,nel,1);
        end
        if isempty(bindata)     % fill according to unambiguous determination from number of IX_dataset_1d and contenst of y
            if sum(nely)==nw
                bindata=zeros(nel,1);   % all point data
            elseif sum(nely)==nw+nel
                bindata=ones(nel,1);    % all bin data
            else
                error('IX_dataset_2d:invalid_argument',...
                    'Number of y values inconsistent with number of number of elements in input IX_dataset_1d object')
            end
        elseif nbindata~=nel
            bindata=repmat(bindata,nel,1);
        end
        nelyc=nely-bindata;    % number of elements per group of 1D objects
        if ~all(nelyc>=1) || ~(sum(nelyc)==nw)
            error('Check length of y array(s) and consistency with any optional histogramming description')
        end
    else
        error('Check size of input arguments')
    end
end

obj=IX_dataset_1d_to_2d(obj,w1,y,y_axis,y_dist,nelyc);

end

%-------------------------------------------------------------------------------------------------
function w2=IX_dataset_1d_to_2d(obj,w1,y,y_axis,y_dist,nelyc)
% Repack an array of IX_dataset_1d into an array of IX_dataset_2d according
% It is assumed that the input argumnets have been checked for consistency

[n,nlo,nhi]=IX_dataset_1d_to_2d_getn(w1,nelyc);
iw2end=cumsum(n);
iw2beg=[1,iw2end(1:end-1)+1];
w2=repmat(IX_dataset_2d,iw2end(end),1);
iw1end=cumsum(nelyc);
iw1beg=[1,iw1end(1:end-1)+1];
for i=1:numel(nelyc)
    w2(iw2beg(i):iw2end(i)) = IX_dataset_1d_to_2d_chunk(obj,w1(iw1beg(i):iw1end(i)),...
        y{i},y_axis(i),y_dist(i),n(i),nlo{i},nhi{i});
end

end

%-------------------------------------------------------------------------------------------------
function [n,nlo,nhi]=IX_dataset_1d_to_2d_getn(w1,nelyc)
% Get the number of IX_dataset_2d that area required for each section of an array of
% IX_dataset_1d that is being split into chunks whose length is given in array nelyc.
%
%   n           Array length numel(nelyc) with number of IX_dataset_2d per chunk
%   nlo, nhi    Cell arrays length numel(nelyc) of arrays giving start and end indixies
%               into w1 for each set of IX_dataset_2d per chunk
%
%Output are cell arrays
nw2=numel(nelyc);
n=zeros(nw2,1); nlo=cell(nw2,1); nhi=cell(nw2,1);

iwend=cumsum(nelyc);
iwbeg=[1,iwend(1:end-1)+1];

nw1=numel(w1);
nx=zeros(nw1,1);
nsignal=zeros(nw1,1);
for i=1:nw1
    nx(i)=numel(w1(i).x);
    nsignal(i)=numel(w1(i).signal);
end

for i=1:nw2
    xsame=false(nelyc(i),1);
    for j=iwbeg(i)+1:iwend(i)
        xsame(j-iwbeg(i)+1) = nx(j)==nx(j-1) && nsignal(j)==nsignal(j-1) && all(w1(j).x==w1(j-1).x);
    end
    nlo{i}=find(~xsame);
    nhi{i}=[nlo{i}(2:end)-1;iwend(i)-iwbeg(i)+1];
    %     nlo{i}=find(~xsame)+iwbeg(i)-1;
    %     nhi{i}=[nlo{i}(2:end)-1;iwend(i)];
    n(i)=numel(nlo{i});
end

end

%-------------------------------------------------------------------------------------------------
function w2=IX_dataset_1d_to_2d_chunk(obj,w1,y,y_axis,y_dist,n,nlo,nhi)
% Repack an array of IX_dataset_1d into an array of IX_dataset_2d according
% to the ranges specified in index arrays for lower and upper limits
% It is assumed that this set of ranges has previously been correctly identified
% as consistent with IX_dataset_2d objects

if numel(y)==nhi(end)   % point mode
    nbin=0;
else
    nbin=1;
end
w2=repmat(obj,n,1);
for i=1:n
    signal=zeros(numel(w1(nlo(i)).signal),nhi(i)-nlo(i)+1);
    error=zeros(size(signal));
    for j=1:nhi(i)-nlo(i)+1
        signal(:,j)=w1(nlo(i)+j-1).signal;
        error(:,j)=w1(nlo(i)+j-1).error;
    end
    w2(i).title =w1(nlo(i)).title;
    w2(i).s_axis = w1(nlo(i)).s_axis;
    w2(i).x_axis = w1(nlo(i)).x_axis;
    w2(i).x_distribution = w1(nlo(i)).x_distribution;
    w2(i).y_axis = y_axis;
    w2(i).y_distribution = y_dist;
    w2(i).x_ = w1(nlo(i)).x;
    w2(i).y_ = y(nlo(i):nhi(i)+nbin);
    w2(i).signal_ = signal;
    w2(i).error_ = error;
    [w2(i),mess] = w2(i).isvalid();
    if ~isempty(mess) % can happen only if input 1D objects are incorrect
        error('IX_dataset_2d:runtime_error',mess);
    end
    
end

end
