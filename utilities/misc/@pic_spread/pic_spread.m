classdef pic_spread
    %Class respronsible for holding range of Matlab figures, spreading
    % them orderly around a screen and doing range of other operations.
    %
    % Usage:
    % initiate class and initial picture positions with appropriate class
    % coustructor (see the details of the constructor below)
    % >>ps=pic_spread(['-tight'])
    %
    % Then place a pictuire in subsequent position:
    % >>ps =ps.place_pic(figure_handle)
    %
    %
    % $Revision: 1524 $ ($Date: 2017-09-27 15:48:11 +0100 (Wed, 27 Sep 2017) $)
    %
    properties(Dependent)
        % current number of pictures to display.
        pic_count;
        % number of hidden figures
        n_hidden_pic;
        % if the placed pictures should be resized according to size
        % specified in pic_size parameter. By default, if '-tight' is
        % selected, pictures are resized and if not '-tight' they are
        % placed as they are.
        resize_pictures;
        %
        pic_size
        % size of the left border in pictures to start from (e.g. if you have
        % windows toolbar on the left side of the screen)
        left_border;
        top_border;
        overlap_borders;
    end
    %
    properties
        
        
    end
    properties(Access=private)
        pic_per_screen_=[4,3];
        
        pic_list_={};
        current_shift_x_=0;
        current_shift_y_=0;
        
        pic_count_=0;
        % rize all previous figures when adding the last one
        rize_stored_figures = false;
        n_hidden_pic_ = 0;
        resize_pictures_ = false;
        
        % size of a screen
        screen_size_=[800,600];
        % standard size of image to plot
        pic_size_ = [800,600];
        % real number of pictures to place on a screen.
        n_pic_per_screen_ = 0;
        
        % size of the left border in pictures to start from (e.g. if you have
        % windows toolbar on the left side of the screen)
        left_border_=40;
        top_border_ =75;
        
        place_pic_tight_ = false;
        overlap_borders_ = false;
    end
    
    methods
        function obj=pic_spread(varargin)
            % constructor initates the class and defines the picture size
            %
            % Usage:
            % >>obj=pic_spread(['-tight']) % -- prepares to put default image spread of 4x3
            %                         picture per creen
            % >>obj=pic_spread([3,2],['-tight']) % -- prepares to put 6 pictures on the screen as
            %                              in the table of 3x2 cells
            %
            % if '-tight' parameter is present, then picture placed on the
            % screen tight, namely overalling picture borders and resizing
            % them to fit on the screen requested number.
            
            keywords={'-tight','rize'};
            set(0,'Units','pixels')
            ss= get(0,'ScreenSize');
            obj.screen_size_=[ss(3),ss(4)];
            [ok,mess,place_pic_tight,rize_fig,param]=parse_char_options(varargin,keywords);
            if ~ok
                error('PIC_SPREAD:invalid_argument',mess);
            end
            obj.rize_stored_figures=rize_fig;
            
            if ~isempty(param) && numel(param{1})==2
                obj.pic_per_screen_ = param{1};
            end
            
            if place_pic_tight
                obj.overlap_borders_=true;
                obj.resize_pictures_ = true;
            end
            obj.pic_size = floor([(obj.screen_size_(1)-obj.left_border)/obj.pic_per_screen_(1),...
                (obj.screen_size_(2)-obj.top_border)/obj.pic_per_screen_(2)]);
            
            obj.current_shift_x_ = obj.left_border;
        end
        %------------------------------------------------------------------
        function pc = get.pic_count(self)
            pc = self.pic_count_;
        end
        %
        function nh = get.n_hidden_pic(self)
            nh = self.n_hidden_pic_;
        end
        %
        function rs = get.resize_pictures(self)
            rs = self.resize_pictures_;
        end
        function self = set.resize_pictures(self,val)
            self.resize_pictures_ = logical(val);
        end
        %
        function ps = get.pic_size(self)
            ps = self.pic_size_;
        end
        function self = set.pic_size(self,val)
            self = check_and_set_pic_size_(self,val);
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
        %------------------------------------------------------------------
        
        function self=place_pic(self,fig_handle,varargin)
            % method moves the provided image into the calculated position
            % within the list of the pictures, resized it according to the
            % figures list
            %
            % defined by the picture handle provided as argument, to current size and
            % postion.
            % if '-rise' option is specified, after adding the last pictures
            %  method also rizes all previous pictures
            
            self = self.calc_pos_place_pic_(fig_handle,varargin{:});
        end
        %
        function self=close_all(self)
            % method closes all related picutres
            valid  = get_valid_ind(self);
            close(self.pic_list_{valid});
            self.pic_list_={};
            
            self.pic_count_=0;
            self.current_shift_x_ =0;
            self.current_shift_y_ =0;
        end
        
        
        function self=hide_n_pic(self,varargin)
            % method hides last n_pic2_hide pictures
            %
            %Usage:
            % self=self.hide_n_figs([n_pic2_hide ])
            %
            % if n_pic2hide is not provided, the method hides last
            % n_pic_per_screen_ images.
            self = hide_npic_(self,varargin{:});
        end
        function self = show_all(self)
            n_all = self.pic_count;
            self = self.show_n_pic(self,n_all);
        end
        %
        function self=show_n_pic(self,varargin)
            % method shows latest block of pictures, stored in class
            %
            % usage:
            % fgc = fgc.show_n_pic([n],['-raise'])
            %
            % if number n is not specified, shows latest full screen of pictures
            %
            % -raise -- if provided, the pictures moved on top of the screen
            %
            self = check_and_show_n_figs_(self,varargin{:});
        end
        %
        function fc = get_pic_handles(self)
            % return the list of stored valid pictures handles
            valid = self.get_valid_ind();
            fc  = self.pic_list_(valid);
        end
        function valid  = get_valid_ind(self)
            % get boolean array containing true for all existing (valid) 
            % images and false for the images which were deleted
            valid = get_existing_(self);

        end
    end
    
end

