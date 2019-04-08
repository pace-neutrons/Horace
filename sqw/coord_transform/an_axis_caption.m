classdef an_axis_caption
    %Lightweight class -- parent for different various axis caption classes
    %
    % By default implements sqw recangular cut captions
    %
    %
    % $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)
    %
    properties(Dependent)
        % property specifies if 2D or 3D picture, this class captions
        % is created for, changes aspect ration according to aspect ratio
        % of the data along axes
        changes_aspect_ratio;
    end
    properties(Access=protected)
        % handle to function calculating axes captions
        caption_calc_func_;
        % internal property, which defines if appropriate picture changes
        % aspect ratio of a 2D image.
        changes_aspect_ratio_=true;
    end
    
    methods
        function obj=an_axis_caption(varargin)
            obj.caption_calc_func_ = @data_plot_titles;
        end
        function change=get.changes_aspect_ratio(this)
            change = this.changes_aspect_ratio_;
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
                this.caption_calc_func_(data);
        end
    end
    
end

