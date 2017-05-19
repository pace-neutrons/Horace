function obj = set_bfun(obj,varargin)
% Set background function or functions
%
% Set all background functions
%   >> obj = obj.set_bfun (@fhandle, pin)
%   >> obj = obj.set_bfun (@fhandle, pin, free)
%   >> obj = obj.set_bfun (@fhandle, pin, free, bind)
%   >> obj = obj.set_bfun (@fhandle, pin, 'free', free, 'bind', bind)
%
% Set a particular background function or set of background functions
%   >> obj = obj.set_bfun (ifun, @fhandle, pin,...)    % ifun can be scalar or row vector
%
%
% Form of background fit functions
% --------------------------------
%   function ycalc = my_function (x1,x2,...,p)
%
% or, more generally:
%   function ycalc = my_function (x1,x2,...,p,c1,c2,...)
%
% where
%   x1,x2,... Array of x values, one array for each dimension
%   p           A vector of numeric parameters that define the
%              function (e.g. [A,x0,w] as area, position and
%              width of a peak)
%   c1,c2,...   Any further arguments needed by the function (e.g.
%              they could be the filenames of lookup tables)
%
%     See <a href="matlab:doc('example_1d_function');">example_1d_function</a>
%     See <a href="matlab:doc('example_2d_function');">example_2d_function</a>
%     See <a href="matlab:doc('example_3d_function');">example_3d_function</a>

% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_bfun_intro = fullfile(mfclass_doc,'doc_set_bfun_intro.m')
%   doc_set_fun_xye_function_form = fullfile(mfclass_doc,'doc_set_fun_xye_function_form.m')
%
%   class_name = 'mfclass_Horace'
%   x_arg = 'x1,x2,...'
%   x_descr = 'x1,x2,... Array of x values, one array for each dimension'
%
% <#doc_beg:> multifit
%   <#file:> <doc_set_bfun_intro>
%   <#file:> <doc_set_fun_xye_function_form> <x_arg> <x_descr>
%
%     See <a href="matlab:doc('example_1d_function');">example_1d_function</a>
%     See <a href="matlab:doc('example_2d_function');">example_2d_function</a>
%     See <a href="matlab:doc('example_3d_function');">example_3d_function</a>
% <#doc_end:>

try
    obj = set_bfun@mfclass (obj, varargin{:});
catch ME
    error(ME.message)
end

