function [w, ok, mess, S] = bums_get_sqw (dummy, file, varargin)
% Routine to test get_sqw - only way to get debugger working properly
[w, ok, mess, S] = get_sqw (file, varargin{:});
