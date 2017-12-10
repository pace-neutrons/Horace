function testFliplrMatrix2
disp('Test testFliplrMatrix2')
in = magic(3);
assertEqual(fliplr(in), in(:, [3 2 1]));