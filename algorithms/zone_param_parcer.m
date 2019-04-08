function transf_list = zone_param_parcer(pos,q_step_or_transf,erange,varargin)
% Helper function to process input cut parameters in any form and return input
% parameters in standard form, namely cellarray of cut_transf classes
%
% (cellarray to support older Matlab versions, not working with array of classes)
%
%Inputs:
% q_step_or_transf
%             -- either single number or 3-vector of numbers defining
%                cut steps in all 3 q-directions
%                or
%                cellarray of the cut_transf classes, describing symmetry
%                transformations
% erange      -- energy range to combine zones into. Can be
%                empty if q_step_or_transf is cut_transf list but if
%                present in this case, will define common energy range for
%                all symmetry transformations
%
% Optional inputs:
% zonelist    -- list of zones to combine into zone, defined by pos. May be
%                absent if q_step_or_transf is cut_transf list, but if
%                present, will define zone_center of each cut_transf object
% key-value pairs:
% 'correct_fun', function_handle where function_handle is the function, used
%                to modify combined zones and the source zone itself.
%                The function should act on sqw object and have a form
% corrected_sqw = function_handle(source_sqw)
%
% symmetry_type -- possible values are : {'sigma','shift','external'}
%                what type of symmetry transformation to apply.
%
%                If no symmetry_type keyword is specified, assuming 'sigma'
%                symmetry, which will be constructed on transformation
%                if no transformation is specified.
%
%                if 'external' symmetry is specified on input, no symmetry
%                will be constructed for transformation class even if
%                no symmetry is defined for the class
%
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
%

known_keywords={'correct_fun','symmetry_type'};
known_symmetries = {'sigma','shift','external'};
% Verify input arguments in various possible formats and convert them into
% standard form, containing cellarray of cut transformations
if ~iscell(q_step_or_transf)
    if ~(numel(q_step_or_transf)==3 || numel(q_step_or_transf)==1)
        error('COMBINE_EQUIV_LIST:invalid_argument',...
            ['q_step_or_transf variable should be vector of 1 or 3 components',...
            ' or list of cut_transf objects'])
    end
    if numel(q_step_or_transf)==1 % if qe_range is the same for all q-directions, triple it
        cut_par = cut_transf(q_step_or_transf,erange);
    else
        cut_par = cut_transf(q_step_or_transf(1),q_step_or_transf(2),q_step_or_transf(3),erange);
    end
    transf_list = {};
else
    all_cf = cellfun(@(x)(isa(x,'cut_transf')),q_step_or_transf);
    if sum(all_cf) == numel(q_step_or_transf)
        transf_list = q_step_or_transf;
    elseif sum(all_cf) == 0 && numel(q_step_or_transf)==3
        cut_par = cut_transf(q_step_or_transf{1},q_step_or_transf{2},q_step_or_transf{3},erange);
        transf_list = {};
    else
        error('COMBINE_EQUIV_LIST:invalid_argument',['If q_step_or_transf contains a cellarray,'...
            'of cut_transf, all its elements have to be cut_transf objects or 3-component cellarray of data limits'])
    end
end
% check if we have zone list defined
zonelist_defined = false;
if ~isempty(varargin)
    if ~is_string(varargin{1})
        zonelist = varargin{1};
        zonelist_defined = true;
        if numel(varargin)>1
            argi = varargin(2:end);
        else
            argi = {};
        end
    else
        argi = varargin;
    end
else
    argi = {};
end
% do we have common correction function?
if ~isempty(argi)
    [keyval,~]=extract_keyvalues(argi,known_keywords);
    keys = keyval(1:2:end);
    val  = keyval(2:2:end);
    keyval = cell2struct(val,keys,2);
else
    keyval = struct();
end
%check symmetry field and add default symmetry if one has not been specified

if ~isfield(keyval,known_keywords{2})
    keyval.(known_keywords{2})= known_symmetries{1};
    force_symmetry_calc=false;
else
    sym = keyval.(known_keywords{2});
    if ~ismember(sym,known_symmetries)
        error('COMBINE_EQUIV_LIST:invalid_argument',...
            'Symmetry "%s" is not among known symmetries',sym);
    end
    if  strcmpi(sym,'external')
        force_symmetry_calc = false;
    else
        force_symmetry_calc = true;
    end
    
end
% build transformation list on the basis of zone list
if zonelist_defined
    %First we work out which element of zonelist corresponds to pos:
    ind = -1;
    for i=1:numel(zonelist)
        if isequal(zonelist{i},pos)
            ind=i;
            break;
        end
    end
    % extend zone list to the primary zone if it is not there yet
    if ind == -1
        zonelist{end+1} = pos;
        zonelist_extended = true;
    else
        zonelist_extended = false;
    end
    
    if numel(transf_list)>1
        n_cut_pars = numel(transf_list);
        if n_cut_pars == numel(zonelist)-1
            if zonelist_extended
                transf_list{end+1} = transf_list{1};
                transf_list{end+1}.zone_center = pos;
            end
        end
        if n_cut_pars ~=numel(zonelist)
            error('COMBINE_EQUIVALENT_ZONES:invalid_parameters',...
                'Cellarray of cut parameters is defined but number of its elemets: %d is not equeal to number of zones: %d to convert',...
                n_cut_pars,numel(zonelist))
        end
    else
        transf_list=cell(numel(zonelist),1);
        for i=1:numel(transf_list)
            transf_list{i}=cut_par;
        end
    end
    % zonelist is defined so necessary to define centers for each zone to combine
    for i=1:numel(transf_list)
        transf_list{i}.zone_center= zonelist{i};
    end
    
end
% tag each cut range with unique identifier
if isfield(keyval,'correct_fun')
    has_correct_fun = true;
else
    has_correct_fun = false;
end

%-------------------------------------------------------------------------
% All possible input arguments have been verified. Combine them into
% standard form
%
for i=1:numel(transf_list)
    par = transf_list{i};
    par.zone_id  = i;
    par.target_center = pos;
    if has_correct_fun
        par.correct_fun = keyval.correct_fun;
    end
    sym = keyval.symmetry_type;
    if ~strcmpi(sym,'external')
        if ~par.transf_defined || force_symmetry_calc
            if strcmpi(sym,'sigma')
                par = par.set_sigma_transf();
            elseif strcmpi(sym,'shift')
                par = par.set_shift_transf();
            else % should never come here, should be caught above
                error('COMBINE_EQUIV_LIST:invalid_argument',...
                    'Symmetry transformation "%s" is not among known symmetries',sym);
            end
        end
    end
    transf_list{i} = par;
end

