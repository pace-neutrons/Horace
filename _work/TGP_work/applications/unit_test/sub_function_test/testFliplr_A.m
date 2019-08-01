function test_suite = testFliplr_A
initTestSuite;

function testFliplrMatrix_A
disp('Test testFliplrMatrix_A')
in = magic(3);
assertEqual(fliplr(in), in(:, [3 2 1]));

function testFliplrVector_A
disp('Test testFliplrVector_A')
assertEqual(fliplr([1 4 10]), [10 4 1]);
