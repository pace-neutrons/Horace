classdef test_experiment_loadsave < TestCase
    % Tests to check if the Experiment class loads and saves correctly

    properties
        % full path of this file --V
        % its directory --V
        test_dir = fileparts(mfilename('fullpath'));
    end

    methods
        function obj = test_experiment_loadsave(name)
            obj = obj@TestCase(name);
        end
        
        function test_loadsave_single_run_and_sqw(obj)
            % 'rundata_vs_sqw_refdata.mat' is an existing .mat file in the
            % test_sqw suite which provides a single sqw object sq4 with the old
            % header structure using one struct per run (single run) for all data.
            % sq4 is held in a struct test_rundata_sqw which is loadable
            % from the .mat file
            matfile = fullfile(obj.test_dir, 'rundata_vs_sqw_refdata.mat');
            % the file is loaded; the load process should convert the old 
            % struct-type headers into an Experiment class
            load(matfile);
            assertTrue( isa(test_rundata_sqw.sq4.header_x, 'Experiment') );
            % the sq4 object is renamed as 'test_rundata_sqw.sq4' cannot be
            % saved as-is
            tmp_sqw = test_rundata_sqw.sq4;
            % the sqw object is saved with the new Experiment class
            % header_x
            save('experiment_sqw.mat', 'tmp_sqw');
            % tmp_sqw is marked so that it can be seen the mark is removed
            % on reload
            tmp_sqw.main_header.extra='new';
            assertTrue( isfield( tmp_sqw.main_header, 'extra') );
            % tmp_sqw is reloaded from the .mat file, it should reload the
            % Experiment class header_x as-is
            load('experiment_sqw.mat');
            % tmp_sqw is checked that it now does not have the marker field
            % extra in its main_header
            assertTrue( ~isfield( tmp_sqw, 'extra') );
            assertTrue( isa(tmp_sqw.header_x, 'Experiment') );
            assertEqual( tmp_sqw, test_rundata_sqw.sq4);
        end
        
        function test_loadsave_multiple_run_and_sqw(obj)
            % 'multisqw.mat' is an existing .mat file in the
            % test_sqw suite which provides an array sq3 of 2 sqw objects with the old
            % header structure using one struct per run (two runs) for all data.
            % sq3 is  is loadable directly from the .mat file.
            % NB sq3 was created from the 'rundata_vs_sqw_refdata.mat' file
            % by unpacking its object sq4 in an environment without the Experiment
            % class and (1) duplicating the header structs into a cell array 
            % (2) duplicating the sqw objects into a top level array. The
            % headers have been made unique by appending '_1/2/3/4' to the
            % filename roots in the headers.
            matfile = fullfile(obj.test_dir, 'multisqw.mat');
            % the file is loaded; the load process should convert the old 
            % struct-type headers into an Experiment class
            load(matfile);
            assertEqual( numel(sq3), 2);
            assertTrue( isa(sq3(1).header_x, 'Experiment') );
            assertTrue( isa(sq3(2).header_x, 'Experiment') );
            assertEqual( numel(sq3(1).header_x.expdata), 2);
            assertEqual( numel(sq3(1).header_x.instruments), 2);
            assertEqual( numel(sq3(1).header_x.samples), 2);
            assertEqual( numel(sq3(2).header_x.expdata), 2);
            assertEqual( numel(sq3(2).header_x.instruments), 2);
            assertEqual( numel(sq3(2).header_x.samples), 2);
            % the sq3 object is copied as 'sq3_original' to distinguish it
            % from a reload
            sq3_orig = copy(sq3);
            % the sqw object is saved with the new Experiment class
            % header_x
            loadsavefile = fullfile(obj.test_dir, 'experiment_multisqw.mat');
            cleanup_obj = onCleanup(@()delete(loadsavefile));
            save(loadsavefile, 'sq3');
            % sq3 is marked so that it can be seen the mark is removed
            % on reload
            sq3(1).main_header.extra='new';
            sq3(2).main_header.extra='new';
            assertTrue( isfield( sq3(1).main_header, 'extra') );
            assertTrue( isfield( sq3(2).main_header, 'extra') );
            % sq3 is reloaded from the .mat file, it should reload the
            % Experiment class header_x as-is
            load('experiment_multisqw.mat');
            % sq3 is checked that it now does not have the marker field
            % extra in its main_header
            assertTrue( ~isfield( sq3(1).main_header, 'extra') );
            assertTrue( ~isfield( sq3(2).main_header, 'extra') );
            assertTrue( isa(sq3(1).header_x, 'Experiment') );
            assertTrue( isa(sq3(2).header_x, 'Experiment') );
            assertEqual( numel(sq3), 2);
            assertTrue( isa(sq3(1).header_x, 'Experiment') );
            assertTrue( isa(sq3(2).header_x, 'Experiment') );
            assertEqual( numel(sq3(1).header_x.expdata), 2);
            assertEqual( numel(sq3(1).header_x.instruments), 2);
            assertEqual( numel(sq3(1).header_x.samples), 2);
            assertEqual( numel(sq3(2).header_x.expdata), 2);
            assertEqual( numel(sq3(2).header_x.instruments), 2);
            assertEqual( numel(sq3(2).header_x.samples), 2);
            assertEqual( sq3, sq3_orig);
        end
    end
end
