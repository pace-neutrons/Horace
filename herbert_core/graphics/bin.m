function bin (n)
% Alter the binning for 1D graphics display.
%
%   >> bin(n)   % Set the plot grouping to be n data points together
%               % n=0 or n=1 corresponds to no binning being applied
%
%   >> bin      % Prints the current value of n
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Obsolete function
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function has been declared obsolete.
% If you want to plot data with grouping of data points, please operate
% on the data with a function tailored for that data and plot that manipulated
% data. The generic algorithm invoked by this function could not be sensitive
% to the details of that data.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

error('HERBERT:graphics:deprecated', ...
      ['This function has been declared obsolete.\n',...
      'If you want to plot data with grouping of data points, please operate\n',...
      'on the data with a function tailored for that data and plot that manipulated\n',...
      'data. The generic algorithm invoked by this function could not be sensitive\n',...
      'to the details of that data.'])
