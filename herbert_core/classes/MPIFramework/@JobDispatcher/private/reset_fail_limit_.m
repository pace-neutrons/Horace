function this = reset_fail_limit_(this,new_fail_limit)
% Recet fail limit according to changes in task waiting times
%
this.fail_limit_ = ceil(new_fail_limit);
if this.fail_limit_ < 2
    this.fail_limit_ = 2;
end
