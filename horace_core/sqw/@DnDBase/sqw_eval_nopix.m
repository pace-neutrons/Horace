function  wout = sqw_eval_nopix(wout, sqwfunc, pars, options)
% Helper function for sqw eval executed on a pixel-less object (DnD  or sqw 
%  with no pixels
% Called by `sqw_eval_` defined in sqw/DnDBase
% interface to private sqw_eval_nopix_
for i=1:numel(wout)
    wout(i) = sqw_eval_nopix_(wout(i), sqwfunc, pars,options);
end