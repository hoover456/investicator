classdef stock
  properties
    symbol
    closes
    adjCloses
    volumes
    suggestion
    inaccuracy = 0
    sharesOwned = 0
    purchasePrice = 0
  end
  methods
    function revenue = sell(stock, dayIndex)
      revenue = stock.closes(dayIndex) * stock.sharesOwned;
      % stock.sharesOwned = 0;
    end
    function price = getTodaysPrice(stock, dayIndex)
      price = stock.closes(dayIndex);
    end
  end
end
