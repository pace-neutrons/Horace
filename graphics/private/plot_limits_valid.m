function [ok,mess] = plot_lims_valid (lims, varargin)
% Check that plot limits have correct format
%
%   >> [ok,mess] = plot_lims_valid (lims, arg1, arg2,...)
%
% If lims=='xy' or 'xyz':
%   >> [ok,mess] = plot_lims_valid (lims)
%   >> [ok,mess] = plot_lims_valid (lims, xlo, xhi)
%   >> [ok,mess] = plot_lims_valid (lims, xlo, xhi, ylo, yhi)
%
% and, if lims=='xyz' only:
%   >> [ok,mess] = plot_lims_valid (lims, xlo, xhi, ylo, yhi, zlo, zhi)
%
% If not OK, then returns suitable error message

par=varargin;
if strcmpi(lims,'xy') || strcmpi(lims,'xyz')
    if numel(par)==0 || numel(par)==2 || numel(par)==4 ||...
            (strcmpi(lims,'xyz') && numel(par)==6)
        % Check limits are numeric scalars
        for i=1:numel(par)
            if ~(isnumeric(par{i}) && isscalar(par{i}))
                ok=false; mess='Plot limits must be numeric scalars'; return
            end
        end
        % Check limits ranges
        if numel(par)>=2 && par{1}>=par{2}
            ok=false; mess='Plot limits along x axis must have xlo < xhi'; return
        end
        if numel(par)>=4 && par{3}>=par{4}
            ok=false; mess='Plot limits along y axis must have ylo < yhi'; return
        end
        if numel(par)>=6 && par{5}>=par{6}
            ok=false; mess='Plot limits along z axis must have zlo < zhi'; return
        end
    else
        ok=false; mess='Check the number of plot limits'; return
    end
else
    error('Invalid limits options - contact developers.')
end

% OK if got to this point
ok=true;
mess='';
