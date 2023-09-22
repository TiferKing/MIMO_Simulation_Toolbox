function [ErrorRate, ErrorNum, TotalNum, ErrorPos] = ProbeBitError(DataTx, DataRx, Title)
%ProbeBitError A probe that detects bit errors in the binary stream.
%Introduction:
%   Compare two binary streams and get the error bits.
%Syntax:
%   ErrorRate = ProbeBitError(DataTx, DataRx)
%   [ErrorRate, ErrorNum, TotalNum, ErrorPos] = ProbeBitError(DataTx, DataRx)
%   [ ___ ] = ProbeBitError(DataTx, DataRx, Title)
%Description:
%   ErrorRate = ProbeBitError(DataTx, DataRx)
%       returns the bit error rate.
%   [ErrorRate, ErrorNum, TotalNum, ErrorPos] = ProbeBitError(DataTx, DataRx)
%       returns a vector that contains the bit error rate, the total number
%       of errors, the total number of bits and the error positions.
%   [ ___ ] = ProbeBitError(DataTx, DataRx, Title)
%       display all these results after 'Title' on console.
%Input Arguments:
%   DataTx: (DigitalSignal)
%       Data stream transmitted.
%   DataRx: (DigitalSignal)
%       Data stream received.
%   Title: (string)
%       Probe display title.
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
    
    if(size(DataTx.Signal) == size(DataRx.Signal))
        ErrorNum = sum(DataTx.Signal ~= DataRx.Signal, "all");
        [BitChannel, BitLength] = size(DataTx.Signal);
        TotalNum = BitChannel * BitLength;
        ErrorRate = ErrorNum / TotalNum;
        ErrorPos = find(DataTx.Signal ~= DataRx.Signal);
    else
        % Bit stream with different size
        [BitChannel, BitLength] = size(DataTx.Signal);
        TotalNum = BitChannel * BitLength;
        ErrorNum = TotalNum;
        ErrorRate = TotalNum / TotalNum;
        ErrorPos = [1 : TotalNum];
    end
    if(exist('Title','var'))
        DisplayString = [Title '_TotalBitNum = ' num2str(TotalNum) ' bits.'];
        disp(DisplayString);
        DisplayString = [Title '_ErrorNum    = ' num2str(ErrorNum) ' bits.'];
        disp(DisplayString);
        DisplayString = [Title '_ErrorRate   = ' num2str(ErrorRate * 100) ' %.'];
        disp(DisplayString);
    end
end

