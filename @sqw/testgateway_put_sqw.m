function [ok, mess, S] = testgateway_put_sqw (dummy, file, w, varargin)
% Routine to test get_sqw - only way to get debugger working properly is to use a gateway function
[ok, mess, S] = put_sqw (file, w, varargin{:});
