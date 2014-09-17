function [ok, mess, S] = bums_put_sqw (dummy, file, w, varargin)
% Routine to test put_sqw - only way to get debugger working properly
[ok, mess, S] = put_sqw (file, w, varargin{:});
