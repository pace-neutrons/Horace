function varargout = set_mod_pulse(in_data,pulse_model,pm_par)
% Set the moderator pulse shape model and pulse parameters for an array of sqw objects.
%
%   >> wout = set_mod_pulse(win, pulse_model, pp)
%
% Input:
% ------
%   win         Array of sqw objects of sqw type
%   pulse_model Pulse shape model name e.g. 'ikcarp'
%   pm_par      Pulse shape parameters: row vector for a single set of parameters
%               or a 2D array, one row per spe data set in the sqw object(s).
%
% Output:
% -------
%   wout        Output sqw objects


% Original author: T.G.Perring
%




% Parse input
% -----------
if nargin<3
    error('HORACE:algorithms:invalid_argument', ...
        'This function requests 3 input arguments')
end
if ~iscell(in_data)
    in_data =  {in_data};
end

if nargout ~= 1
    if nargout~= numel(in_data)
        error('HORACE:algorithms:invalid_argument', ...
            'You have requested %d outputs but have only %d input values for them',...
            nargout,numel(in_data));
    end
end
out = cell(1,numel(in_data));


% Perform operations
% ==================
for i=1:numel(in_data)
    the_obj = in_data{i};
    if ischar(the_obj) || isstring(the_obj)
        set_mod_pulse_on_file(the_obj,i,pulse_model,pm_par)
        out{i} = the_obj;
    else
        out{i} = the_obj.set_mod_pulse(pulse_model,pm_par);
    end
end
if nargout == 1
    varargout{1} = out;
else
    for i=1:nargout
        varargout{i} = out{i};
    end
end


function set_mod_pulse_on_file(file,n_file,pulse_model,pm_par)

% Change moderator pulse
ld  = sqw_formats_factory.instance().get_loader(file);
if ~ld.sqw_type
    error('HORACE:algorithms:invalid_argument', ...
        'You can only set up moderator pulse on an sqw-type object. The argument N%d, file %s contains DnD-type object', ...
        n_file,file)
end

inst_cont = ld.get_instrument();
if isa(inst_cont,'unique_objects_container')
    inst = inst_cont.unique_objects;
    for i=1:numel(inst)
        inst{i} = inst{i}.set_mod_pulse(pulse_model,pm_par);
    end
    inst_cont.unique_objects = inst;
    inst = inst_cont;
else
    inst = inst_cont.set_mod_pulse(pulse_model,pm_par);
end
ld = ld.put_instruments(inst);
ld.delete();
