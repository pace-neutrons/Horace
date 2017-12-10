function test_suite = testFliplr_B
initTestSuite;

function testFliplrMatrix_B
disp('Test testFliplrMatrix_B')
in = magic(3);
assertEqual(fliplr(in), in(:, [3 2 1]));

function testFliplrVector_B
disp('Test testFliplrVector_B')
assertEqual(fliplr([1 4 10]), [10 4 1]);
