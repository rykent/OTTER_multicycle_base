#! /bin/bash


#Start Tests
echo "Starting Test_all"
cp $PWD/../mem/test_all.mem $PWD/../mem/current_test.mem
make PLUSARGS="+PC=0x1ec" COCOTB_RESULTS_FILE="test_all_results.xml"


echo "Starting Matrix Sum 3x3"
cp $PWD/../mem/matsum3x3.mem $PWD/../mem/current_test.mem
make PLUSARGS="+PC=0x58" COCOTB_RESULTS_FILE="matsum3_results.xml"


echo "Starting Matrix Sum 10x10"
cp $PWD/../mem/matsum10x10.mem $PWD/../mem/current_test.mem
make PLUSARGS="+PC=0x58" COCOTB_RESULTS_FILE="matsum10_results.xml"


echo "Starting Matrix Sum 50x50"
cp $PWD/../mem/matsum50x50.mem $PWD/../mem/current_test.mem
make PLUSARGS="+PC=0x60" COCOTB_RESULTS_FILE="matsum50_results.xml"


echo "Starting Matrix Multiply 3x3"
cp $PWD/../mem/matmul3x3.mem $PWD/../mem/current_test.mem
make PLUSARGS="+PC=0x58" COCOTB_RESULTS_FILE="matmul3_results.xml"

echo "Starting Matrix Multiply 10x10"
cp $PWD/../mem/matmul10x10.mem $PWD/../mem/current_test.mem
make PLUSARGS="+PC=0x58" COCOTB_RESULTS_FILE="matmul10_results.xml"

echo "Starting Matrix Multiply 50x50"
cp $PWD/../mem/matmul50x50.mem $PWD/../mem/current_test.mem
make PLUSARGS="+PC=0x60" COCOTB_RESULTS_FILE="matmul50_results.xml"


#Parse Results

#Cleanup


wait

echo "All done"