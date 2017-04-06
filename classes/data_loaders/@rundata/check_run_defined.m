function [undefined,fields_from_loader,fields_undef] = check_run_defined(run,fields_needed)
% Method verifies if all necessary run parameters are defined by the class
%
% >> [undefined,fields_to_load,fields_from_defaults,fields_undef] = check_run_defined(run,fields_needed)
%
% Input:
% ------
%   run             Initated instance of the rundata class
%   fields_needed   List of the fields to verify (optional). If absent,
%                  it is derived from the class method.
%
% Output:
% -------
%   undefined       Status flag:
%                     0  - all data defined and loaded to memory
%                     1  - all data defined but some fields have to be read from file
%                     2  - some fields are needed, but no definition for them can be
%                          found in memory, file or from defaults
%
%   fields_from_loader  Cellarray of field names which have to be obtained
%   from loader
%   fields_from_defaults    Cellarray of field names for which the values were
%                          loaded from hard-coded defaults
%   fields_undef    Cellarray of the fields which are unfilled

% $Author: Alex Buts; 20/10/2011
%
% $Revision$ ($Date$)

%
% What fields have to be defined (as function of crystal/powder parameter)?
if ~exist('fields_needed','var')
    fields_needed = what_fields_are_needed(run);
    [all_fields,lattice_fields] = what_fields_are_needed(run);
else
    [all_fields,lattice_fields] = what_fields_are_needed(run,fields_needed);
end
fields_from_loader = {};


undefined  = 0; % false; all defined;

if ~isempty(lattice_fields)
    % If everything is defined, no point to bother, finish
    if isempty(run.lattice)
        the_lattice = oriented_lattice();
    else
        the_lattice = run.lattice;
    end
    undef_lattice  = the_lattice.get_undef_fields();
    other_fields   = ~ismember(all_fields,lattice_fields);
    all_fields     = all_fields(other_fields);
    
else
    undef_lattice = {};
end
% If everything is defined, no point to bother, finish
is_empty_f = @(field)is_empty_field(run,field);
%
is_undef      = cellfun(is_empty_f,all_fields);
fields_undef  = {all_fields{is_undef},undef_lattice{:}};
if isempty(fields_undef)
    return;
end


% Only some of undefined fields are needed to define run
is_needed     = ismember(fields_undef,fields_needed);
fields_undef  = fields_undef(is_needed);
if isempty(fields_undef)
    return;
end

% Something still undefined, let's check if we can deal with it;
undefined = 1;

% Can missing fields be obtained from data loader?
loader_provides = loader_can_define(run.loader);
is_in_loader    = ismember(fields_undef,loader_provides);
if sum(is_in_loader)>0
    fields_from_loader=fields_undef(is_in_loader);
else
    fields_from_loader={};
end

fields_undef = fields_undef(~is_in_loader);

% necessary fields are still undefined by the run
if ~isempty(fields_undef)
    undefined = 2;
    if config_store.instance().get_value('herbert_config','log_level') > -1
        for i=1:numel(fields_undef)
            fprintf('Necessary field undefined: %s \n',fields_undef{i});
        end
        disp(['The field(s) above are neither defined by the data reader ',class(run.loader),' nor by the command line arguments\n']);
    end
    
end

function isit=is_empty_field(data,field)
% the function which is applied to each element of cell array verifying if
% it is empty
isit=false;
val = data.(field);
if isempty(val)
    isit=true;
else
    if ischar(val) && strncmp('undef',val,5)
        isit = true;
    end
end
