function [OutputSignal] = ChannelConvolution(InputSignal, InputChannel)
%ChannelConvolution Channel convolution core.
%Introduction:
%   This is the convolution core of the channel simulation. Note: This
%   function is poorly optimized. To improve the channel simulation
%   performance, this function should be optimized first. It will bring a
%   huge performance boost to the channel simulation.
%Syntax:
%   OutputSignal = ChannelConvolution(InputSignal, InputChannel)
%Description:
%   OutputSignal = ChannelConvolution(InputSignal, InputChannel)
%       returns the signal and channel impulse response convolution.
%Input Arguments:
%   InputSignal: (matrix)
%       Channel input signals.
%   InputChannel: (matrix)
%       Channel impulse response for each channel.
%Output Arguments:
%   OutputSignal: (matrix)
%       Signal convolutions.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    [OutputNum, InputNum, ChannelLength] = size(InputChannel);
    InputLength = length(InputSignal);
    OutputSignal = zeros(OutputNum, ChannelLength + InputLength - 1);
    InputSignal = [InputSignal zeros(InputNum, ChannelLength - 1)];
    for indextime = 1 : ChannelLength
        OutputSignal = OutputSignal + InputChannel(:, :, indextime) * InputSignal;
        InputSignal = circshift(InputSignal,1,2);
    end

    %OutputSignal = pagemtimes(InputChannel, InputSignal);
    %for indextime = 1 : ChannelLength
        %OutputSignal(:, :, indextime) = circshift(OutputSignal(:, :, indextime), indextime - 1,2);
    %end
    %OutputSignal = sum(OutputSignal, 3);
end

