classdef unique_con < handle
    properties(Access=private)
        store_ = {};
        hash_ = [];
        idx_ = [];
    end
    methods
        function obj = unique_con(varargin)
            if numel(varargin) == 1 && iscell(varargin{1})
                varargin = varargin{1};
            end
            for ii = 1:numel(varargin)
                if isa(varargin{ii}, 'unique_con')
                    other = varargin{ii};
                    offset = numel(obj.store_);
                    obj.idx_ = cat(2, obj.idx_, other.idx_ + offset);
                    obj.hash_ = cat(1, obj.hash_, other.hash_);
                    obj.store_ = cat(1, obj.store_, other.store_);
                else
                    obj.add_object(varargin{ii});
                end
            end
        end
        function [idx, hash] = is_in_container(self, object)
            % Returns the index in the container if the object is in it else empty
            Engine = java.security.MessageDigest.getInstance('MD5');
            % getByteStreamFromArray is an undocumented built-in used internally 
            % by the `save` function which has been available since at least R2013a
            % but *may* in principle change/be removed in a future Matlab release.
            % https://undocumentedmatlab.com/articles/serializing-deserializing-matlab-data
            Engine.update(getByteStreamFromArray(object));
            hash = typecast(Engine.digest, 'uint8')';
            if isempty(self.hash_)
                idx = [];
            else
                [~, ~, idx] = intersect(hash, self.hash_, 'rows');
            end
        end
        function self = add_object(self, object, add_index)
            [idx, hash] = self.is_in_container(object);
            if isempty(idx)
                self.hash_ = cat(1, self.hash_, hash);
                self.store_ = cat(1, self.store_, {object});
                idx = numel(self.store_);
            end
            if nargin < 3
                self.idx_ = cat(2, self.idx_, idx);
            else
                self.idx_(add_index) = idx;
            end
        end
        function out = subsref(self, s)
            % Overloads Matlab indexing
            switch s(1).type
                case '()'
                    out = self.store_{self.idx_(s(1).subs{1})};
                otherwise
                    error('This class does not support dot or brace notation');
            end
        end
        function self = subsasgn(self, s, val)
            switch s.type
                case '()'
                    self.add_object(val, s.subs{1});
                otherwise
                    error('This class does not support dot or brace notation');
            end
        end
        function out = horzcat(varargin)
            out = unique_con(varargin);
        end
        function out = vertcat(varargin)
            out = unique_con(varargin);
        end
        function out = disp(self)
            out = sprintf('Unique container with %i elements and %i unique elements', ...
                numel(self.idx_), numel(self.store_));
            if nargout == 0
                disp(out)
            end
        end
    end
end