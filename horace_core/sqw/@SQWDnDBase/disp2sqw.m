function wout = disp2sqw(win, dispreln, pars, fwhh,varargin)

wout = win;
for i=1:numel(win)
    wout(i).data = disp2sqw(win(i).data, dispreln, pars, fwhh,varargin{:});
end