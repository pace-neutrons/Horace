function obj = set_pdf_array_as_input_(obj,objects)
% Compute pdf table array and lookup indexing for pdf_table_lookup
%
% Make a cell array for convenience, if not already
if ~iscell(objects)
    objects = {objects};
end

% Check all arrays have the same class - requirement for sorting later on
if numel(objects)>1
    class_name = class(objects{1});
    tf = cellfun(@(x)(strcmp(class(x),class_name)),objects);
    if ~all(tf)
        error('HERBERT:pdf_table_lookup:invalid_argument', ...
            'The classes of the object arrays are not all the same')
    end
end

% Check existence of public property called 'pdf' that is a scalar pdf_table object
if ~ismethod(objects{1},'pdf_table')
    error('HERBERT:pdf_table_lookup:invalid_argument', ...
        'A method with name pdf_table does not exist')
end

% Assemble the objects in one array
nw = numel(objects);
nel = cellfun(@numel,objects(:));
if any(nel==0)
    error('HERBERT:pdf_table_lookup:invalid_argument', ...
        'Cannot have any empty object arrays')
end
nend = cumsum(nel);
nbeg = nend - nel + 1;
ntot = nend(end);

obj_all=repmat(objects{1}(1),[ntot,1]);
for i=1:nw
    obj_all(nbeg(i):nend(i))=objects{i}(:);
end

% Get unique entries
if fieldsNumLogChar (obj_all, 'indep')
    [obj_unique,~,ind] = uniqueObj(obj_all);    % simple object
else
    [obj_unique,~,ind] = genunique(obj_all,'resolve','indep');
end

% Compute pdf table array and lookup indexing
pdf_arr = arrayfun(@pdf_table,obj_unique);
obj.pdf_table_array_ = pdf_table_array(pdf_arr);
obj.indx_ = mat2cell(ind,nel,1);
