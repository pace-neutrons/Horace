classdef fig_spread
    % Class respronsible for holding range of Matlab figures, spreading
    % them orderly around a screen and doing range of auxiliary operations.
    %
    % Usage:
    %
    % >>ps=fig_spread(['-tight'])       -- create class to hold matlab figures
    % >>ps =ps.place_fig(figure_handle) -- place a figtuire on a subsequent
    %                                      plot, located in the next
    %                                      available screen position.
    %
    %Other useful
    %fig_spread Methods:
    %
    %replot_figs - re-plot figures again resizing them according to current
    %              settings and ignoring missing (deleted) figures.
    %grab_all    - take all plotted figures under the control of the
    %              class and replot them according to class settings.
    %close_all   - delete all controlled figures
    %
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    properties(Dependent)
        % current number of fig handles the class contains (including deleted figures)
        fig_count;
        % number of hidden figures (not displayed by Matlab)
        n_hidden_fig;
        % if the placed figures should be resized according to the size
        % specified in fig_size parameter. By default, if '-tight' is
        % selected, figures are resized and if not '-tight' they are
        % placed as they are.
        resize_figures;
        % 2-element vector, defining the size of each fig in sequence
        fig_size
        % size of the left border in figures to start from (e.g. if you have
        % windows toolbar on the left side of the screen)
        left_border;
        % size of the top border in figures to start from
        top_border;
        % if fig-s should be placed tight e.g. with their borders
        % overlapped.
        overlap_borders;
        % number of figures actually placed on screen (2-element vector
        % with x and y axis values)
        screen_capacity_nfig;
    end
    %
    properties(Access=private)
        screen_capacity_nfig_=[4,3];
        
        fig_count_=0;
        fig_list_={};
        
        % rize all previous figures when adding the last one
        rise_stored_figures_ = false;
        %
        resize_figures_ = false;
        %
        n_hidden_fig_ = 0;
        
        
        % size of a screen
        screen_size_=[800,600];
        % standard size of image to plot
        fig_size_ = [800,600];
        
        % size of the left border in figtures to start from (e.g. if you have
        % windows toolbar on the left side of the screen)
        left_border_=40;
        top_border_ =75;
        
        place_fig_tight_ = false;
        overlap_borders_ = false;
    end
    
    methods
        function obj=fig_spread(varargin)
            % constructor initiates the class and defines the figure size and
            % initial figure position on the screen according to the
            % settings and screen parameters
            %
            % Usage:
            % >>obj=fig_spread(['-tight']) % -- prepares to put default image spread of 4x3
            %                                   figure per screen
            % >>obj=fig_spread([3,2],['-tight']) % -- prepares to put 6 figures on the screen as
            %                                       in the table of 3x2 cells
            %
            % if '-tight' parameter is present, then figure placed on the
            % screen tight, namely overlapping figure borders and resizing
            % them to fit on the screen requested number.
            
            warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            
            
            keywords={'-tight','-rise'};
            set(0,'Units','pixels')
            ss= get(0,'ScreenSize');
            obj.screen_size_=[ss(3),ss(4)];
            [ok,mess,place_fig_tight,rise_fig,param]=parse_char_options(varargin,keywords);
            if ~ok
                error('FIG_SPREAD:invalid_argument',mess);
            end
            obj.rise_stored_figures_=rise_fig;
            
            if ~isempty(param) && numel(param{1})==2
                obj.screen_capacity_nfig_ = param{1};
            end
            
            if place_fig_tight
                obj.overlap_borders_=true;
                obj.resize_figures_ = true;
            end
            obj.fig_size = floor([(obj.screen_size_(1)-obj.left_border)/obj.screen_capacity_nfig_(1),...
                (obj.screen_size_(2)-obj.top_border)/obj.screen_capacity_nfig_(2)]);
            
        end
        %------------------------------------------------------------------
        function pc = get.fig_count(self)
            pc = self.fig_count_;
        end
        %
        function nh = get.n_hidden_fig(self)
            nh = self.n_hidden_fig_;
        end
        %
        function rs = get.resize_figures(self)
            rs = self.resize_figures_;
        end
        function self = set.resize_figures(self,val)
            self.resize_figures_ = logical(val);
        end
        %
        function ps = get.fig_size(self)
            ps = self.fig_size_;
        end
        function self = set.fig_size(self,val)
            self = check_and_set_fig_size_(self,val);
        end
        %
        function lb = get.left_border(self)
            if self.overlap_borders_
                lb = 0;
            else
                lb = self.left_border_;
            end
        end
        function self = set.left_border(self,val)
            self.left_border_ = double(val);
        end
        %
        function tb = get.top_border(self)
            if self.overlap_borders_
                tb = 0;
            else
                tb = self.top_border_;
            end
        end
        function self = set.top_border(self,val)
            self.top_border_ = double(val);
        end
        %
        function ob = get.overlap_borders(self)
            ob = self.overlap_borders_;
        end
        function self = set.overlap_borders(self,val)
            self.overlap_borders_ = logical(val);
        end
        %
        function sc = get.screen_capacity_nfig(self)
            if self.resize_figures
                sc = self.screen_capacity_nfig_;
            else
                ps = self.fig_size;
                sc = [floor((self.screen_size_(1)-self.left_border)/ps(1)),...
                    floor((self.screen_size_(2)-self.top_border)/ps(2))];
            end
        end
        %------------------------------------------------------------------
        
        function self=place_fig(self,fig_handle,varargin)
            % method moves the provided figure into the calculated position
            % within the list of the figures and resizes it according to the
            % class settings
            %
            % if '-rise' option is specified, after adding the last figures
            %  method also rises all previous figures
            %
            self = self.calc_pos_place_fig_(fig_handle,varargin{:});
        end
        %
        function self = replot_figs(self,varargin)
            % plot figures again ignoring missing (deleted) figures.
            %
            % place subsequent figures one after another, using
            % (possibly new) class picture parameters.
            %
            self = replot_figs_(self,varargin{:});
        end
        function save_figs(self,filename)
            % save all controlled valid figures into Matlab figures file.
            save_figs_(self,filename);
        end
        function self = load_figs(self,filename)
            % load previously saved figs to memory, add then to
            % fig controlled list and replot all
            self = load_figs_(self,filename);
        end
        
        %
        function self=close_all(self)
            % closes and deletes all figures, referred by the class
            valid  = get_valid_ind(self);
            if any(valid)
                close(self.fig_list_{valid});
            end
            
            self.fig_count_=0;
            self.fig_list_={};
        end
        %
        function obj = grab_all(obj,varargin)
            % retrieve all existing (plotted) figures under the class
            % control for further operations (e.g. resizing, replotting)
            obj = grab_all_(obj,varargin{:});
            obj = obj.replot_figs();
        end
        %
        function self=hide_n_fig(self,varargin)
            % hide speficied number of visible figures.
            %
            %Usage:
            % self=self.hide_n_figs([n_fig2_hide ])
            %
            % if n_fig2hide is not provided, the method hides last
            % n_fig_per_screen_ images.
            self = hide_nfig_(self,varargin{:});
        end
        function self = show_all(self,varargin)
            n_all = self.fig_count;
            self = self.show_n_fig(self,n_all,varargin{:});
        end
        %
        function self=show_n_fig(self,varargin)
            % show speficied number of hidden figures.
            %
            % usage:
            % fgc = fgc.show_n_fig([n],['-raise'],['-force'])
            %
            % if number n is not specified, shows latest full screen of figures
            %
            % -raise -- if provided, the figures moved on top of the screen
            % -force -- if provided, ignores the sign identifying number of
            %           hidden figures to be 0, which can happen if you
            %           have hided some pictures but not assigned the
            %           changed class to a new value.
            %
            self = check_and_show_n_figs_(self,varargin{:});
        end
        %
        function fc = get_fig_handles(self)
            % return the list of stored valid (not deleted) figures handles
            valid = self.get_valid_ind();
            fc  = self.fig_list_(valid);
        end
        %
        function valid  = get_valid_ind(self)
            % get boolean array containing true for all existing (valid)
            % figures and false for the images which are deleted.
            valid = get_existing_(self);
            
        end
        %
        function [ix,iy,n_frames] = calc_fig_pos(self,nfig,size_x,size_y)
            % calculate the position of the figure number n on the screen
            % given the figture size.
            %
            % Usage:
            % [ix,iy,n_frames] = self.calc_fig_pos(nfig,size_x,size_y)
            %  where:
            %  self -- initiated instance of fig_spread class, defining
            %          screen size, number of figs to place on the
            %          screen and the type of fig placement (tigt, free,
            %          resize, keep existing size etc.)
            %  nfig -- number of figure to calculate postion
            %  size_x- size of the fig (in pixels) defining the X-size of the
            %          fig and its X-position in the sequence of size_x-sized
            %          figures.
            %  size_y- size of the fig (in pixels) defining the Y-size of the
            %          fig and its Y-position in the sequence of size_y-sized
            %          figures.
            % Outputs
            %  ix   -- initial x-coordinate (in pixels) where the fig will
            %          be plotted
            %  iy   -- initial y-coordinate (in pixels) where the fig will
            %          be plotted
            % n_frames - number of previous blocks of figures which the
            %          figure  number nfig overplots.
            [ix,iy,n_frames] = calc_fig_pos_(self,nfig,size_x,size_y);
        end
        
    end
    
end

