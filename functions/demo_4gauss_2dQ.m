function y=demo_4gauss_2dQ(q1,q2,p)
%
% Calculate 4 gaussians at symmetric positions in momentum space. This
% function is designed only to work for constant-energy 2D slices
%
% syntax:
%   >> wout= func_eval(win,@demo_4gauss,[pars],options)
%
% Input for function:
% ------
%   q1     variable component q1 (meshgrid syle matrix?)
%   q2     variable component q2 
%   p     the parameters for the FM spin wave model
%   p = [amp1 posx1 posy1 widx1 widy1 amp2 .... bg]
%
% Output:
% -------
%   y    array the same size as the input arrays qvar and en.
%
% RAE 10/7/08

% trick to avoid divide by zero warning
warning_status = warning('query');
warning off
%=============================================

amp=p(1); posx=p(2); posy=p(3); wid=p(4); symposx=p(5); symposy=p(6); bg=p(7);

pos1=[symposx+posx symposy];
pos2=[symposx symposy-posy];
pos3=[symposx-posx symposy];
pos4=[symposx symposy+posy];

y = amp.* (exp(-0.5*((q1-pos1(1))./wid).^2)) .* (exp(-0.5*((q2-pos1(2))./wid).^2))...
    + amp.* (exp(-0.5*((q1-pos2(1))./wid).^2)) .* (exp(-0.5*((q2-pos2(2))./wid).^2))...
    + amp.* (exp(-0.5*((q1-pos3(1))./wid).^2)) .* (exp(-0.5*((q2-pos3(2))./wid).^2))...
    + amp.* (exp(-0.5*((q1-pos4(1))./wid).^2)) .* (exp(-0.5*((q2-pos4(2))./wid).^2)) + bg;


%=============================================
% return to original warning status
warning(warning_status);