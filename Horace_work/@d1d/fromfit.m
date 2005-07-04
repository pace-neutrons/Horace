function [wcalc, p, dp, fixed]= fromfit (win)
% Returns a spectrum with the y values calculated at the x-values of an
% input spectrum using the latest parameters and function in Mfit.
%
% Syntax:
%   >> wcalc = fromfit (w)                    % most common use
%
%   >> [wcalc, p, dp, fixed] = fromfit (w)    % to recover parameter values etc.

% Original: JvD: 26-08-3
% Extended: TGP: 27-01-05


% Obtain the (xrange, yramge,...etc) of the data set that was fitted
% in Mfit and store them temporarily. Will be sent back to MFit later
% to leave Mfit in its original state.
[xstore, ystore, estore, selectedstore, fitstore, pstore, dpstore, fixedstore] = fromfit;

% Calculate y values with current parameters:
w=get(win);
if length(w.x)~=length(w.y)
    xcalc = 0.5*(w.x(2:end)'+w.x(1:end-1)');
else
    xcalc = w.x';
end
tomfit(xcalc, w.y', w.e', ones(1,length(xcalc)));
[xtemp, ytemp, etemp, stemp, ycalc, ptemp, dptemp, fixedtemp]= fromfit;
wcalc = win;
if isa(wcalc,'tofspectrum')
    wtemp = get(wcalc, 'spectrum');
    wtemp = set(wtemp, 'y', ycalc, 'e', zeros(1,length(ycalc)));
    wcalc = set_spectrum(wcalc,wtemp);
else
    wcalc = set(wcalc, 'y', ycalc, 'e', zeros(1,length(ycalc)));
end

% Re-initialise Mfit to the original data set that was fitted.
tomfit(xstore, ystore, estore, selectedstore, pstore, fixedstore);
