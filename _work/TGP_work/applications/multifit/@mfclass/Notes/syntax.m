%   >> obj = multifit
% 
%   >> obj = multifit (data)
%
% ===============================================================================================
% Set functions
% ===============================================================================================
%
% Setting or changing datasets
% ----------------------------
% Set the data, clearing all functions:
%   >> obj = obj.set_data (x,y,z)
%   >> obj = obj.set_data (w1,w2,...)
%
% Append dataset(s):
%   >> obj = obj.add_data (x,y,z)
%   >> obj = obj.add_data (w1,w2,...)
%
% Replace datasets, but leave the functions unchanged:
%   >> obj = obj.replace_data (i,x,y,z) % Replace ith dataset with x-y-e triple
%   >> obj = obj.replace_data (i,w)     % Replace with {x,y,e}, or scalar
%                                       % structure or object
%   >> obj = obj.replace_data (x,y,e)   % Replace the single dataset
%   >> obj = obj.replace_data (w)       % Replace the single dataset
%   >> obj = obj.replace_data (w1,w2,..)% Replace all dataset(s) with equal number
%
% Remove data, clearing corresponding functions:
%   >> obj = obj.remove_data (i)        % Remove ith dataset
%   >> obj = obj.remove_data            % Remove all data
%
%
% Options: apply to individual datasets or all according to type of the argument
%   (...,'keep',xkeep,...)
%   (...,'remove',xremove,...)
%   (...,'mask',mask,...)
%
%
% Setting or changing functions
% -----------------------------
% Set all foreground functions
%   >> obj = obj.set_fun (@fhandle, pin)
%   >> obj = obj.set_fun (@fhandle, pin, pfree)
%   >> obj = obj.set_fun (@fhandle, pin, pfree, pbind)
%   >> obj = obj.set_fun (@fhandle, pin, 'pfree', pfree, 'pbind', pbind)
%
% Set a particular foreground function or set of foreground functions
%   >> obj = obj.set_fun (ifun, @fhandle, pin, pfree, pbind)    % ifun can be scalar or row vector
%
% [[It would have been nice to have the following:
% The set function acts on existing functions if do not give a function handle. THis
% will only work if the relevant function handles are set
%   >> obj = obj.set_fun (pin, pfree, pbind)          % applies to all
%   >> obj = obj.set_fun (ifun, pin, pfree, pbind)    % ifun can be scalar or row vector
% However, this is not possible, as it is not possible to tell the difference between
%   >> obj = obj.set_fun (pin, pfree)
% & >> obj = obj.set_fun (ifun, pin)
% as numeric arrays are valid for both. That is why we insist that the handle and
% initial; parameters have to be given together.]]
%
% EXAMPLES:
%   >> obj = obj.set_fun (@gauss, [100,10,1.2])                  
%   >> obj = obj.set_fun (@gauss, {[100,10,1.2],[70,9,0.9]})     % two gaussians
%   >> obj = obj.set_fun (@gauss, pin, pfree)    % scalar pfree applies to all functions
%   >> obj = obj.set_fun (@gauss, pin, 'pbind', pbind_)  % scalar cell array pbind applies to all functions
%
% Set one or all background functions:
%   >> obj = obj.set_bfun (...)
%
%
% Remove functions, clearing any corresponding constraints
%   >> obj = obj.remove_fun
%   >> obj = obj.remove_fun (ifun)
%
%   >> obj = obj.remove_bfun (...)
%
%
% Set free parameters
% -------------------
% Foreground functions
%   >> obj = obj.set_free
%   >> obj = obj.set_free (pfree)   % pfree row vector (applies to all) or cell array (one per function)
%   >> obj = obj.set_free (ifun)
%   >> obj = obj.set_free (ifun, pfree)
%
% Background functions
%   >> obj = obj.set_bfree (...)
%       
%
% Binding
% -------
% Set bindings; ame as add bindings, but clears all existing bindings first
%   >> obj = obj.set_bind (...)
%
%
% Add bindings:
%   >> obj = obj.add_bind ([ip,ifun],[ipbnd,ifunbnd])
%   >> obj = obj.add_bind ([ip,ifun],[ipbnd,ifunbnd],ratio)
%   >> obj = obj.add_bind ({[ip,ifun],[ipbnd,ifunbnd],ratio}, {...}, {...}, ...)
%
%   >> obj = obj.add_bind (ifun,ip,[ipbnd,ifunbnd],ratio)
%   >> obj = obj.add_bind (ifun, {ip,[ipbnd,ifunbnd],ratio}, {...}, ...)
%
%   Here ifun>0 for foreground, ifun<0 for background functions
%
%   >> obj = obj.add_bbind (...)
%
%   Here ifun>0 for background, ifun<0 for foreground functions
%
%
% Clear bindings:
%   >> obj = obj.remove_bind
%   >> obj = obj.remove_bind (ifun)
%
%   >> obj = obj.remove_bbind (...)
%
%
% Fitting and simulating
% ----------------------
%   >> obj = obj.simulate               % Perform simulation using starting parameters
%   
%   >> obj = obj.fit                    % Perform fit
%
%
%
% ===============================================================================================
% Get functions
% ===============================================================================================
%   >> w = obj.get_data             % Cell array of all data (unless single dataset)
%   >> w = obj.get_data (ind)       % Return indicated data sets
%
% Also:
%   >> w = obj.data                 % Always the internal form i.e. a cell array, even if single dataset
%
% -----------------------------------------------------------------------------------------------
%   >> w = obj.get_fun              % Cell array unless single function
%   >> w = obj.get_fun (ind)
%
%   >> w = obj.get_bfun
%   >> w = obj.get_bfun (ind)
%
% Also:
%   >> w = obj.fun
%   >> w = obj.bfun
%
% -----------------------------------------------------------------------------------------------
%   >> w = obj.get_pin
%   >> w = obj.get_pin (ind)
%
%   >> w = obj.get_bpin
%   >> w = obj.get_bpin (ind)
%
% Also
%   >> w = obj.pin
%   >> w = obj.bpin
%
% -----------------------------------------------------------------------------------------------
%   >> w = obj.get_free
%   >> w = obj.get_free (ind)
%
%   >> w = obj.get_bfree
%   >> w = obj.get_bfree (ind)
%
% Also
%   >> w = obj.free
%   >> w = obj.bfree
%
%
% -----------------------------------------------------------------------------------------------
%   >> w = obj.get_bind
%   >> w = obj.get_bind (ind)
%
%   >> w = obj.get_bbind
%   >> w = obj.get_bbind (ind)
%
% Also
%   >> w = obj.bind
%   >> w = obj.bbind
%
%
%
%








