function varargout = set(this, index, varargin)
% Set function
%   >> w = set(w,field,value)   % set field to value
%   >> set(w)                   % list all fields with comments
%   >> set(w,field)             % comment for given field

% Generic method

% Original author: T.G.Perring
%
%   15 Aug 2009:   Updated to allow isvalid to alter input structure (T.G.Perring)

% Based on:
% A Comprehensive Guide to Object Oriented Programming in MATLAB
%   Chapter 9 example set
%   (c) 2004 Andy Register

% ====== SPECIAL TO IX_DATASET_1D ======
% Allow multiple setting of fields, and synonymns allowed for y,e,xlab,ylab: signal,error,x_axis,y_axis
if numel(varargin)>1
    % Set multiple fields; check for synonyms too
    narg=numel(varargin);
    if rem(narg,2)==1
        nams=[{index},varargin(2:2:end)];
        vals=varargin(1:2:end);
        w=struct(this);
        fnams=fieldnames(w);
        for i=1:numel(nams)
            ind=find(strcmp(nams{i},fnams), 1);
            if isempty(ind)
                ind=find(strcmp(nams{i},{'y','e','xlab','ylab'}));
                if isempty(ind)
                    warning(['??? Reference to non-existent field ' nams{i} '.']);
                    return;
                end
                indlist=[2,3,6,4];
                ind=indlist(ind);
            end
            w.(fnams{ind})=vals{i};
        end
        w=IX_dataset_1d(w);
        if nargout>0, varargout{1}=w; end
        return
    else
        warning(['??? Reference to non-existent field ' index '.']);
    end
elseif numel(varargin)==1
    % Single field to be set; check for synonyms
    ind=find(strcmp(index,{'y','e','xlab','ylab'}));
    if ~isempty(ind)
        fieldlist={'signal','error','x_axis','s_axis'};
        index=fieldlist{ind};
    end
end
% =====================================

% one argument, display info and return

if nargin < 3
    fields = fieldnames(this);
    if ~isempty(which([class(this),'/private/fieldnames_comments']))
        possible = fieldnames_comments(this);
        if isequal(possible(1:2:end),fields)    % check fieldnames_comments synchronised with true fields
            possible_struct = struct(possible{:});
        else
            possible = [fields,repmat({{{}}},size(fields))]';
            possible_struct = struct(possible{:});
            warning('??? fieldnames_comments out of synchronisation with true field names')
        end
    else
        possible = [fields,repmat({{{}}},size(fields))]';
        possible_struct = struct(possible{:});
    end
    if nargout == 0
        if nargin == 1
            disp(possible_struct);
        else
            try
                temp_struct.(index) = possible_struct.(index);
                disp(temp_struct);
            catch
                warning(['??? Reference to non-existent field ' index '.']);
            end
        end
    else
        varargout = cell(1,max([1, nargout]));
        varargout{1} = possible_struct;
    end
    return;
end

called_by_name = ischar(index);

% the set switch below needs a substruct
if called_by_name
    index = substruct('.', index);
end

% public-member-variable section
try
    if length(index) > 1
        this.(index(1).subs) = subsasgn(this.(index(1).subs), index(2:end), varargin{:});
    else
        if length(varargin)==1
            this.(index(1).subs) = varargin{1};
        else
            error('Check number of arguments')
        end
    end
catch
    error(['Reference to non-existent field ' index(1).subs '.']);
end

%   15 Aug 2009:   updated to allow isvalid to alter input structure
[ok,message,this]=isvalid(this);
if ~ok
    error(message)
end
varargout{1} = this;
