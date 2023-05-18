function [DigitalSignal] = DigitalSignalGen(Channel, Length, BitRate, Mode, SignalPreset)
%DigitalSignalGen Generate binary data stream.
%Introduction:
%   Generate binary data using the specified method to evaluate the
%   communication system.
%Syntax:
%   DigitalSignal = DigitalSignalGen(Channel, Length, BitRate, Mode, SignalPreset)
%Description:
%   DigitalSignal = DigitalSignalGen(Channel, Length, BitRate, Mode, SignalPreset)
%       returns the generated binary stream.
%Input Arguments:
%   Channel: (positive integer scalar)
%       Number of channels.
%   Length: (positive integer scalar)
%       Binary stream bit length.
%   BitRate: (double)
%       Data stream bit rate in bit/s.
%   Mode: (string)
%       Generating method, it is one of blow:
%       'random': Random data with equal probability of 0 or 1.
%       'ones': All 1.
%       'zeros': All 0.
%       'onoff': A repeating pattern of 101010…
%       'prbs7': Pseudo-Random Binary Sequence in order 7.
%       'prbs9': Pseudo-Random Binary Sequence in order 9.
%       'prbs13': Pseudo-Random Binary Sequence in order 13.
%       'prbs15': Pseudo-Random Binary Sequence in order 15.
%       'prbs20': Pseudo-Random Binary Sequence in order 20.
%       'prbs23': Pseudo-Random Binary Sequence in order 23.
%       'prbs31': Pseudo-Random Binary Sequence in order 31.
%   SignalPreset: (string)
%       The preset reference voltage, impedance and different pair of
%       signal, please refer to 'InitDigitalSignal' for more detail.
%Output Arguments:
%   DigitalSignal: (DigitalSignal)
%       Generated binary stream.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    DigitalSignal = InitDigitalSignal(Channel, 0, Length / BitRate, BitRate, SignalPreset);
    if(strcmp(Mode, "random"))
        DigitalSignal.Signal = randi([0 1],Channel, Length);
    elseif (strcmp(Mode, "ones"))
        DigitalSignal.Signal = ones(Channel, Length);
    elseif (strcmp(Mode, "zeros"))
        DigitalSignal.Signal = zeros(Channel, Length);
    elseif (strcmp(Mode, "onoff"))
        Signal = repmat([1 0], Channel, ceil(Length / 2));
        DigitalSignal.Signal = Signal(:, 1:Length);
    elseif (strcmp(Mode, "prbs7"))
        for index = 1:Channel
            Seed = randi([0 1], 1, 7);
            % PRBS need a start up sequence.
            Seed(1) = 1;
            % This is to prevent the initial sequence from being all 0.
            DigitalSignal.Signal(index,:) = prbs(7, Length, Seed);
        end
    elseif (strcmp(Mode, "prbs9"))
        for index = 1:Channel
            Seed = randi([0 1], 1, 9);
            Seed(1) = 1;
            DigitalSignal.Signal(index,:) = prbs(9, Length, Seed);
        end
    elseif (strcmp(Mode, "prbs13"))
        for index = 1:Channel
            Seed = randi([0 1], 1, 13);
            Seed(1) = 1;
            DigitalSignal.Signal(index,:) = prbs(13, Length, Seed);
        end
    elseif (strcmp(Mode, "prbs15"))
        for index = 1:Channel
            Seed = randi([0 1], 1, 15);
            Seed(1) = 1;
            DigitalSignal.Signal(index,:) = prbs(15, Length, Seed);
        end
    elseif (strcmp(Mode, "prbs20"))
        for index = 1:Channel
            Seed = randi([0 1], 1, 20);
            Seed(1) = 1;
            DigitalSignal.Signal(index,:) = prbs(20, Length, Seed);
        end
    elseif (strcmp(Mode, "prbs23"))
        for index = 1:Channel
            Seed = randi([0 1], 1, 23);
            Seed(1) = 1;
            DigitalSignal.Signal(index,:) = prbs(23, Length, Seed);
        end
    elseif (strcmp(Mode, "prbs31"))
        for index = 1:Channel
            Seed = randi([0 1], 1, 31);
            Seed(1) = 1;
            DigitalSignal.Signal(index,:) = prbs(31, Length, Seed);
        end
    else
        %Default is random
        warning("Cannot recognize generate mode, default using random mode.");
        DigitalSignal.Signal = randi([0 1],Channel, Length);
    end

end

