function obj = set_bfun(obj,varargin)
% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_fun_intro = fullfile(mfclass_doc,'doc_set_fun_intro.m')
%   doc_set_fun_obj_function_form = fullfile(mfclass_doc,'doc_set_fun_obj_function_form.m')
%   doc_set_fun_xye_function_form = fullfile(mfclass_doc,'doc_set_fun_xye_function_form.m')
%
%   type = 'back'
%   pre = 'b'
%   atype = 'fore'
%   x_arg = 'x'
%   x_descr = 'x           Array of x values'
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_set_fun_intro> <type> <pre> <atype>
% If fitting objects:
% -------------------
%   <#file:> <doc_set_fun_obj_function_form> <x_arg> <x_descr>
%
% If fitting x,y,e data:
% ----------------------
%   <#file:> <doc_set_fun_xye_function_form> <x_arg> <x_descr>
%
%     See <a href="matlab:edit('example_1d_function');">example_1d_function</a>
%     See <a href="matlab:edit('example_2d_function');">example_2d_function</a>
%     See <a href="matlab:edit('example_3d_function');">example_3d_function</a>
%
%
% See also set_bfun
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


% Process input
isfore = false;
[ok, mess, obj] = set_fun_private_ (obj, isfore, varargin);
if ~ok, error(mess), end

