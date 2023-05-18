function [ErrorRate, ErrorNum, TotalNum, ErrorPos] = ProbeBitError(DataTx, DataRx)
%ProbeBitError A probe that detects bit errors in the binary stream.
%Introduction:
%   Compare two binary streams and get the error bits.
%Syntax:
%   ErrorRate = ProbeBitError(DataTx, DataRx)
%   [ErrorRate, ErrorNum, TotalNum, ErrorPos] = ProbeBitError(DataTx, DataRx)
%Description:
%   ErrorRate = ProbeBitError(DataTx, DataRx)
%       returns the bit error rate.
%   [ErrorRate, ErrorNum, TotalNum, ErrorPos] = ProbeBitError(DataTx, DataRx)
%       returns a vector that contains the bit error rate, the total number
%       of errors, the total number of bits and the error positions.
%Input Arguments:
%   DataTx: (DigitalSignal)
%       Data stream transmitted.
%   DataRx: (DigitalSignal)
%       Data stream received.
%Output Arguments:
%   ErrorRate: (double)
%       The error rate of the binary stream.
%   ErrorNum: (integer)
%       The number of error bits.
%   TotalNum: (integer)
%       The number of total transmitted bits.
%   ErrorPos: (vector)
%       The index of every error bit.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    ErrorPos = find(DataTx.Signal ~= DataRx.Signal);
    [BitChannel, BitLength] = size(DataTx.Signal);
    TotalNum = BitChannel * BitLength;
    ErrorNum = size(ErrorPos , 1);
    ErrorRate = ErrorNum / TotalNum;
end

