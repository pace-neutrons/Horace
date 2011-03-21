function xytext
% Puts cross-hairs on the screen and prompts for text to be written at that location
% when the left pouse button is pressed. Contionues until carriage return is hit.

val=[0,0];
display ('Click left mouse button; <carriage return> to finish')
while ~isempty(val)
    val = ginput(1);
    if ~isempty(val)
        string = input ('Text to write (<CR> to exit): ','s');
        if ~isempty(string)
            text(val(1),val(2),string);
        end
    end
end
