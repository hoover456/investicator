
function backtest(listName)

  symbols = dataread('file', listName, '%s', 'delimiter', '\n'); % Read in list of symbols

  % Get 2 years data for each symbol
  for i = [1:10]
    data = webread(strcat('http://real-chart.finance.yahoo.com/table.csv?s=',symbols{i}));
    if height(data) >= 730
      SIMULATION_LENGTH = 730;
    else
      continue;
    end
    data = data(1:SIMULATION_LENGTH,:);
    close = fliplr(table2array(data(:,5))');
    volume = fliplr(table2array(data(:,6))');
    adjClose = fliplr(table2array(data(:,7))');
    market(i) = stock;
    market(i).symbol = symbols{i};
    market(i).closes = close;
    market(i).adjCloses = adjClose;
    market(i).volumes = volume;
  end
% PORTFOLIO SETUP
funds = 100000;
net = funds;
% portfolio = [stock];

n = 365;
r = length(market);
for n = [365:730]
  for i = [1:r]
    [market(i).suggestion, market(i).innacuracy] = main(market(i).symbol, market(i).adjCloses(n-364:n), market(i).volumes(n-364:n), 365);
  end

  for j = [1:length(market)]
      if market(j).sharesOwned > 0 && market(j).suggestion == -1
        funds = funds + market(j).sell(n)
        market(j).sharesOwned
      end
  end

  [sorted, indexes] = sort([market.innacuracy]);
  for k = [1:length(indexes)]
    market(k) = market(indexes(k));
  end

  for i = [1:length(market)]
    if funds > net / 5
      if market(i).suggestion == 1
        market(i).purchasePrice = market(i).closes(n);
        market(i).sharesOwned = floor((funds / 5) / market(i).purchasePrice);
        funds = funds - market(i).sharesOwned * market(i).purchasePrice;
        net = funds + sum([market.sharesOwned] .* [market.closes(n)])
      end
    end

  % BUY UNTIL LESS THAN 1/5 of portfolio is cash

  % fprintf('%.0f $%5.2f $%5.2f\n', n, funds, net);
end
