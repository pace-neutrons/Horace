classdef spher_proj_caption<an_axis_caption
    %Class describes axis captions, used in spherical projection
    %
    %
    % $Revision$ ($Date$)
    %       
    properties
        % property contains the type of spher_cut projection used in
        % captions. Default is rdd which is rlu (for cubic lattice), 
        % degree, degree and nothing else is currently supported. 
        %
        %TODO: when spher_proj changes to support something else, 
        % the setting should be asigned in get_proj_param method, and 
        % spher_proj_titles method should change to understand those
        % changes.
        proj_type = 'rdd';
    end    
     
    methods
        function obj=spher_proj_caption(varargin)
            obj = obj@an_axis_caption(); 
            % spherical projection does not by default change aspect ratio
            obj.changes_aspect_ratio_ = false;
        end    
        function [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] =...
                data_plot_titles(this,data)
            %Get titling and caption information for an sqw data structure
            % Input:
            % ------
            %   data            Structure for which titles are to be created from the data in its fields.
            %                   Type >> help check_sqw_data for a full description of the fields
            %
            % Output:
            % -------
            %   title_main      Main title (cell array of character strings)
            %   title_pax       Cell array containing axes annotations for each of the plot axes
            %   title_iax       Cell array containing annotations for each of the integration axes
            %   display_pax     Cell array containing axes annotations for each of the plot axes suitable
            %                  for printing to the screen
            %   display_iax     Cell array containing axes annotations for each of the integration axes suitable
            %                  for printing to the screen
            %   energy_axis     The index of the column in the 4x4 matrix din.u that corresponds
            %                  to the energy axis
            
            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                this.spher_plot_titles_(data);
        end
        
    end
    
end

