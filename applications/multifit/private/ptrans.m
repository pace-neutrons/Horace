function [p,bp]=ptrans(pf,w)
% Transform a list of free parameter values used by the least-squares fitting routine
% to the parameter values needed for function evaluation.
%
% See also ptrans_sig.m

% Update list of parameter values
pp=w.pp0;
pp(w.free)=pf;
pp(w.bound)=w.ratio(w.bound).*pp(w.ib(w.bound));

% Convert to array for global function and cell array for background functions
p=pp(1:w.np)';
bp=mat2cell(pp(w.np+1:end)',1,w.nbp(:)');
bp=reshape(bp,size(w.nbp));
