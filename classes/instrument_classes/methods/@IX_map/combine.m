function map_out = combine(varargin)
% Combine map data to form a single map object by concatenating the input maps
%
%   >> map_out = combine(map1, map2,...)
%
%   >> map_out = combine(map1, map2,...,'wkno')     % Keep workspace numbers where given
%
%   >> map_out = combine(map1, map2,...,'wkno',vals)% Set workspace numbers
%
%
% Input:
% ------
%   map1        Map object
%   map2        Map object, name of .map file, or single array (see >> help IX_map for details)
%   map3            :
%     :             :
%
% Output:
% -------
%   map_out     Concatenated map object. There must be no spectra in common
%              between the contributing map objects.
%               If the workspace numbers are undefined for all contributing
%              maps, then they are undefined for the output map. If they are
%              for one or more of the input maps, then the defined

classname='IX_map';

% Find 'wkno' option, if given
wkno_def=zeros(1,0);
if nargin>1 && isstring(varargin{end}) && strncmpi(varargin{end},'wkno',numel(varargin{end}))    % ...,'wkno')
    narg=nargin-1;
    opt=true;
    optval=false;
elseif nargin>2 && isstring(varargin{end-1}) && strncmpi(varargin{end-1},'wkno',numel(varargin{end-1}))    % ...,'wkno',val)
    narg=nargin-2;
    opt=true;
    optval=true;
    wkno=varargin{end};
else
    narg=nargin;
    opt=false;
    optval=false;
end


% Collect fields of the input maps
ns=cell(1,narg);
s=cell(1,narg);
wkno=cell(1,narg);
wkno_empty=true(1,narg);
for i=1:narg
    if isa(varargin{i},classname)
        ns{i}=varargin{i}.ns;
        s{i}=varargin{i}.s;
        if ~isempty(varargin{i}.wkno)
            wkno{i}=varargin{i}.wkno;
            wkno_empty(i)=false;
        else
            wkno{i}=NaN(1,numel(ns{i}));
        end
    else
        try
            tmp_map=IX_map(varargin{i});
            ns{i}=tmp_map.ns;
            s{i}=tmp_map.s;
            if ~isempty(tmp_map.wkno)
                wkno{i}=tmp_map.wkno;
                wkno_empty(i)=false;
            else
                wkno{i}=NaN(1,numel(ns{i}));
            end
        catch
            error('Check all input arguments form a valid map object if passed to IX_map')
        end
    end
end

% Build into a single map
map.ns=cell2mat(ns);
map.s=cell2mat(s);
if ~opt || all(wkno_empty)
    map.wkno=[];    % Workspace numbers undefined
else
    if optval
        map.wkno=optval;    % Use provided workspace numbers
    else
        % Must construct a list of workspace numbers, rataining any in the maps, and filling
        % the rest with the smallest possible numbers in numerically increasing order
        wkno_used=cell2mat(wkno(~wkno_empty));    % make an array of the non-empty elements of wkno
        ind=1:sum(map.ns);      % 1:<total number of workspaces>
        ind=ind(~ismember(ind,wkno_used));          % list of smallest numbers that are not already part of wkno
        wkno=cell2mat(wkno);    % make list of workspace numbers where we still have to fill the NaNs
        unfilled=isnan(wkno);
        wkno(unfilled)=ind(1:sum(unfilled));
        map.wkno=wkno;
    end
end

map_out=IX_map(map);
