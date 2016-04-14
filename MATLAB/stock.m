classdef stock
  properties
    % DATA
    symbol = 0
    closes
    adjCloses
    volumes

    % DECICION MAKERS
    rsi
    macd
    aroon
    obv
    stoch
    sma200_50
    decisionSum


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
    function sum = getDecisionSum(stock, dayIndex)
      sum = stock.decisionSum(dayIndex);
    end
  end
end
