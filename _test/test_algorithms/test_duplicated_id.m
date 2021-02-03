classdef test_duplicated_id < TestCase
    
    properties
    end
    
    methods
        
        function obj = test_duplicated_id(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            obj = obj@TestCase(name);
        end
        function test_update_duplicates_no_empty(~)
            % duplicated ID-s have been updated
            
            runfiles = {rundatah(),rundatah(),...
                rundatah(),rundatah(),rundatah(),...
                rundatah(),rundatah(),rundatah(),rundatah()};
            % create 1,1,2,2,2,3,3,3,3 runid sequence
            runids = [1,1,2,2,2,3,3,3,3];
            for i=1:numel(runfiles)
                runfiles{i}.run_id = runids(i);
            end
            rf_proc = update_duplicated_rf_id(runfiles);
            % Got the sequence from runid
            ids = cellfun(@(x)(x.run_id),rf_proc,'UniformOutput',true);
            rd_unique = [1,4,2,5,6,3,7,8,9];
            assertEqual(ids,rd_unique);
        end
        
        
        function test_update_duplicates(~)
            % duplicated ID-s have been updated
            runfiles = {rundatah(),[],rundatah(),rundatah(),[],...
                rundatah(),rundatah(),rundatah()};
            % create 1,'',2,2,'',3,3,3 runid sequence
            runids = [1,NaN,2,2,NaN,3,3,3];
            for i=1:numel(runfiles)
                if isempty(runfiles{i})
                    continue;
                end
                runfiles{i}.run_id = runids(i);
            end
            rf_proc = update_duplicated_rf_id(runfiles);
            % Got 1,0,2,6,0,3,7,8 sequence
            function id = get_id(run)
                if isempty(run)
                    id = 0;
                else
                    id = run.run_id;
                end
            end
            ids = cellfun(@get_id,rf_proc,'UniformOutput',true);
            assertEqual(ids,[1,0,2,6,0,3,7,8]);
        end
        
        function test_do_nothing_if_data_unique_and_inverse_order(~)
            % routine should not modify the unique run_ids;
            runfiles = {rundatah(),[],[],rundatah(),[]};
            nf = numel(runfiles);
            for i=1:nf
                if ~isempty(runfiles{i})
                    runfiles{i}.run_id = nf-i+1;
                end
            end
            rf_proc = update_duplicated_rf_id(runfiles);
            
            assertEqual(runfiles,rf_proc);
        end
        
        
        function test_do_nothing_if_all_data_unique(~)
            % routine should not modify the unique run_ids;
            runfiles = {rundatah(),[],rundatah()};
            for i=1:numel(runfiles)
                if ~isempty(runfiles{i})
                    runfiles{i}.run_id = i;
                end
            end
            rf_proc = update_duplicated_rf_id(runfiles);
            
            assertEqual(runfiles,rf_proc);
        end
        function test_do_nothing_at_all(~)
            % ignore empty celarray
            runfiles = cell(1,4);
            rf_proc = update_duplicated_rf_id(runfiles);
            assertEqual(runfiles,rf_proc);
        end
        
        
    end
end
