classdef stock
  properties
    % DATA
    symbol
    closes
    adjCloses
    volumes
    
    % DECICION MAKERS
    rsi
    macd
    aroon
    obv
    stock
    sma200_50
    decicionSum


    % Portfolio info
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
