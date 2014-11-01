function [w, ok, mess, S] = testgateway_get_sqw (dummy, file, varargin)
% Routine to test get_sqw - only way to get debugger working properly is to use a gateway function
[w, ok, mess, S] = get_sqw (file, varargin{:});
