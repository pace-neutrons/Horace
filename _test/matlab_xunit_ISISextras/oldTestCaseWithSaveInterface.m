classdef oldTestCaseWithSaveInterface < handle
    % *************************************************************************
    % Deprecated TestCaseWithSave interface
    %
    % Simply adds a few fields for use with teh legacy method
    % save_or_test_variables.
    % That method should *NOT* be used in any new unit tests.
    % *************************************************************************
    
    properties
        % default accuracy of the save_or_test_variables method
        tol = 1.e-8;
        
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
        function this = oldTestCaseWithSaveInterface()
        end
    end
end
