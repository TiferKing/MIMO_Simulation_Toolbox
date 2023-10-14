function [ChannelImpulseResponse] = InitChannelImpulseResponse(varargin)
%InitChannelImpulseResponse Initialize a structure containing channel impulse response.
%Introduction:
%   Initialize the struct to contain multi-channel to multi-channel impulse
%   response. It will provide a standard struct to log channel impulse
%   response. Using the standard channel impulse response struct will bring
%   much more convenience.
%Syntax:
%   ChannelImpulseResponse = InitChannelImpulseResponse(InputChannel, OutputChannel, TimeStart, TimeEndurance, SampleRate,...
%       AttenuationdB, MaximumFrequency, ChannelPreset)
%Description:
%   ChannelImpulseResponse = InitChannelImpulseResponse(InputChannel, OutputChannel, TimeStart, TimeEndurance, SampleRate,...
%       AttenuationdB, MaximumFrequency, ChannelPreset)
%       returns a preset channel impulse response.
%Input Arguments:
%   InputChannel: (positive integer scalar)
%       Number of transmitte channels.
%   OutputChannel: (positive integer scalar)
%       Number of receive channels.
%   TimeStart: (double)
%       The impulse start time in second.
%   TimeEndurance: (double)
%       The impluse endurance time in second.
%   SampleRate: (double)
%       The impluse sample rate in Sa/s.
%   AttenuationdB: (double)
%       Signal attenuation in dB. This enables the impulse response to be
%       rescaled into an appropriate range.
%   MaximumFrequency: (double)
%       The maximum frequency that channel impluse respose will simulate.
%   ChannelPreset: (string)
%       Channel preset, it is one of blow:
%       'Ideal': Ideal channel, the input signal will have no change.
%       'Gaussian': The channel is represented by a Gaussian impulse.
%       Moreover, each transmitted channel is only connected to its
%       corresponding received channel.
%       'Custom': Channel will be blank.
%Output Arguments:
%   ChannelImpulseResponse: (ChannelImpulseResponse)
%       A channel impulse response.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    DefaultInputChannel = 1;
    DefaultOutputChannel = 1;
    DefaultTimeStart = 0;
    DefaultTimeEndurance = 0;
    DefaultSampleRate = 1;
    DefaultAttenuationdB = 0;
    DefaultChannelPreset = 'Ideal';
    DefaultMaximumFrequency = 0;
    ExpectedChannelPreset = {'Ideal','Gaussian','Custom'};
    InPar = inputParser;
    ValidScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    ValidScalarNoNegNum = @(x) isnumeric(x) && isscalar(x) && (x >= 0);
    addOptional(InPar,'InputChannel', DefaultInputChannel,ValidScalarPosNum);
    addOptional(InPar,'OutputChannel', DefaultOutputChannel,ValidScalarPosNum);
    addOptional(InPar,'TimeStart',DefaultTimeStart,@(x) isnumeric(x));
    addOptional(InPar,'TimeEndurance',DefaultTimeEndurance,ValidScalarNoNegNum);
    addOptional(InPar,'SampleRate',DefaultSampleRate,ValidScalarPosNum);
    addOptional(InPar,'AttenuationdB',DefaultAttenuationdB,@(x) isnumeric(x));
    addOptional(InPar,'MaximumFrequency',DefaultMaximumFrequency,ValidScalarPosNum);
    addOptional(InPar,'ChannelPreset',DefaultChannelPreset,@(x) any(validatestring(x,ExpectedChannelPreset)));
    parse(InPar,varargin{:});
    
    ChannelImpulseResponse = struct;
    ChannelLength = round(InPar.Results.TimeEndurance * InPar.Results.SampleRate);
    ChannelImpulseResponse.ChannelInputNum = InPar.Results.InputChannel;
    ChannelImpulseResponse.ChannelOutputNum = InPar.Results.OutputChannel;
    ChannelImpulseResponse.TimeStart = InPar.Results.TimeStart;
    ChannelImpulseResponse.TimeEndurance = ChannelLength * (1 / InPar.Results.SampleRate);
    ChannelImpulseResponse.SampleRate = InPar.Results.SampleRate;
    ChannelImpulseResponse.AttenuationdB = InPar.Results.AttenuationdB;
    
    if(ChannelLength == 0)
        ChannelLength = 1;
    end
    ChannelImpulseResponse.Signal = zeros(InPar.Results.OutputChannel, InPar.Results.InputChannel, ChannelLength);
    if(InPar.Results.InputChannel > InPar.Results.OutputChannel)
        Channel = InPar.Results.OutputChannel;
    else
        Channel = InPar.Results.InputChannel;
    end
    
    if(strcmp(InPar.Results.ChannelPreset, "Ideal"))
        ChannelImpulseResponse.Signal(:,:,1) = eye(InPar.Results.OutputChannel, InPar.Results.InputChannel);
    elseif(strcmp(InPar.Results.ChannelPreset, "Gaussian"))
        GaussianTau = 1 / (pi * InPar.Results.MaximumFrequency);
        if (GaussianTau < 10 * (1 / InPar.Results.SampleRate))
            warning("The Gaussian impulse sample may not have the precision needed. Please increase the channel sample rate.");
        end
        if (InPar.Results.TimeEndurance > 12 * GaussianTau)
            GaussianImpulse = exp(-(([1 : ChannelLength] .* (1 / InPar.Results.SampleRate) - (6 * GaussianTau)) ...
                .^ 2) ./ (GaussianTau .^ 2));
            GaussianImpulse = GaussianImpulse ./ sum(GaussianImpulse);
            ChannelImpulseResponse.TimeStart = InPar.Results.TimeStart - 6 * GaussianTau;
        else
            GaussianImpulse = exp(-(([1 : ChannelLength] .* (1 / InPar.Results.SampleRate) - (InPar.Results.TimeEndurance / 2)) ...
                .^ 2) ./ (GaussianTau .^ 2));
            GaussianImpulse = GaussianImpulse ./ sum(GaussianImpulse);
            ChannelImpulseResponse.TimeStart = InPar.Results.TimeStart - InPar.Results.TimeEndurance / 2;
        end
        for index = 1 : Channel
            ChannelImpulseResponse.Signal(index, index, :) = GaussianImpulse;
        end
    elseif(strcmp(InPar.Results.ChannelPreset, "Custom"))
        % Return a blank channel impluse respose.
    end
end

