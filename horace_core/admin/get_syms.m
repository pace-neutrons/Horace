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
