function [labels, added] = put_struct_to_labels (varargin)
% Create cell array of label strings strom a structure.
%
%   >> labels = put_struct_to_labels (struc)
%   >> [labels, added] = put_struct_to_labels (struc, labels_in)
%
%   >> ... = put_struct_to_labels (..., opt, fields) 
%
% Input:
% ------
%   struc       Structure
%   labels_in   Input cellstr of labels to which labels will be added
%   opt         Option: 'except' or 'only'  to indicate which fields should be written
%   optfields   If opt='except': cell array of strings of field names not to be written
%                  opt='only'  : only write these fields
%
% Output:
% -------
%   labels      Output cellstr of labels to which labels will be added
%   added       Logical flag: indicates if information was added to the input structure f_in
%
%
% Label information will be written in the form:
%   lhs_1 = rhs_1
%   lhs_2 = rhs_2
%       :    :
% 
% Will write numeric scalar or array, strings or cell arrays of strings. If cell array, then 
% writes on successive lines with the same variable name e.g. title={'Hello','Mister'} is written
%   title = Hello
%   title = Mister

% T.G.Perring   March 2008: Created.
%               May 2011:   Renamed from write_labels to put_struct_to_labels and functionality increased.

if nargin==1
    struc=varargin{1};
    labels=cell(0);
    option=false;
elseif nargin==2
    struc=varargin{1};
    labels=varargin{2};
    option=false;
elseif nargin==3
    struc=varargin{1};
    labels=cell(0);
    option=true;
    opt=varargin{2};
    optfields=varargin{3};
elseif nargin==4
    struc=varargin{1};
    labels=varargin{2};
    option=true;
    opt=varargin{3};
    optfields=varargin{4};
end
   
if ~option
    fields=fieldnames(struc);
    for i=1:length(fields)
        labels=[labels,make_label(fields{i},struc.(fields{i}))];
    end
else
    if ischar(opt)
        if strcmp(opt,'only')
            for i=1:length(optfields)
                if isfield(struc,optfields{i})
                    labels=[labels,make_label(optfields{i},struc.(optfields{i}))];
                end
            end
        elseif strcmp(opt,'except')
            fields=fieldnames(struc);
            for i=1:length(fields)
                if ~any(strcmp(fields{i},optfields))
                    labels=[labels,make_label(fields{i},struc.(fields{i}))];
                end
            end
        end
    else
        error('Check option')
    end
end
added=~isempty(struct);

end

%======================================================================================================
function label=make_label(name,var)

name=[name,' = '];
label = cell(0);

if isempty(var)     % write out label only
    label = sprintf ('%s', name);
    
elseif iscellstr(var)
    for i=1:numel(var)
        label = [label, strtrim(sprintf('%s%s', name, var{i}))];
    end
    
elseif isa(var,'char')
    dims = size(var);
    if length(dims)>2  % multi-dimensional character array; 2nd dimension is the string
        var = reshape(var,dims(1),dims(2),prod(dims(3:end)));   % reshape to be array of matricies
        for j=1:prod(dims(3:end))
            for i=1:dims(1)
                label = [label, strtrim(sprintf('%s%s', name, var(i,:,j)))];
            end
        end
    else
        for i=1:dims(1)
            label = [label, strtrim(sprintf('%s%s', name, var(i,:)))];
        end
    end

elseif isa(var,'numeric')
    label=make_numeric_label(name,var,label,'%-25.16g');

elseif isa(var,'logical')
    label=make_numeric_label(name,uint8(var),label,'%-2.1u');
    
else
    error(['No rule for creating label for class = ',class(var)])

end

end

%======================================================================================================
function label=make_numeric_label(name,var,label,fmt_single)

dims = size(var);
fmt = repmat(fmt_single,1,dims(2));
if length(dims)>2  % multi-dimensional array; layout as pages of matricies
    var = reshape(var,dims(1),dims(2),prod(dims(3:end)));   % reshape to be array of matricies
    fmt = ['%s',fmt];
    for j=1:prod(dims(3:end))
        for i=1:dims(1)
            label = [label, strtrim(sprintf(fmt, name, var(i,:,j)))];
        end
    end
else
    fmt = ['%s',fmt];
    for i=1:dims(1)
        label = [label, strtrim(sprintf(fmt, name, var(i,:)))];
    end
end

end
