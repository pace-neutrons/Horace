function [info, sym] = get_syms(arg)
% MATLAB wrapper for python script to generate crystal symmetries
%
% >> [info, symop] = get_syms('P3_212')
% >> [info, symop] = get_syms(13)
%
% where `info` is a string of information on the spacegroup and
% `symop` is an array of symmetry operations which can be used by
% symmetrise_sqw or cut_sqw.
%
% Script to roughly convert from multifit_legacy to modern multifit syntax
%
% J. Wilkins 17-4-2024
%
% To use this function, proper python package containing spglib
% has to be installed with python used by this metod.
% The code in C, and it's a relatively big library available at
% https://github.com/spglib/spglib
%
% There are bindings for other languages than Python but not for Matlab.
% To use the get_syms function you'll have to either do:
% >>mamba install spglib
% or
% >>pip install spglib
% in the Python environment you supply to Matlab using the pyenv function.
% On DAaaS you can use the Mantid environment:
%
%>> pyenv('Version', '/opt/mantidworkbenchnightly/bin/python')
%
% or Euphonic one:
%
%>> pyenv('Version', '/mnt/ceph/auxiliary/excitations/isis_direct_soft/euphonic_env/bin/python')
%
% Usage example:
% [info, symops] = get_syms('Fd-3m');
% proj = line_proj([1 1 0], [-1 1 0]);
% w1 = cut(sqwfile, proj, [0.01], [-1, 1], [-1, 1], [0.2], symops)
%
% Note, that ranges defined in "cut" have to be transformed to each other
% wrt the projection provided using symmetries obtained from get_syms.

pth = fullfile(horace_paths().horace, 'admin');
if count(py.sys.path, pwd) == 0
    insert(py.sys.path, int32(0), pth);
end

outpy = py.get_syms.main(arg);
info = string(outpy(1));
% outpy(2) is a string which begins "sym = {..."
% evalc evaluates it in the current workspace, giving a variable "sym"
% which is returned to the user as the second output variable.
evalc(string(outpy(2));
if nargout < 2
    disp(info)
    disp(sym)
end

end
