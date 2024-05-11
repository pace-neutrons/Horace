function [info, ops] = get_syms(arg)
% MATLAB wrapper for python script to generate crystal symmetries
%
% >> get_syms('P3_212')
% >> get_syms(13)
%
% Script to roughly convert from multifit_legacy to modern multifit syntax
%
% J. Wilkins 17-4-2024

    pth = fullfile(horace_paths().horace, 'admin');
    if count(py.sys.path, pwd) == 0
        insert(py.sys.path, int32(0), pth);
    end

    [info, ops] = py.get_syms.main(arg);
    if nargout < 2
        disp(info)
        disp(ops)
    end

end
