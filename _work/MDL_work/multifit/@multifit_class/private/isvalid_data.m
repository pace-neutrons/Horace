function [ok,mess,data] = isvalid_data(in_dat)
% Checks input dataset(s) and returns dataset in cell array 
% (even if single dataset)
%
% Valid datasets are described in:
% >> help multifit/data

ok = false;
mess = '';

% Put everything into a cell for iteration below
if iscell(in_dat) 
    if all(cellfun(@isnumeric,in_dat))==1
        data = {in_dat};
    else
        data = in_dat;
    end
elseif isstruct(in_dat) || isobject(in_dat)
    for iset=1:numel(in_dat)
        data{iset} = in_dat(iset);
    end
else
    data = in_dat;
    mess = 'Datasets must be cell arrays, structs or objects';
    return;
end

for iset = 1:numel(data)
    d = data{iset};
    if iscell(d) 
        if any(~cellfun(@isnumeric,in_dat)) || numel(d)~=3 || range(cellfun(@numel,in_dat))~=0
            mess = 'A dataset must be a 3-cell array with elements {x y e} of equal size';
            return;
        end
    elseif isstruct(d) 
        if ~all(isfield(d,{'x','y','e'}))
            mess = 'A dataset must be a struct with fields ''x'', ''y'', and ''e''';
            return;
        end
    else
        mth = methods(class(d));
        mth = cell2struct(mth,mth,1);
        %mrq = {'sigvar' 'sigvar_set' 'sigvar_get' 'sigvar_size' 'mask_points' 'mask'; ...
        %        []       []           []           []           'sigvar_getx'  []};
        % Require either mask_points() or sigvar_getx()
        mrq = {'sigvar_get' 'mask_points' 'mask'; ...
                []          'sigvar_getx'  []};
        if ~all(sum(isfield(mth,mrq))~=0)
            prq = cellfun(@(x)strcat(x,','),mrq,'UniformOutput',false);
            prq = strrep(strrep(strcat(prq{:}),',,',','),',',', ');
            mess = ['A dataset must be a class with methods: ' prq];
            return;
        end
    end
end

ok = true;
