function [] = OFDMVisualizer(IQSignal, SubCarrierNum, CyclicPrefixNum, Filter, SampleRate, DisplayRBWFrequency)
    
    figure;
    TiledFigure = tiledlayout("flow");

    [ChannelNum, IQLength] = size(IQSignal.Signal);
    RawLength = IQLength / SubCarrierNum;
    RawSignal = reshape(IQSignal.Signal', SubCarrierNum, RawLength, ChannelNum);
    
    SampleFactor = SampleRate / IQSignal.SampleRate;
    SpectrumLength = RawLength * (SubCarrierNum + CyclicPrefixNum) * SampleFactor + size(Filter, 2);
    SpectrumWide = round(SpectrumLength / SampleFactor);
    SpectrumWideFrequency = SpectrumWide / SpectrumLength * SampleRate;
    SpectrumStepFrequency = 1 / SpectrumWide * SpectrumWideFrequency;
    DisplayLength = SpectrumWide * 2 + 1;
    DisplaySignal = zeros(SubCarrierNum, DisplayLength);
    DisplayHorizon = [flip(-[SpectrumStepFrequency : SpectrumStepFrequency : SpectrumWideFrequency]) [0 : SpectrumStepFrequency : SpectrumWideFrequency]];
    if (~exist('DisplayRBWFrequency', 'var'))
        DisplayRBWFrequency = (IQSignal.SampleRate / SubCarrierNum) * 0.1;
    end
    DisplayRBWRelatively = DisplayRBWFrequency / SampleRate;
    DisplayFilterSigma = DisplayRBWRelatively / 2 / sqrt(log(2));
    DisplayFilterDefinitionDomain = [flip(-[(1 / SpectrumLength) : (1 / SpectrumLength) : (7 * DisplayFilterSigma)]) [0 : (1 / SpectrumLength) : (7 * DisplayFilterSigma)]];
    DisplayFilter = exp(-(DisplayFilterDefinitionDomain .^ 2) / (2 .* DisplayFilterSigma .^ 2));

    for index = 1 : SubCarrierNum;
        AnalyzeWindow = zeros(SubCarrierNum, RawLength, ChannelNum);
        AnalyzeWindow(index, :, :) = ones(1, RawLength, ChannelNum);
        AnalyzeSignal = RawSignal .* AnalyzeWindow;
        BaseSignal = ifft(AnalyzeSignal) * sqrt(SubCarrierNum);
        OrthogonalSignal = reshape([BaseSignal((SubCarrierNum - CyclicPrefixNum + 1) : SubCarrierNum, :, :); BaseSignal], RawLength * (SubCarrierNum + CyclicPrefixNum), ChannelNum)';
        ShapedSignal = upfirdn([OrthogonalSignal zeros(ChannelNum, 1)]', Filter', SampleFactor)';
        SpectrumSignal = (abs(fft(ShapedSignal' .* IQSignal.ReferenceVoltage)' / SpectrumLength) .^ 2) / IQSignal.ReferenceImpedance;
        DisplaySpectrum = abs([SpectrumSignal(:, SpectrumLength - SpectrumWide + 1 : SpectrumLength) SpectrumSignal(:, 1 : SpectrumWide + 1)]);
        DisplaySignal(index, :) = mean(DisplaySpectrum, 1);
    end
    [FrequencyUnit, FrequencyFactor] = UnitConvert(SpectrumWideFrequency, 'Hz');

    DisplayFiltered = convn(DisplaySignal, DisplayFilter, "same");
    
    nexttile;
    plot(DisplayHorizon * FrequencyFactor, pow2db(DisplayFiltered'));
    xlim([(-SpectrumWideFrequency * FrequencyFactor) (SpectrumWideFrequency * FrequencyFactor)]);
    
    nexttile;
    plot(DisplayHorizon * FrequencyFactor, pow2db(sum(DisplayFiltered, 1)'));
    xlim([(-SpectrumWideFrequency * FrequencyFactor) (SpectrumWideFrequency * FrequencyFactor)]);
    
    xlabel(TiledFigure, [FrequencyUnit ' (RBW = ' num2str(DisplayRBWFrequency * FrequencyFactor) FrequencyUnit ')']);
    ylabel(TiledFigure, 'dBW');
    title(TiledFigure, 'OFDM Visualizer');
end

