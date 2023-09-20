function [Unit, Factor] = UnitConvert(MaximumValue,UnitSuffix)
    if(MaximumValue == 0)
        UnitMagnitude = 0;
    else
        UnitMagnitude = log10(abs(MaximumValue));
    end
    if(UnitMagnitude >= 24)
        Unit = ['Y' UnitSuffix];
        Factor = 1e-24;
    elseif(UnitMagnitude >= 21)
        Unit = ['Z' UnitSuffix];
        Factor = 1e-21;
    elseif(UnitMagnitude >= 18)
        Unit = ['E' UnitSuffix];
        Factor = 1e-18;
    elseif(UnitMagnitude >= 15)
        Unit = ['P' UnitSuffix];
        Factor = 1e-15;
    elseif(UnitMagnitude >= 12)
        Unit = ['T' UnitSuffix];
        Factor = 1e-12;
    elseif(UnitMagnitude >= 9)
        Unit = ['G' UnitSuffix];
        Factor = 1e-9;
    elseif(UnitMagnitude >= 6)
        Unit = ['M' UnitSuffix];
        Factor = 1e-6;
    elseif(UnitMagnitude >= 3)
        Unit = ['k' UnitSuffix];
        Factor = 1e-3;
    elseif(UnitMagnitude >= 0)
        Unit = [UnitSuffix];
        Factor = 1;
    elseif(UnitMagnitude >= -3)
        Unit = ['m' UnitSuffix];
        Factor = 1e3;
    elseif(UnitMagnitude >= -6)
        Unit = ['µ' UnitSuffix];
        Factor = 1e6;
    elseif(UnitMagnitude >= -9)
        Unit = ['n' UnitSuffix];
        Factor = 1e9;
    elseif(UnitMagnitude >= -12)
        Unit = ['p' UnitSuffix];
        Factor = 1e12;
    elseif(UnitMagnitude >= -15)
        Unit = ['f' UnitSuffix];
        Factor = 1e15;
    elseif(UnitMagnitude >= -18)
        Unit = ['a' UnitSuffix];
        Factor = 1e18;
    elseif(UnitMagnitude >= -21)
        Unit = ['z' UnitSuffix];
        Factor = 1e21;
    elseif(UnitMagnitude >= -24)
        Unit = ['y' UnitSuffix];
        Factor = 1e24;
    end
end

