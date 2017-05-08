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
% If fitting objects:
% -------------------
%   function wcalc = my_function (w,p)
%
% or, more generally:
%   function wcalc = my_function (w,p,c1,c2,...)
%
% where
%   w           Object on which to evaluate the function
%   p           A vector of numeric parameters that define the
%              function (e.g. [A,x0,w] as area, position and
%              width of a peak)
%   c1,c2,...   Any further arguments needed by the function (e.g.
%              they could be the filenames of lookup tables)
%
% If fitting x,y,e data:
% ----------------------
%   function ycalc = my_function (x,p)
%
% or, more generally:
%   function ycalc = my_function (x,p,c1,c2,...)
%
% where
%   x           Array of x values
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
%   doc_set_fun_obj_function_form = fullfile(mfclass_doc,'doc_set_fun_obj_function_form.m')
%   doc_set_fun_xye_function_form = fullfile(mfclass_doc,'doc_set_fun_xye_function_form.m')
%
%   x_arg = 'x'
%   x_descr = 'x           Array of x values'
%
% <#doc_beg:> multifit
%   <#file:> <doc_set_bfun_intro>
% If fitting objects:
% -------------------
%   <#file:> <doc_set_fun_obj_function_form> <x_arg> <x_descr>
%
% If fitting x,y,e data:
% ----------------------
%   <#file:> <doc_set_fun_xye_function_form> <x_arg> <x_descr>
%
%     See <a href="matlab:doc('example_1d_function');">example_1d_function</a>
%     See <a href="matlab:doc('example_2d_function');">example_2d_function</a>
%     See <a href="matlab:doc('example_3d_function');">example_3d_function</a>
% <#doc_end:>

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Check there is data
% -------------------
if isempty(obj.data_)
    if numel(varargin)>0
        error ('Cannot set background function(s) before data has been set.')
    else
        return  % no data has been set, so trivial return
    end
end

% Process input
% -------------
isfore = false;
[ok, mess, obj] = set_fun_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
