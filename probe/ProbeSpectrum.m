function [] = ProbeSpectrum(Signal, SeparateDisplay, Title, varargin)
    DefaultSpan = 'Auto';
    DefaultRBW = 'Auto';
    DefaultWindow = 'FlatTop';
    ExpectedWindowPreset = {'FlatTop'};
    InPar = inputParser;
    addOptional(InPar,'Span', DefaultSpan);
    addOptional(InPar,'RBW', DefaultRBW);
    addOptional(InPar,'Window',DefaultWindow,@(x) any(validatestring(x,ExpectedWindowPreset)));
    parse(InPar,varargin{:});

    figure;
    TiledFigure = tiledlayout("flow");
    if (~exist('SeparateDisplay', 'var'))
        SeparateDisplay = false;
    end
    SignalSize = size(Signal.Signal,2);
    %if(strcmp(InPar.Results.Window, "FlatTop"))
        %SignalWithWindow = Signal.Signal .* repmat(flattopwin(SignalSize)', Signal.ChannelNum, 1);
    %end
    FFTConvert = (abs(fft(Signal.Signal .* Signal.ReferenceVoltage, [], 2) / SignalSize) .^ 2) / Signal.ReferenceImpedance;
    if (mod(SignalSize, 2) == 0)
        FFTSize = SignalSize / 2;
        FFTBand = Signal.SampleRate / 2;
        FFTConvert = FFTConvert(:, 1 : SignalSize / 2);
    else
        % Handle the signal in even points, and the specturm of fft should
        % also been calculated correctly.
        FFTSize = (SignalSize - 1) / 2;
        FFTBand = Signal.SampleRate * FFTSize / SignalSize;
        FFTConvert = FFTConvert(:, 1 : FFTSize);
    end
    FFTAutoThreshold = -10;

    if (SeparateDisplay)
        for index = 1 : Signal.ChannelNum
            if(strcmp(InPar.Results.Span, "Auto"))
                % Auto calculate span
                FFTPeak = max(FFTConvert(index, :), [], "all");
                FFTThreshold = FFTPeak * db2pow(FFTAutoThreshold);
                FFTBase = FFTConvert(index, :) > FFTThreshold;
                FFTSpanStart = find(FFTBase, 1, "first");
                FFTSpanStop = find(FFTBase, 1, "last");
                FFTSpan = FFTSpanStop - FFTSpanStart;
                % Expand the monitor span for a little bit.
                if ((FFTSpanStart - round(FFTSpan / 2)) > 1)
                    FFTSpanStart = (FFTSpanStart - round(FFTSpan / 2));
                else
                    FFTSpanStart = 1;
                end
                if ((FFTSpanStop + round(FFTSpan / 2)) < FFTSize)
                    FFTSpanStop = (FFTSpanStop + round(FFTSpan / 2));
                else
                    FFTSpanStop = FFTSize;
                end
                FFTSpan = FFTSpanStop - FFTSpanStart;
                if(FFTSpan < 100)
                    if ((FFTSpanStart - round(FFTSize / 20)) > 1)
                        FFTSpanStart = (FFTSpanStart - round(FFTSize / 20));
                    else
                        FFTSpanStart = 1;
                    end
                    if ((FFTSpanStop + round(FFTSize / 20)) < FFTSize)
                        FFTSpanStop = (FFTSpanStop + round(FFTSize / 20));
                    else
                        FFTSpanStop = FFTSize;
                    end
                end
                FFTSpan = FFTSpanStop - FFTSpanStart;
                FFTStartFrequency = (FFTSpanStart - 1) / FFTSize * FFTBand;
                FFTStopFrequency = (FFTSpanStop - 1) / FFTSize * FFTBand;
                FFTSpanFrequency = FFTSpan / FFTSize * FFTBand;
            else
                FFTSpanStart = round(InPar.Results.Span(1) / Signal.SampleRate * FFTSize);
                FFTSpanStop = round(InPar.Results.Span(2) / Signal.SampleRate * FFTSize);
                FFTSpan = FFTSpanStop - FFTSpanStart;
                FFTStartFrequency = (FFTSpanStart - 1) / FFTSize * FFTBand;
                FFTStopFrequency = (FFTSpanStop - 1) / FFTSize * FFTBand;
                FFTSpanFrequency = FFTSpan / FFTSize * FFTBand;
            end
            if(strcmp(InPar.Results.RBW, "Auto"))
                FFTRBW = round(0.02 * FFTSpan);
                FFTRBWFrequency = FFTRBW / FFTSize * FFTBand;
                FFTRBWRelatively = FFTRBWFrequency / Signal.SampleRate;
            else
                FFTRBWFrequency = InPar.Results.RBW;
                FFTRBW = round(FFTRBWFrequency / Signal.SampleRate * FFTSize);
                FFTRBWRelatively = FFTRBWFrequency / Signal.SampleRate;
            end

            %FFTConvertFiltered = conv(FFTConvert(index, : ), gausswin(FFTRBW * 12, 10)', "same");
            FFTSigma = FFTRBWRelatively / 2 / sqrt(log(2));
            FFTFilterDefinitionDomain = [flip(-[(1 / SignalSize) : (1 / SignalSize) : (7 * FFTSigma)]) [0 : (1 / SignalSize) : (7 * FFTSigma)]];
            FFTWindow = exp(-(FFTFilterDefinitionDomain .^ 2) / (2 .* FFTSigma .^ 2));
            FFTConvertSpan = FFTConvert(index, FFTSpanStart : FFTSpanStop);
            FFTConvertFiltered = convn(FFTConvertSpan, FFTWindow, "same");

            [FrequencyUnit, FrequencyFactor] = UnitConvert(FFTStopFrequency, 'Hz');
            
            Horizon = [(FFTStartFrequency * FrequencyFactor) : (FFTSpanFrequency / FFTSpan * FrequencyFactor) : (FFTStopFrequency * FrequencyFactor)];
            nexttile;
            plot(Horizon, pow2db(FFTConvertFiltered));
            xlim([(FFTStartFrequency * FrequencyFactor) (FFTStopFrequency * FrequencyFactor)]);
            xlabel(TiledFigure, FrequencyUnit);
        end
    else
        nexttile;
        if(strcmp(InPar.Results.Span, "Auto"))
            FFTPeak = max(FFTConvert, [], "all");
            FFTThreshold = FFTPeak * db2pow(FFTAutoThreshold);
            FFTBase = FFTConvert > FFTThreshold;
            FFTSpanStartMin = FFTSize;
            FFTSpanStopMax = 0;
            for index = 1 : Signal.ChannelNum
                FFTSpanStart = find(FFTBase(index, :), 1, "first");
                FFTSpanStop = find(FFTBase(index, :), 1, "last");
                if (FFTSpanStart < FFTSpanStartMin)
                    FFTSpanStartMin = FFTSpanStart;
                end
                if (FFTSpanStop > FFTSpanStopMax)
                    FFTSpanStopMax = FFTSpanStop;
                end
            end
            FFTSpan = FFTSpanStopMax - FFTSpanStartMin;
    
            % Expand the monitor span for a little bit.
            if ((FFTSpanStartMin - round(FFTSpan / 2)) > 1)
                FFTSpanStart = (FFTSpanStartMin - round(FFTSpan / 2));
            else
                FFTSpanStart = 1;
            end
            if ((FFTSpanStopMax + round(FFTSpan / 2)) < FFTSize)
                FFTSpanStop = (FFTSpanStopMax + round(FFTSpan / 2));
            else
                FFTSpanStop = FFTSize;
            end
            FFTSpan = FFTSpanStop - FFTSpanStart;
            if(FFTSpan < 100)
                if ((FFTSpanStart - round(FFTSize / 20)) > 1)
                    FFTSpanStart = (FFTSpanStart - round(FFTSize / 20));
                else
                    FFTSpanStart = 1;
                end
                if ((FFTSpanStop + round(FFTSize / 20)) < FFTSize)
                    FFTSpanStop = (FFTSpanStop + round(FFTSize / 20));
                else
                    FFTSpanStop = FFTSize;
                end
            end
            FFTSpan = FFTSpanStop - FFTSpanStart;
            FFTStartFrequency = FFTSpanStart / FFTSize * FFTBand;
            FFTStopFrequency = FFTSpanStop / FFTSize * FFTBand;
            FFTSpanFrequency = FFTSpan / FFTSize * FFTBand;
        else
            FFTSpanStart = round(InPar.Results.Span(1) / Signal.SampleRate * FFTSize);
            FFTSpanStop = round(InPar.Results.Span(2) / Signal.SampleRate * FFTSize);
            FFTSpan = FFTSpanStop - FFTSpanStart;
            FFTStartFrequency = (FFTSpanStart - 1) / FFTSize * FFTBand;
            FFTStopFrequency = (FFTSpanStop - 1) / FFTSize * FFTBand;
            FFTSpanFrequency = FFTSpan / FFTSize * FFTBand;
        end
        if(strcmp(InPar.Results.RBW, "Auto"))
            FFTRBW = round(0.01 * FFTSpan);
            if(FFTRBW < 1)
                FFTRBW = 1;
            end
            FFTRBWFrequency = FFTRBW / FFTSize * FFTBand;
            FFTRBWRelatively = FFTRBWFrequency / Signal.SampleRate;
        else
            FFTRBWFrequency = InPar.Results.RBW;
            FFTRBW = round(FFTRBWFrequency / Signal.SampleRate * FFTSize);
            FFTRBWRelatively = FFTRBWFrequency / Signal.SampleRate;
        end

        %FFTConvertFiltered = convn(FFTConvert, gausswin(FFTRBW * 12, 10)', "same") ;
        FFTSigma = FFTRBWRelatively / 2 / sqrt(log(2));
        FFTFilterDefinitionDomain = [flip(-[(1 / SignalSize) : (1 / SignalSize) : (7 * FFTSigma)]) [0 : (1 / SignalSize) : (7 * FFTSigma)]];
        FFTWindow = exp(-(FFTFilterDefinitionDomain .^ 2) / (2 .* FFTSigma .^ 2));
        FFTConvertSpan = FFTConvert(:, FFTSpanStart : FFTSpanStop);
        FFTConvertFiltered = convn(FFTConvertSpan, FFTWindow, "same");
        
        %FFTTimeWindow = exp(-(FFTTimeSigma .^ 2 * [[0 + (1 / Signal.SampleRate / 2) : (1 / Signal.SampleRate) : Signal.TimeEndurance / 2] [-Signal.TimeEndurance / 2 : (1 / Signal.SampleRate) : 0 - (1 / Signal.SampleRate / 2)]] .^ 2) / 2) * FFTTimeSigma;
        %FFTConvertFiltered = (abs(fft(Signal.Signal .* Signal.ReferenceVoltage .* FFTTimeWindow, [], 2) / SignalSize / 2 / pi) .^ 2) / Signal.ReferenceImpedance;
        %FFTConvertFiltered = FFTConvert;

        [FrequencyUnit, FrequencyFactor] = UnitConvert(FFTStopFrequency, 'Hz');
        
        Horizon = [(FFTStartFrequency * FrequencyFactor) : (FFTSpanFrequency / FFTSpan * FrequencyFactor) : (FFTStopFrequency * FrequencyFactor)];
        for index = 1 : Signal.ChannelNum
            hold on;
            plot(Horizon, pow2db(FFTConvertFiltered(index,:)));
        end
        xlim([(FFTStartFrequency * FrequencyFactor) (FFTStopFrequency * FrequencyFactor)]);
        xlabel(TiledFigure, FrequencyUnit);
        xlabel(TiledFigure, FrequencyUnit);
    end
    if (exist('Title', 'var'))
        title(TiledFigure, Title);
    end
    hold off;
    drawnow;
end

