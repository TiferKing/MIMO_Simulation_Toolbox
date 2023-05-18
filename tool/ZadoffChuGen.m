function [ZadoffChuSeq] = ZadoffChuGen(ChannelNum, Length)
%ZadoffChuGen Generate zadoffchu sequence for multi-channel.
%Introduction:
%   Compared to the ‘zadoffChuSeq’ by MATLAB, this function can generate a
%   more general definition of zadoff-chu sequence. This function can
%   generate multiple sequences at once.
%Syntax:
%   ZadoffChuSeq = ZadoffChuGen(ChannelNum, Length)
%Description:
%   ZadoffChuSeq = ZadoffChuGen(ChannelNum, Length)
%       returns the multi-channel zadoff-chu sequence.
%Input Arguments:
%   ChannelNum: (positive integer scalar)
%       Number of channels.
%   Length: (positive integer scalar)
%       Zadoff-Chu sequence length.
%Output Arguments:
%   ZadoffChuSeq: (matrix)
%       Multi-channel zadoff-chu sequence.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    N = Length;
    q = 0;
    cf = mod(N, 2);
    ZadoffChuSeq = zeros(ChannelNum, N);
    RootOffset = round(Length / 4);
    for index = 1 : ChannelNum
        while gcd(nthprime(index + RootOffset), Length) ~= 1
            RootOffset = RootOffset + 1;
        end
        u = nthprime(index + RootOffset);
        ZadoffChuSeq(index, :) = exp(-1i * (pi * u * [0 : N-1] .* ([0 : N-1] + cf + 2 * q)) / N);
    end
end

