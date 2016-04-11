classdef stock
  properties
    symbol
    closes
    adjCloses
    volumes
    suggestion
    innacuracy
    sharesOwned = 0
    purchasePrice
  end
  methods
    function revenue = sell(dayIndex)
      revenue = closes(dayIndex) * sharesOwned;
      sharesOwned = 0;
    end
  end
end
