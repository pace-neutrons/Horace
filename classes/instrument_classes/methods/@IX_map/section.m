function map_out=section(map,index)
% Create a new map object by defined by an index array
%
%   >> mapout=section(map,index)
%
% Input:
% ------
%   map     Mapping (IX_map object)
%   index   Index array into the map that defines the new output map object
%          The index refers to the work space numbers in the range 1,2,...nw
%          where nw is the total number of workspaces. The elements of index
%          must be unique. 
%           (Note: The index array does NOT refer to the numeric workspace
%          'names' given by the field wkno (type >> help IX_map for details))
%
% Output:
% -------
%   mapout  New output map. The workspace 'names' are retained fromt eh original
%          map.

ns=map.ns;
nw=numel(ns);
if numel(index)>0 && min(index)>=1 && max(index)<=nw && numel(unique(index))==numel(index)
    % Get indices into spectrum array that are to be retained
    nend=cumsum(ns);
    nbeg=nend-ns+1;
    nend=nend(index);
    nbeg=nbeg(index);
    s=map.s;
    % Get corresponding indicies into output spectrum array
    ns_out=ns(index);
    nend_out=cumsum(ns_out);
    nbeg_out=nend_out-ns_out+1;
    s_out=zeros(1,sum(ns_out));
    for i=1:numel(nbeg)
        s_out(nbeg_out(i):nend_out(i))=s(nbeg(i):nend(i));
    end
    % Make output map
    map_out.ns=ns_out;
    map_out.s=s_out;
    if ~isempty(map.wkno)
        map_out.wkno=map.wkno(index);
    else
        map_out.wkno=map.wkno;
    end
    map_out=IX_map(map_out);
else
    error(['Indicies of map workspaces must lie in the range 1 -  ',num2str(nw)])
end
