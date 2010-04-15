function varargout=combine_equivalent_zones(data_source,proj,pos,qstep,erange,outfile,varargin)
%
% wout=combine_equivalent_zones(data_source,proj,pos,qstep,erange,outfile)
% wout=combine_equivalent_zones(data_source,proj,pos,qstep,erange,outfile,keyword)
% wout=combine_equivalent_zones(data_source,proj,pos,qstep,erange,outfile,zonelist)
%
% or as above with no output argument, so that final 4-dimensional object
% is not retained in memory
%
% Create a new sqw file which corresponds to just one Brillouin zone, but
% with data from equivalent positions. Default choice is all equivalent
% wavevectors, but can also manually specify which zones are to be combined.
% This is done either by using the keywords:
%   '-cyclic' : only cyclic permutations (with no sign changes) of the chosen zone are included
%   '-cycwithneg' : cyclic permutations AND the negatives (e.g. (2,1,0),
%   (-2,1,0) etc.
%   '-ab' : equivalent positions in the ab plane
%   '-ac' : equivalent positions in the ac plane
%   '-bc' : equivalent positions in the bc plane
%
% Alternatively one can explicitly provide a list of wavevectors to be
% combined by providing a cell array
%
% RAE 30/3/2010

%==========================================================================
%First do some checks on the inputs:

if ~ischar(data_source)
    error('Horace error: data source must be a string');
end

if ~isstruct(proj)
    error('Horace error: proj must be a structure array');
elseif ~isfield(proj,'u') || ~isfield(proj,'v')
    error('Horace error: proj structure array must have fields u and v');
end

if ~isnumeric(pos) || numel(pos)~=3
    error('Horace error: pos argument must be a vector with 3 elements specifying h,k,l of reference Brillouin zone');
end

if ~isnumeric(qstep)
    error('Horace error: step argument must be numeric');
elseif numel(qstep)~=1 && numel(qstep)~=3
    error('Horace error: step argument must either be a single number, or a vector containing 3 elements');
end

if ~isnumeric(erange)
    error('Horace error: erange argument must be numeric');
elseif numel(erange)~=3
    error('Horace error: erange argument must either be a vector containing 3 elements');
end

if ~ischar(outfile)
    error('Horace error: outfile argument must be a string');
end

%==========================================================================

%Now work out what format the arguments have taken:
basicinput=false; cellinput=false; keywordinput=false;
if nargin==6
    basicinput=true;
elseif nargin==7
    if iscell(varargin{1})
        cellinput=true;
    elseif ischar(varargin{1})
        keywordinput=true;
    end
else
    error('Horace error: check the format of optional inputs are either cell array or keyword');
end

%===
%If optional inputs have been chosen, check that they are in the correct
%format:

if cellinput
    zonelist=varargin{1};
    if prod(size(zonelist))~=numel(zonelist)
        error('Horace error: cell array specifying zones must be a 1-by-n cell array');
    else
        for i=1:numel(zonelist)
            if ~isnumeric(zonelist{i}) || numel(zonelist{i})~=3
                error('Horace error: all elements of cell array specifying zones must be 3-element vectors');
            end
        end
    end
end

if keywordinput
    keyword=varargin{1};
    if ~strcmp(keyword,'-cyclic') && ~strcmp(keyword,'-cycwithneg') && ~strcmp(keyword,'-ab') && ...
            ~strcmp(keyword,'-ac') && ~strcmp(keyword,'-bc');
        error('Horace error: keyword must be either ''-cyclic'', ''-cycwithneg'', ''-ab'', ''-ac'', or ''-bc''');
    end
end

%==========================================================================

if basicinput
    wout=combine_equiv_basic(data_source,proj,pos,qstep,erange,outfile);
elseif keywordinput
    wout=combine_equiv_keyword(data_source,proj,pos,qstep,erange,outfile,keyword);
elseif cellinput
    wout=combine_equiv_list(data_source,proj,pos,qstep,erange,outfile,zonelist);
else
    error('Horace error: logic flaw - contact R. Ewings');
end

if nargout==1
    varargout{1}=wout;
end
    
    
