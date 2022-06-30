classdef fixedNameList
    % Create an immutable list of names and methods to test if a string is a member
    %
    % The purpose of the class is to enable te
    % The check on validity ignores character case
    % Very similar to a simple enumeration class
    
    properties (SetAccess=immutable)
        names
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = fixedNameList (varargin)
            % Create a list of names
            %
            %   >> list = fixedNameList (cellstr)
            %   >> list = fixedNameList (nam1, nam2, nam3,...)
            %
            % Input can be:
            %   - cell array of character strings that are valid fieldnames
            %   - list of names that are valid field names
            
            % Standard error message:
            mess = 'Input must be a single cell array of strings, or one or more strings, that are valid variable names';
            
            % Check input makes a siongle cell array
            if nargin==1 && iscell(varargin{1})
                list = varargin{1}(:);  % make column
            elseif nargin>=1
                list = varargin';       % make column
            else
                error(mess)
            end
            
            % Check a cell array of unique strings with case insensitivity
            if all(cellfun(@(x)(is_string(x) & ~isempty(x) & isvarname(x)), list))
                if numel(unique(lower(list)))==numel(list)
                    obj.names = list;
                else
                    error('The names must all be unique with case insensitivity')
                end
            else
                error(mess)
            end
        end
        
        %------------------------------------------------------------------
        % Other methods
        %------------------------------------------------------------------
        function [ok, mess, name] = valid(obj, arg)
            % Determine if arg is an unambiguous abbreviation of one of the fixed names
            ok = false;
            mess = '';
            name = '';
            if ~isempty(arg) && is_string(arg)
                tf = strncmpi(arg, obj.names, numel(arg));
                n = sum(tf);
                if n==1         % unambiguous abbreviation or match
                    ok = true;
                    name = obj.names{tf};
                elseif n>1
                    tf = strcmpi(arg, obj.names);
                    if any(tf)  % ambiguous abbreviation but exact match
                        ok = true;
                        name = obj.names{tf};
                    else
                        mess = 'Ambiguous match to two or more valid names';
                    end
                elseif n==0
                    mess = 'Unrecognised name';
                end
            else
                mess = 'Argument is not a non-empty character string';
            end
        end
        
        %------------------------------------------------------------------
        function ok = match(obj, name, str)
            % Test if
            if is_string(name) && is_string(str)
                if any(strcmpi(name, obj.names))
                    if strcmpi(str, name)
                        ok = true;
                    else
                        ok = false;
                    end
                else
                    error(['''',name,''' is not a valid entry in the fixed name list'])
                end
            else
                error('The fixed name and test argument must both be character strings')
            end
        end
        
        %------------------------------------------------------------------
    end
end
