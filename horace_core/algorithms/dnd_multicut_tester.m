classdef dnd_multicut_tester < data_sqw_dnd
    % helper class used to test cut operations on multiple files or
    % multiple dnd objects
    properties

    end

    methods
        function obj = dnd_multicut_tester(varargin)
            obj = obj@data_sqw_dnd(varargin{:});
        end

        function  wout = cut(obj, varargin)
            % overloaded cut
            wout = obj;
        end
    end
    methods(Static)
        function [nin,nout,fn_present,filenames,argi] = cut_inputs_tester(nin,nout,varargin)
            %
            [nin,nout,fn_present,filenames,argi] = parse_cut_inputs_(nin,nout,varargin{:});            
        end
        
    end
end