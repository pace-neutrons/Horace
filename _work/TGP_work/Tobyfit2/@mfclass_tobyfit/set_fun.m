function obj = set_fun(obj,varargin)
% Set foreground function or functions
%
% Set all foreground functions
%   >> obj = obj.set_fun (@fhandle, pin)
%   >> obj = obj.set_fun (@fhandle, pin, free)
%   >> obj = obj.set_fun (@fhandle, pin, free, bind)
%   >> obj = obj.set_fun (@fhandle, pin, 'free', free, 'bind', bind)
%
% Set a particular foreground function or set of foreground functions
%   >> obj = obj.set_fun (ifun, @fhandle, pin,...)    % ifun can be scalar or row vector
%
%
% Form of foreground fit functions
% --------------------------------
% A model for S(Q,w) must have the form:
%
%       function ycalc = my_function (qh, qk, ql, en, par)
%
% More generally:
%       function ycalc = my_function (qh, qk, ql, en, par, c1, c2,...)
%
% where
%   qh, qk, qk  Arrays of h, k, l in reciprocal lattice vectors, one element
%              of the arrays for each data point
%   en          Array of energy transfers at those points
%   par         A vector of numeric parameters that define the
%              function (e.g. [A,J1,J2] as scale factor and exchange parmaeters
%   c1,c2,...   Any further arguments needed by the function (e.g.
%              they could be the filenames of lookup tables)
%
% <a href="matlab:doc('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
% <a href="matlab:doc('example_sqw_flat_mode');">Click here</a> (Dispersionless excitation)

% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_fun_intro = fullfile(mfclass_doc,'doc_set_fun_intro.m')
%
%   mfclass_Horace_doc = fullfile(fileparts(which('sqw/multifit2_sqw')),'_docify')
%   doc_set_fun_sqw_model_form = fullfile(mfclass_Horace_doc,'doc_set_fun_sqw_model_form.m')
%
% <#doc_beg:> multifit
%   <#file:> <doc_set_fun_intro>
%   <#file:> <doc_set_fun_sqw_model_form>
%
% <a href="matlab:doc('example_sqw_spin_waves');">Click here</a> (Damped spin waves)
% <a href="matlab:doc('example_sqw_flat_mode');">Click here</a> (Dispersionless excitation)
% <#doc_end:>

try
    obj = set_fun@mfclass (obj, varargin{:});
catch ME
    error(ME.message)
end
