classdef oldTestCaseWithSaveInterface < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % default accuracy of the save_or_test_variables method
        tol = 1.e-8;        %
        
        % default parameters for equal_to_tol function used by
        % save_or_test_variables method. See equal_to_tol function for
        % other methods.
        comparison_par={'min_denominator', 0.01};
        %--- Auxiliary properties.
        % the string printed in the case of errors in
        % save_or_test_variables intended to provide additional information
        % about the error (usually set in front of save_or_test_variables)
        errmessage_prefix = ''
    end
    
    methods
        function obj = oldTestCaseWithSaveInterface()
        end
        
    end
    methods(Access=protected)
        %------------------------------------------------------------------
        function var = get_ref_dataset_(this, var_name, test_name)
            % Retrieve variable from the store for the named test
            %
            % Input:
            % ------
            %   var_name    -- the name of the variable to retrieve
            %   test_name   -- the name of the test the variable belongs to
            %
            % Output:
            % ------
            %   var         -- retrieved variable
            %
            % NOTE: for backwards compatibility with earlier versions:
            % If the variable is not found in the structure for the named
            % test it is looked for at the top level of the class property
            % ref_data_.
            
            if isfield(this.ref_data,test_name) && isstruct(this.ref_data.(test_name))
                % Structure called test_name exists - assume new format
                S = this.ref_data.(test_name);
                if isfield(S,var_name)
                    var = S.(var_name);
                else
                    error('TestCaseWithSave:invalid_argument',...
                        'variable: %s does not exist in stored data for the test: %s',...
                        var_name,test_name);
                end
            else
                % No structure called test_name exists - assume legacy format
                % of variable stored at top level, not in test_name
                if isfield(this.ref_data,var_name)
                    var = this.ref_data.(var_name);
                else
                    % Give the error message for the new format, as we assume that
                    % old format files are correct (we should not be creating any new ones)
                    error('TestCaseWithSave:invalid_argument',...
                        'variable: %s does not exist in stored data for the test: %s',...
                        var_name,test_name);
                end
            end
            
            
        end
    end
    
end
