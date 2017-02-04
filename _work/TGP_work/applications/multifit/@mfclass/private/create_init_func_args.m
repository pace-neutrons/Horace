function [ok, mess, func_init_output_args, bfunc_init_output_args] = ...
    create_init_func_args (func_init, bfunc_init, wmask)
% Create the constant arguments from the initialisation functions, if any
%
%   >> [ok, mess, func_init_output_args, bfunc_init_output_args] = ...
%                       create_init_func_args (func_init, bfunc_init, wmask)
%
% Input:
% ------
%   func_init   Initialisation function for foreground parameters (empty if none)
%   bfunc_init  Initialisation function for background parameters (empty if none)
%   w           Data
%
%
% Output:
% -------
%   ok      True if no problem, false otherwise
%   mess    Empty if ok, error message if not ok
%   
%   func_init_output_args       Cell array containing arguments returned by 
%                              foreground initialisation function. If none,
%                              then set to {}.
%
%   bfunc_init_output_args      Cell array containing arguments returned by 
%                              background initialisation function. If none,
%                              then set to {}.


ok = true;
mess = '';

if ~isempty(func_init)
    [ok,mess,func_init_output_args]=func_init(wmask);
    if ~ok
        mess = ['Foreground preprocessor function: ',mess];
    end
    if ~isrowvector(func_init_output_args)
        func_init_output_args=func_init_output_args(:)';
    end
else
    func_init_output_args={};
end

if ~isempty(bfunc_init)
    if ~isequal(func_init,bfunc_init)
        [ok,mess,bfunc_init_output_args]=bfunc_init(wmask);
        if ~ok
            mess = ['Background preprocessor function: ',mess];
        end
    else
        bfunc_init_output_args=func_init_output_args;
    end
    if ~isrowvector(bfunc_init_output_args)
        bfunc_init_output_args=bfunc_init_output_args(:)';
    end
else
    bfunc_init_output_args={};
end
