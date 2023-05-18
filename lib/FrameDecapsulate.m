function [BaseSignal, ChannelEstimation] = FrameDecapsulate(FrameSignal, PreambleSignal, Filter)
%FrameDecapsulate Decapsulate the frame using channel estimation and unload the preamble.
%Introduction:
%   Use the generalized inverse matrix of channel estimation to unload the
%   preamble, and then remove the preamble. It is a paired function of
%   'FrameEncapsulate'.
%Syntax:
%   BaseSignal = FrameDecapsulate(FrameSignal, PreambleSignal, Filter)
%   [BaseSignal, ChannelEstimation] = FrameDecapsulate(FrameSignal, PreambleSignal, Filter)
%Description:
%   BaseSignal = FrameDecapsulate(FrameSignal, PreambleSignal, Filter)
%       returns the base signal that unloaded from frame.
%   [BaseSignal, ChannelEstimation] = FrameDecapsulate(FrameSignal, PreambleSignal, Filter)
%       returns the base signal and channel estimation matrix that unloaded
%       from frame.
%Input Arguments:
%   FrameSignal: (AnalogSignal)
%       Baseband signal with preamble.
%   PreambleSignal: (AnalogSignal)
%       The preamble signal.
%   Filter: (matrix)
%       If the signal should be filtered, add a filter here. This argument
%       may be used for channel shaping filter. If not used, please input
%       [1].
%Output Arguments:
%   BaseSignal: (AnalogSignal)
%       Payload baseband signal.
%   ChannelEstimation: (matrix)
%       Channel estimation matrix.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    ChannelNum = FrameSignal.ChannelNum;
    ChannelNumTx = PreambleSignal.ChannelNum;
    if (PreambleSignal.SampleRate < FrameSignal.SampleRate)
        % If the sample rate of the preamble signal is slower than the
        % baseband signal, the preamble should be first upsampled.
        Preamble = SignalResample(PreambleSignal, FrameSignal.SampleRate, 'previous');
    elseif (PreambleSignal.SampleRate > FrameSignal.SampleRate)
        Preamble = PreambleSignal;
        warning("Preamble cannot sample faster than base, ignore the sample rate.");
    else
        Preamble = PreambleSignal;
    end
    ShapedSignal = filter(Filter,1,FrameSignal.Signal,[],2);
    % First filter the baseband signal with shaping filter.
    PreambleCorrelation = zeros(ChannelNum, ChannelNumTx, size(FrameSignal.Signal, 2) + size(Preamble.Signal, 2) - 1);
    for index = 1 : ChannelNum
        for indextx = 1: ChannelNumTx
            % Calculate the correlation of the preamble signals.
            PreambleCorrelation(index, indextx, :) = conv(ShapedSignal(index, :), conj(flip(Preamble.Signal(indextx, :))));
        end
    end
    [CorrelationMax, CorrelationMaxIndex] = max(PreambleCorrelation, [],3);
    CorrelationRange = max(abs(CorrelationMax), [],'all');
    % Find the highest level of correlation, and then judge the
    % availability of every other correlation based on it.
    PayloadStart = round(mean(CorrelationMaxIndex(abs(CorrelationMax) > (CorrelationRange / 2)), 'all')) + 1;
    % The payload start time can be found using the correlation.
    EstimationSeq = zeros(ChannelNum, size(PreambleSignal.Signal, 2));
    DownSampleRate = FrameSignal.SampleRate / PreambleSignal.SampleRate;
    for index = 1 : ChannelNum
        EstimationSeqRow = downsample(flip(ShapedSignal(index,1 : PayloadStart), 2), DownSampleRate, round(DownSampleRate / 2));
        % To estimate the channel, the received preamble should be first
        % downsampled to the same sample rate as the sent preamble.
        EstimationSeq(index, :) = flip(EstimationSeqRow(1 : size(PreambleSignal.Signal, 2)));
        % Remove the meaningless symbol before the preamble.
    end
    ChannelEstimation = EstimationSeq * pinv(PreambleSignal.Signal);
    % H = P * H * P ^ (-1)
    TimeStart = FrameSignal.TimeStart + PayloadStart / FrameSignal.SampleRate;
    TimeEndurance = FrameSignal.TimeEndurance - (PayloadStart - 1) / FrameSignal.SampleRate;
    BaseSignal = InitAnalogSignal(ChannelNum, TimeStart, TimeEndurance, FrameSignal.SampleRate, 'Template', 'As', FrameSignal);
    BaseSignal.Signal = pinv(ChannelEstimation) * ShapedSignal(:,PayloadStart : end);
end

