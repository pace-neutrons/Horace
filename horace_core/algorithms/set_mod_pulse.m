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
            'You have requested %d outputs but defined only %d input values for them',...
            nargout,numel(in_data));
    end
end
out = cell(1,numel(in_data));


% Perform operations
% ==================

% arrange all inputs into cellarray of accessible objects
obj_list = cell(1,numel(in_data));
for i=1:numel(in_data)
    the_obj = in_data{i};
    if ischar(the_obj) || isstring(the_obj)
        obj_list{i} = sqw_formats_factory.instance().get_loader(the_obj);
    elseif isa(the_obj,'sqw')
        obj_list{i} = the_obj;
    else
        error('HORACE:algorithms:invalid_argument',...
            'The object N%d in the list of input objects is neither sqw object nor sqw file. Its class is: %s', ...
            i,class(the_obj));
    end
end

num_params = size(pm_par,1);

if size(pm_par,1) == 1
    pm_par_split = cell(1,numel(in_data));
    for i=1:numel(in_data)
        pm_par_split{i} = pm_par;
    end
else
    pm_par_split_tot = cell(1,numel(in_data));
    pm_par_split_uni = cell(1,numel(in_data));

    n_tot_runs =0;
    n_unique_runs = 0;
    for i=1:numel(in_data)
        the_obj = obj_list{i};
        if isa(the_obj,'sqw')
            inst = the_obj.experiment_info.instruments();
        elseif isa(the_obj,'sqw_file_interface')
            inst = the_obj.get_instrument('-all');
        else
            error('HORACE:algorithms:invalid_argument', ...
                'This method accepts the list of sqw objects and the class of object N%d in this list is %s (non-sqw type)', ...
                i,class(the_obj));
        end
        if isa(inst,'IX_null_inst')
            error('HORACE:algorithms:invalid_argument', ...
                'This method accepts the list of sqw objects with instruments set and the object N%d in this list does not have instrument defined on it', ...
                i)
        end
        in1 = n_tot_runs;
        n_tot_runs    = n_tot_runs    + inst.n_runs;
        if n_tot_runs <= num_params
            pm_par_split_tot{i} = pm_par(in1+1:inst.n_runs,:);
        end
        in1 = n_unique_runs;
        n_unique_runs = n_unique_runs + inst.n_unique;
        if n_unique_runs <= n_unique_runs
            pm_par_split_uni{i} = pm_par(in1+1:inst.n_unique,:);
        end
    end
    if num_params == n_tot_runs
        pm_par_split  = pm_par_split_tot;
    elseif num_params == n_unique_runs
        pm_par_split  = pm_par_split_uni;
    else
        error('HORACE:sqw:invalid_argument',...
            'Total number of moderator parameters (%d) not equal to 1 and to either to number of total runs (%d) nor the number of unique runs (%d)',...
            num_params,n_tot_runs,n_unique_runs);
    end
end


for i=1:numel(in_data)
    the_obj = obj_list{i};
    if isa(the_obj,'sqw')
        % split input parameters according to the number of parameters and
        % set this parameters on object in memory
        the_obj = the_obj.set_mod_pulse(pulse_model,pm_par_split{i});
    elseif isa(the_obj,'sqw_file_interface')
        % set input parameters on file
        Exper = the_obj.get_header('-all');
        Exper = Exper.set_mod_pulse(pulse_model,pm_par_split{i});
        the_obj = the_obj.upgrade_file_format(); % also reopens file in update mode if format is already the latest one
        the_obj.put_instruments(Exper.instruments);
        the_obj.delete();
    end
    if isa(the_obj,'sqw')
        out{i} = the_obj;    % it was an sqw and we return the modified sqw
    else
        out{i} = in_data{i};  % it was a filename and we return the filename
    end
end
% explicitly close all file accessors if they were present
for i=1:numel(in_data)
    if isa(obj_list{i},'sqw_file_interface')
        obj_list{i}.delete();
    end
end
% format output parameters according to the output request
if nargout == 1
    varargout{1} = out;
else
    for i=1:nargout
        varargout{i} = out{i};
    end
end
